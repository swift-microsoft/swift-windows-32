#if os(Windows)
    internal import WinSDK

    extension Windows.`32`.Kernel.Process {
        public struct Job: ~Copyable, Sendable {
            private let descriptor: Windows.`32`.Kernel.Descriptor

            public init() throws(Windows.`32`.Kernel.Process.Error) {
                guard let handle = unsafe CreateJobObjectW(nil, nil) else {
                    throw .create(.win32(unsafe GetLastError()))
                }
                descriptor = Windows.`32`.Kernel.Descriptor(_raw: UInt(bitPattern: handle))
            }
        }
    }

    extension Windows.`32`.Kernel.Process.Job {
        public func limit(_ limits: Limit) throws(Windows.`32`.Kernel.Process.Error) {
            var information = JOBOBJECT_EXTENDED_LIMIT_INFORMATION()
            information.BasicLimitInformation.LimitFlags = limits.rawValue
            let handle = unsafe HANDLE(bitPattern: descriptor._raw)
            guard
                unsafe SetInformationJobObject(
                    handle,
                    JobObjectExtendedLimitInformation,
                    &information,
                    UInt32(MemoryLayout<JOBOBJECT_EXTENDED_LIMIT_INFORMATION>.size)
                )
            else {
                throw .create(.win32(unsafe GetLastError()))
            }
        }

        public func assign(
            _ process: borrowing Windows.`32`.Kernel.Descriptor
        ) throws(Windows.`32`.Kernel.Process.Error) {
            guard process.isValid else {
                throw .create(.win32(UInt32(ERROR_INVALID_HANDLE)))
            }
            let handle = unsafe HANDLE(bitPattern: descriptor._raw)
            let child = unsafe HANDLE(bitPattern: process._raw)
            guard unsafe AssignProcessToJobObject(handle, child) else {
                throw .create(.win32(unsafe GetLastError()))
            }
        }

        public func terminate(code: UInt32) throws(Windows.`32`.Kernel.Process.Error) {
            let handle = unsafe HANDLE(bitPattern: descriptor._raw)
            guard unsafe TerminateJobObject(handle, code) else {
                throw .wait(.win32(unsafe GetLastError()))
            }
        }
    }
#endif
