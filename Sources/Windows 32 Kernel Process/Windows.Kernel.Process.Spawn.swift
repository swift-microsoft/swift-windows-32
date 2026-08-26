#if os(Windows)
    public import WinSDK
    public import Path
#endif

extension Windows.`32`.Kernel.Process {

    public enum Spawn: Sendable {}
}

extension Windows.`32`.Kernel.Process.Spawn {

    public struct Result: ~Copyable, Sendable {

        public let processHandle: Windows.`32`.Kernel.Descriptor

        public let threadHandle: Windows.`32`.Kernel.Descriptor

        public let processID: UInt32

        public let threadID: UInt32

        @inlinable
        public init(
            processHandle: consuming Windows.`32`.Kernel.Descriptor,
            threadHandle: consuming Windows.`32`.Kernel.Descriptor,
            processID: UInt32,
            threadID: UInt32
        ) {
            self.processHandle = processHandle
            self.threadHandle = threadHandle
            self.processID = processID
            self.threadID = threadID
        }
    }
}

#if os(Windows)

    extension Windows.`32`.Kernel.Process.Spawn {

        @unsafe
        public static func spawn(
            executable: UnsafePointer<WCHAR>?,
            commandLine: UnsafeMutablePointer<WCHAR>,
            environment: UnsafeMutableRawPointer?,
            workingDirectory: UnsafePointer<WCHAR>?,
            actions: borrowing Actions
        ) throws(Windows.`32`.Kernel.Process.Error) -> Result {
            var startupInfo = STARTUPINFOEXW()
            startupInfo.StartupInfo.cb = DWORD(MemoryLayout<STARTUPINFOEXW>.size)
            startupInfo.lpAttributeList = unsafe actions._attributeList

            if let handles = unsafe actions._stdioHandles {
                unsafe startupInfo.StartupInfo.dwFlags |= DWORD(STARTF_USESTDHANDLES)
                unsafe startupInfo.StartupInfo.hStdInput = handles.stdin
                unsafe startupInfo.StartupInfo.hStdOutput = handles.stdout
                unsafe startupInfo.StartupInfo.hStdError = handles.stderr
            }

            var processInfo = PROCESS_INFORMATION()

            let creationFlags: DWORD = DWORD(
                CREATE_UNICODE_ENVIRONMENT | EXTENDED_STARTUPINFO_PRESENT
            )

            let success = unsafe withUnsafePointer(to: &startupInfo.StartupInfo) {
                (siPtr: UnsafePointer<STARTUPINFOW>) -> Bool in
                let mutableSI = unsafe UnsafeMutablePointer(mutating: siPtr)
                return unsafe CreateProcessW(
                    executable,
                    commandLine,
                    nil,
                    nil,
                    true,
                    creationFlags,
                    environment,
                    workingDirectory,
                    mutableSI,
                    &processInfo
                )
            }

            guard success else {
                throw .create(Error.Error.captureLastError())
            }

            return Result(
                processHandle: Windows.`32`.Kernel.Descriptor(
                    _raw: UInt(bitPattern: processInfo.hProcess)
                ),
                threadHandle: Windows.`32`.Kernel.Descriptor(
                    _raw: UInt(bitPattern: processInfo.hThread)
                ),
                processID: processInfo.dwProcessId,
                threadID: processInfo.dwThreadId
            )
        }
    }

#endif
