#if os(Windows)
    public import Error_Primitives
    public import Memory_Primitives
    public import WinSDK

    extension Memory.Lock {

        @unsafe
        public static func lock(
            address: UnsafeRawPointer,
            length: Memory.Address.Count
        ) throws(Memory.Lock.Error) {
            guard
                VirtualLock(
                    UnsafeMutableRawPointer(mutating: address),
                    SIZE_T(length.underlying.rawValue)
                )
            else {
                throw .lock(Error_Primitives.Error.captureLastError())
            }
        }

        @unsafe
        public static func unlock(
            address: UnsafeRawPointer,
            length: Memory.Address.Count
        ) throws(Memory.Lock.Error) {
            guard
                VirtualUnlock(
                    UnsafeMutableRawPointer(mutating: address),
                    SIZE_T(length.underlying.rawValue)
                )
            else {
                throw .unlock(Error_Primitives.Error.captureLastError())
            }
        }
    }

#endif
