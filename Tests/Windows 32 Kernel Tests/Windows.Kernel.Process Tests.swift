#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error
    import Path
    import Clock
    import Random
    import System

    extension Windows.`32`.Kernel.Process {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Windows.`32`.Kernel.Process.Test.Unit {
        @Test
        func `Process namespace exists`() {
            _ = Windows.`32`.Kernel.Process.self
        }

        @Test
        func `Process.Error type exists`() {
            _ = Windows.`32`.Kernel.Process.Error.self
        }

        @Test
        func `Process.Info type exists`() {
            _ = Windows.`32`.Kernel.Process.Info.self
        }
    }

    extension Windows.`32`.Kernel.Process.Test.Unit {
        @Test
        func `getCurrentId returns non-zero`() {
            let pid = Windows.`32`.Kernel.Process.getCurrentId()
            #expect(pid > 0)
        }

        @Test
        func `getCurrentId matches GetCurrentProcessId`() {
            let pid = Windows.`32`.Kernel.Process.getCurrentId()
            let win32Pid = GetCurrentProcessId()
            #expect(pid == win32Pid)
        }

        @Test
        func `getCurrentHandle returns non-nil`() {
            let handle = Windows.`32`.Kernel.Process.getCurrentHandle()
            #expect(handle != nil)
        }
    }

    extension Windows.`32`.Kernel.Process.Test.Unit {
        @Test
        func `Error.create exists`() {
            let error = Windows.`32`.Kernel.Process.Error.create(.win32(0))
            if case .create = error {

            } else {
                Issue.record("Expected .create, got \(error)")
            }
        }

        @Test
        func `Error.wait exists`() {
            let error = Windows.`32`.Kernel.Process.Error.wait(.win32(0))
            if case .wait = error {

            } else {
                Issue.record("Expected .wait, got \(error)")
            }
        }
    }

    extension Windows.`32`.Kernel.Process.Test.Integration {

        @Test
        func `spawn succeeds with two inheritable stdio handles`() throws {
            var actions = try Windows.`32`.Kernel.Process.Spawn.Actions()
            let stdoutPipe = try Windows.`32`.Kernel.Pipe.pipe()
            let stderrPipe = try Windows.`32`.Kernel.Pipe.pipe()

            try actions.markHandleInheritable(stdoutPipe.write)
            try actions.markHandleInheritable(stderrPipe.write)
            actions.setStdout(stdoutPipe.write)
            actions.setStderr(stderrPipe.write)

            var commandLine: [WCHAR] = Array("cmd.exe /C exit 0".utf16)
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
                Issue.record("spawn produced no result")
                return
            }

            let processHandle = unsafe UnsafeMutableRawPointer(
                bitPattern: result.processHandle._rawValue
            )
            #expect(processHandle != nil)
            if let processHandle {
                let waited = unsafe WaitForSingleObject(processHandle, 10_000)
                #expect(waited == WAIT_OBJECT_0)
            }
        }
    }

    extension Windows.`32`.Kernel.Process.Test.EdgeCase {
        @Test
        func `getCurrentId is consistent`() {
            let pid1 = Windows.`32`.Kernel.Process.getCurrentId()
            let pid2 = Windows.`32`.Kernel.Process.getCurrentId()
            #expect(pid1 == pid2)
        }

        @Test
        func `Info has expected properties`() {

            _ = \Windows.`32`.Kernel.Process.Info.processHandle
            _ = \Windows.`32`.Kernel.Process.Info.threadHandle
            _ = \Windows.`32`.Kernel.Process.Info.processId
            _ = \Windows.`32`.Kernel.Process.Info.threadId
        }
    }

#endif
