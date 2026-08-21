#if os(Windows)
    public import WinSDK

    extension System {

        public static var pathMax: System.Path.Length {
            System.Path.Length(_unchecked: Cardinal(UInt(260)))
        }

        public static var pageSize: System.Page.Size {
            var sysInfo = SYSTEM_INFO()
            GetSystemInfo(&sysInfo)
            return System.Page.Size(_unchecked: Cardinal(UInt(sysInfo.dwPageSize)))
        }

        public static var processorCount: System.Processor.Count {
            var sysInfo = SYSTEM_INFO()
            GetSystemInfo(&sysInfo)
            return System.Processor.Count(_unchecked: Cardinal(UInt(sysInfo.dwNumberOfProcessors)))
        }

        @inlinable
        public static func sleep(_ duration: Duration) {
            let (seconds, attoseconds) = duration.components
            let totalMs = seconds * 1000 + attoseconds / 1_000_000_000_000_000
            Sleep(DWORD(min(totalMs, Int64(DWORD.max))))
        }
    }

#endif
