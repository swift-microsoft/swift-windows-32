#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.Thread {

        /// Suspends the calling thread for `duration`, rounded down to milliseconds, `Sleep`.
        @inlinable
        public static func sleep(_ duration: Duration) {
            guard duration > .zero else {
                Sleep(0)
                return
            }
            let (seconds, attoseconds) = duration.components
            let milliseconds = seconds * 1000 + attoseconds / 1_000_000_000_000_000
            Sleep(DWORD(min(milliseconds, Int64(DWORD.max))))
        }
    }

#endif
