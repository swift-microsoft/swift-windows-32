#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel

    extension Windows.`32`.Kernel.Process.Test.Integration {

        @Test
        func `a child spawned without stdio does not hold another pipe open`() throws {
            let pipe = try Windows.`32`.Kernel.Pipe.pipe()
            let pair = consume pipe.underlying
            let read = pair.first

            let bystander = try Inheritance.spawn(
                "cmd.exe /C ping -n 11 127.0.0.1 >NUL",
                actions: Windows.`32`.Kernel.Process.Spawn.Actions()
            )
            _ = pair.second

            #expect(Inheritance.isBroken(read._rawValue))
            Inheritance.terminate(bystander)
            _ = consume read
        }

        @Test
        func `concurrent captures reach end of file while bystanders run`() throws {
            let started = unsafe GetTickCount64()
            let workers = (0..<4).map { _ in Inheritance.Worker() }
            var threads: [Windows.`32`.Kernel.Thread.Handle] = []
            for worker in workers {
                threads.append(
                    try Windows.`32`.Kernel.Thread.create {
                        worker.run(captures: 5)
                    }
                )
            }

            var bystanders: [UInt] = []
            for _ in 0..<5 {
                bystanders.append(
                    try Inheritance.spawn(
                        "cmd.exe /C ping -n 21 127.0.0.1 >NUL",
                        actions: Windows.`32`.Kernel.Process.Spawn.Actions()
                    )
                )
                unsafe Sleep(100)
            }

            for thread in threads { thread.join() }
            let elapsed = unsafe GetTickCount64() - started
            for bystander in bystanders { Inheritance.terminate(bystander) }

            #expect(workers.allSatisfy { $0.completed == 5 })
            #expect(elapsed < 15_000)
        }
    }

    enum Inheritance {

        final class Worker: @unchecked Sendable {
            var completed = 0

            func run(captures: Int) {
                for _ in 0..<captures {
                    guard (try? Inheritance.capture()) == true else { return }
                    completed += 1
                }
            }
        }

        struct NoResult: Swift.Error {}

        static func capture() throws -> Bool {
            var actions = try Windows.`32`.Kernel.Process.Spawn.Actions()
            let pipe = try Windows.`32`.Kernel.Pipe.pipe()
            try actions.markHandleInheritable(pipe.write)
            actions.setStdout(pipe.write)

            let child = try spawn("cmd.exe /C echo x", actions: actions)
            let pair = consume pipe.underlying
            let read = pair.first
            _ = pair.second

            let bytes = drain(read._rawValue)
            _ = consume read
            terminate(child)
            return bytes.first == UInt8(ascii: "x")
        }

        static func spawn(
            _ command: Swift.String,
            actions: consuming Windows.`32`.Kernel.Process.Spawn.Actions
        ) throws -> UInt {
            var commandLine: [WCHAR] = Array(command.utf16)
            commandLine.append(0)
            let executable: [WCHAR] = Array(#"C:\Windows\System32\cmd.exe"#.utf16) + [0]

            var spawned: Windows.`32`.Kernel.Process.Spawn.Result?
            try unsafe executable.withUnsafeBufferPointer { exePtr in
                try unsafe commandLine.withUnsafeMutableBufferPointer { cmdPtr in
                    spawned = try unsafe Windows.`32`.Kernel.Process.Spawn.spawn(
                        executable: exePtr.baseAddress,
                        commandLine: cmdPtr.baseAddress!,
                        environment: nil,
                        workingDirectory: nil,
                        actions: actions
                    )
                }
            }
            guard let result = consume spawned else {
                throw NoResult()
            }
            let process = unsafe duplicate(result.processHandle._rawValue)
            _ = consume result
            return process
        }

        static func isBroken(_ readHandle: UInt) -> Bool {
            guard let handle = unsafe UnsafeMutableRawPointer(bitPattern: readHandle) else {
                return false
            }
            var available: DWORD = 0
            let peeked = unsafe PeekNamedPipe(handle, nil, 0, nil, &available, nil)
            return !peeked && unsafe GetLastError() == ERROR_BROKEN_PIPE
        }

        static func drain(_ readHandle: UInt) -> [UInt8] {
            guard let handle = unsafe UnsafeMutableRawPointer(bitPattern: readHandle) else {
                return []
            }
            var buffer: [UInt8] = []
            var chunk = [UInt8](repeating: 0, count: 4096)
            while true {
                var bytesRead: DWORD = 0
                let success = unsafe chunk.withUnsafeMutableBufferPointer { ptr in
                    ReadFile(handle, ptr.baseAddress, DWORD(ptr.count), &bytesRead, nil)
                }
                guard success, bytesRead > 0 else { break }
                buffer.append(contentsOf: chunk.prefix(Int(bytesRead)))
            }
            return buffer
        }

        static func duplicate(_ processHandle: UInt) -> UInt {
            var duplicate: HANDLE? = nil
            let source = unsafe UnsafeMutableRawPointer(bitPattern: processHandle)
            _ = unsafe DuplicateHandle(
                GetCurrentProcess(),
                source,
                GetCurrentProcess(),
                &duplicate,
                0,
                false,
                DWORD(DUPLICATE_SAME_ACCESS)
            )
            return UInt(bitPattern: duplicate)
        }

        static func terminate(_ processHandle: UInt) {
            guard let handle = unsafe UnsafeMutableRawPointer(bitPattern: processHandle) else {
                return
            }
            _ = unsafe TerminateProcess(handle, 0)
            _ = unsafe WaitForSingleObject(handle, 10_000)
            _ = unsafe CloseHandle(handle)
        }
    }

#endif
