#if os(Windows)
    public import WinSDK

    extension Clock.Continuous {

        @inlinable
        public static var now: Clock.Continuous.Instant {
            var counter = LARGE_INTEGER()
            var frequency = LARGE_INTEGER()
            QueryPerformanceCounter(&counter)
            QueryPerformanceFrequency(&frequency)

            let counterValue = UInt64(bitPattern: counter.QuadPart)
            let frequencyValue = UInt64(bitPattern: frequency.QuadPart)

            let seconds = counterValue / frequencyValue
            let remainder = counterValue % frequencyValue

            let ns = seconds * 1_000_000_000 + (remainder * 1_000_000_000) / frequencyValue
            return Clock.Continuous.Instant(nanoseconds: ns)
        }
    }

    extension Clock.Suspending {

        @inlinable
        public static var now: Clock.Suspending.Instant {
            var unbiasedTime: ULONGLONG = 0
            QueryUnbiasedInterruptTime(&unbiasedTime)

            let ns = UInt64(unbiasedTime) * 100
            return Clock.Suspending.Instant(nanoseconds: ns)
        }
    }

#endif
