#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.Thread {

        public final class Condition: @unchecked Sendable {
            private var cond: CONDITION_VARIABLE

            public init() {
                self.cond = CONDITION_VARIABLE()
                InitializeConditionVariable(&self.cond)
            }

        }
    }

    extension Windows.`32`.Kernel.Thread.Condition {

        public func wait(mutex: Windows.`32`.Kernel.Thread.Mutex) {
            _ = mutex.withUnsafeMutablePointer { mutexPtr in
                SleepConditionVariableSRW(&cond, mutexPtr, INFINITE, 0)
            }
        }

        public func wait(mutex: Windows.`32`.Kernel.Thread.Mutex, timeout: Duration) -> Bool {
            mutex.withUnsafeMutablePointer { mutexPtr in
                let (seconds, attoseconds) = timeout.components
                let totalMs = seconds * 1000 + attoseconds / 1_000_000_000_000_000
                let ms = DWORD(min(totalMs, Int64(DWORD.max - 1)))

                return SleepConditionVariableSRW(&cond, mutexPtr, ms, 0)
            }
        }

        package func wait(mutex: Windows.`32`.Kernel.Thread.Mutex, milliseconds: DWORD) -> Bool {
            mutex.withUnsafeMutablePointer { mutexPtr in
                SleepConditionVariableSRW(&cond, mutexPtr, milliseconds, 0)
            }
        }
    }

    extension Windows.`32`.Kernel.Thread.Condition {

        public func signal() {
            WakeConditionVariable(&cond)
        }

        public func broadcast() {
            WakeAllConditionVariable(&cond)
        }
    }

#endif
