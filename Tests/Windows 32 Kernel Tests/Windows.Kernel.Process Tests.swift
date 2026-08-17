// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-32 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-windows-32 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error_Primitives
    import Path_Primitives
    import Clock_Primitives
    import Random_Primitives
    import System_Primitives

    extension Windows.`32`.Kernel.Process {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Namespace Tests

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

    // MARK: - Current Process Tests

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

    // MARK: - Error Tests

    extension Windows.`32`.Kernel.Process.Test.Unit {
        @Test
        func `Error.create exists`() {
            let error = Windows.`32`.Kernel.Process.Error.create(.win32(0))
            if case .create = error {
                // Expected
            } else {
                Issue.record("Expected .create, got \(error)")
            }
        }

        @Test
        func `Error.wait exists`() {
            let error = Windows.`32`.Kernel.Process.Error.wait(.win32(0))
            if case .wait = error {
                // Expected
            } else {
                Issue.record("Expected .wait, got \(error)")
            }
        }
    }

    // MARK: - Spawn Integration

    extension Windows.`32`.Kernel.Process.Test.Integration {
        /// Regression for #18: marking a SECOND handle inheritable must
        /// rewire `PROC_THREAD_ATTRIBUTE_HANDLE_LIST` successfully.
        ///
        /// The attribute list holds room for exactly one attribute and
        /// `UpdateProcThreadAttribute` appends rather than replaces, so
        /// before the fix the second ``markHandleInheritable(_:)`` call
        /// failed with `ERROR_GEN_FAILURE` (win32 error 31) — the shape
        /// every consumer spawning with both stdout and stderr piped hits
        /// (swift-process#6; observed fleet-wide via swift-git's client,
        /// which pipes both streams on every invocation).
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

    // MARK: - Edge Cases

    extension Windows.`32`.Kernel.Process.Test.EdgeCase {
        @Test
        func `getCurrentId is consistent`() {
            let pid1 = Windows.`32`.Kernel.Process.getCurrentId()
            let pid2 = Windows.`32`.Kernel.Process.getCurrentId()
            #expect(pid1 == pid2)
        }

        @Test
        func `Info has expected properties`() {
            // Type check only
            _ = \Windows.`32`.Kernel.Process.Info.processHandle
            _ = \Windows.`32`.Kernel.Process.Info.threadHandle
            _ = \Windows.`32`.Kernel.Process.Info.processId
            _ = \Windows.`32`.Kernel.Process.Info.threadId
        }
    }

#endif
