public import System
#if os(Windows)
    public import WinSDK

    extension System {

        public static var pathMax: System.Path.Length {
            System.Path.Length(_unchecked: Cardinal(UInt(260)))
        }

        public static var pageSize: Int {
            var sysInfo = SYSTEM_INFO()
            GetSystemInfo(&sysInfo)
            guard let result = Int(exactly: sysInfo.dwPageSize) else {
                preconditionFailure("Platform page size is not representable as Int")
            }
            return result
        }

        public static var processorCount: Int {
            var sysInfo = SYSTEM_INFO()
            GetSystemInfo(&sysInfo)
            guard let result = Int(exactly: sysInfo.dwNumberOfProcessors) else {
                preconditionFailure("Processor count is not representable as Int")
            }
            return result
        }

        @inlinable
        public static func sleep(_ duration: Duration) {
            let (seconds, attoseconds) = duration.components
            let totalMs = seconds * 1000 + attoseconds / 1_000_000_000_000_000
            Sleep(DWORD(min(totalMs, Int64(DWORD.max))))
        }
    }

#endif
