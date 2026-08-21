#if os(Windows)
    public import WinSDK
    internal import Windows_32_Kernel_Clock

    extension Windows.`32`.Kernel.Time {

        package static func systemTime() -> FILETIME {
            var fileTime = FILETIME()
            GetSystemTimeAsFileTime(&fileTime)
            return fileTime
        }

        package static func systemTimeRaw() -> UInt64 {
            var fileTime = FILETIME()
            GetSystemTimeAsFileTime(&fileTime)
            return UInt64(fileTime.dwHighDateTime) << 32 | UInt64(fileTime.dwLowDateTime)
        }

        public static func realtime() -> Windows.`32`.Kernel.Time {

            let windowsEpochDiff: UInt64 = 116_444_736_000_000_000
            let intervals = systemTimeRaw()
            let sinceUnix = intervals - windowsEpochDiff
            return Windows.`32`.Kernel.Time(
                _unchecked: (),
                secondsSinceUnixEpoch: Int64(sinceUnix / 10_000_000),
                nanosecondFraction: Int32(sinceUnix % 10_000_000) * 100
            )
        }
    }

#endif
