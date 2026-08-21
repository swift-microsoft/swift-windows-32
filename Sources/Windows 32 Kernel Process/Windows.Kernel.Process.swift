#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.Process {

        @inlinable
        public static func getCurrentId() -> UInt32 {
            GetCurrentProcessId()
        }

        @inlinable
        package static func getCurrentHandle() -> HANDLE {
            GetCurrentProcess()
        }

        package static func terminate(handle: HANDLE, exitCode: UInt32) -> Bool {
            TerminateProcess(handle, exitCode)
        }

        package static func getExitCode(handle: HANDLE) -> UInt32? {
            var exitCode: DWORD = 0
            guard GetExitCodeProcess(handle, &exitCode) else {
                return nil
            }

            if exitCode == DWORD(STILL_ACTIVE) {
                return nil
            }
            return exitCode
        }

        package static func wait(handle: HANDLE, timeout: DWORD = DWORD(INFINITE)) -> DWORD {
            WaitForSingleObject(handle, timeout)
        }
    }

    extension Windows.`32`.Kernel.Process {

        public struct Info {

            package let processHandle: HANDLE

            package let threadHandle: HANDLE

            public let processId: UInt32

            public let threadId: UInt32
        }
    }

    extension Windows.`32`.Kernel.Process.Info {

        public func close() {
            _ = CloseHandle(processHandle)
            _ = CloseHandle(threadHandle)
        }
    }

    extension Windows.`32`.Kernel.Process {

        public static func create(
            applicationName: UnsafePointer<WCHAR>? = nil,
            commandLine: UnsafeMutablePointer<WCHAR>,
            inheritHandles: Bool = false,
            creationFlags: DWORD = 0,
            environment: UnsafeMutableRawPointer? = nil,
            currentDirectory: UnsafePointer<WCHAR>? = nil
        ) throws(Error) -> Info {
            var startupInfo = STARTUPINFOW()
            startupInfo.cb = DWORD(MemoryLayout<STARTUPINFOW>.size)

            var processInfo = PROCESS_INFORMATION()

            let success = CreateProcessW(
                applicationName,
                commandLine,
                nil,
                nil,
                inheritHandles,
                creationFlags,
                environment,
                currentDirectory,
                &startupInfo,
                &processInfo
            )

            guard success else {
                throw .create(Error_Primitives.Error.captureLastError())
            }

            return Info(
                processHandle: processInfo.hProcess,
                threadHandle: processInfo.hThread,
                processId: processInfo.dwProcessId,
                threadId: processInfo.dwThreadId
            )
        }

        public static func create(
            commandLine: UnsafeMutablePointer<WCHAR>,
            startupInfo: inout STARTUPINFOW,
            inheritHandles: Bool = true,
            creationFlags: DWORD = 0
        ) throws(Error) -> Info {
            var processInfo = PROCESS_INFORMATION()

            let success = CreateProcessW(
                nil,
                commandLine,
                nil,
                nil,
                inheritHandles,
                creationFlags,
                nil,
                nil,
                &startupInfo,
                &processInfo
            )

            guard success else {
                throw .create(Error_Primitives.Error.captureLastError())
            }

            return Info(
                processHandle: processInfo.hProcess,
                threadHandle: processInfo.hThread,
                processId: processInfo.dwProcessId,
                threadId: processInfo.dwThreadId
            )
        }
    }

#endif
