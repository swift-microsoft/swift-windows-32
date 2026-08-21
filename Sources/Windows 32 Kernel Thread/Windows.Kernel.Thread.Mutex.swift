#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.Thread {

        public final class Mutex: @unchecked Sendable {
            private var srwlock: SRWLOCK

            public init() {
                self.srwlock = SRWLOCK()
                InitializeSRWLock(&self.srwlock)
            }

        }
    }

    extension Windows.`32`.Kernel.Thread.Mutex {

        public func unlock() {
            ReleaseSRWLockExclusive(&srwlock)
        }

        public var lock: Lock { Lock(mutex: self) }
    }

    extension Windows.`32`.Kernel.Thread.Mutex {

        public struct Lock: Sendable {
            let mutex: Windows.`32`.Kernel.Thread.Mutex
        }

        fileprivate func acquireBlocking() {
            AcquireSRWLockExclusive(&srwlock)
        }

        public func withLock<T, E: Swift.Error>(_ body: () throws(E) -> T) throws(E) -> T {
            lock()
            defer { unlock() }
            return try body()
        }
    }

    extension Windows.`32`.Kernel.Thread.Mutex.Lock {

        public enum Error: Swift.Error, Sendable {

            case contention
        }

        public func callAsFunction() {
            mutex.acquireBlocking()
        }

        public func immediate() throws(Error) {
            guard TryAcquireSRWLockExclusive(&mutex.srwlock) != 0 else {
                throw .contention
            }
        }
    }

    extension Windows.`32`.Kernel.Thread.Mutex {

        func withUnsafeMutablePointer<T>(_ body: (UnsafeMutablePointer<SRWLOCK>) -> T) -> T {
            Swift.withUnsafeMutablePointer(to: &srwlock, body)
        }
    }

#endif
