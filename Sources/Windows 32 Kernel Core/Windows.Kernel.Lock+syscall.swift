public import Error

#if os(Windows)
    internal import Space
    internal import WinSDK
#endif

extension Windows.`32`.Kernel.Lock {

    public static func lock(
        _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
        range: Windows.`32`.Kernel.Lock.Range,
        kind: Windows.`32`.Kernel.Lock.Kind
    ) throws(Windows.`32`.Kernel.Lock.Error) {
        #if os(Windows)
            guard try validate(range) else { return }
            var overlapped = OVERLAPPED()
            let (offsetLow, offsetHigh, lengthLow, lengthHigh) = lockParameters(range: range)
            overlapped.Offset = offsetLow
            overlapped.OffsetHigh = offsetHigh

            var flags: DWORD = 0
            if kind == .exclusive {
                flags |= DWORD(LOCKFILE_EXCLUSIVE_LOCK)
            }

            guard let handle = UnsafeMutableRawPointer(bitPattern: descriptor._rawValue) else {
                throw Windows.`32`.Kernel.Lock.Error(Error::Error.captureLastError())
            }
            guard unsafe LockFileEx(handle, flags, 0, lengthLow, lengthHigh, &overlapped) else {
                throw Windows.`32`.Kernel.Lock.Error(Error::Error.captureLastError())
            }
        #endif
    }

    public static func unlock(
        _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
        range: Windows.`32`.Kernel.Lock.Range
    ) throws(Windows.`32`.Kernel.Lock.Error) {
        #if os(Windows)
            guard try validate(range) else { return }
            var overlapped = OVERLAPPED()
            let (offsetLow, offsetHigh, lengthLow, lengthHigh) = lockParameters(range: range)
            overlapped.Offset = offsetLow
            overlapped.OffsetHigh = offsetHigh

            guard let handle = UnsafeMutableRawPointer(bitPattern: descriptor._rawValue) else {
                throw Windows.`32`.Kernel.Lock.Error(Error::Error.captureLastError())
            }
            guard unsafe UnlockFileEx(handle, 0, lengthLow, lengthHigh, &overlapped) else {
                throw Windows.`32`.Kernel.Lock.Error(Error::Error.captureLastError())
            }
        #endif
    }

    static func validate(
        _ range: Windows.`32`.Kernel.Lock.Range
    ) throws(Windows.`32`.Kernel.Lock.Error) -> Bool {
        guard case .bytes(let start, let end) = range else { return true }
        if end.underlying < start.underlying {
            throw .invalidRange(start: start.underlying, end: end.underlying)
        }
        return end.underlying != start.underlying
    }

    #if os(Windows)

        static func lockParameters(
            range: Windows.`32`.Kernel.Lock.Range
        ) -> (offsetLow: DWORD, offsetHigh: DWORD, lengthLow: DWORD, lengthHigh: DWORD) {
            switch range {
            case .file:
                return (0, 0, 0xFFFF_FFFF, 0xFFFF_FFFF)

            case .bytes(let start, let end):
                let offset = UInt64(bitPattern: start.underlying)
                let length = UInt64(bitPattern: (end - start).underlying)
                return (
                    DWORD(truncatingIfNeeded: offset),
                    DWORD(truncatingIfNeeded: offset >> 32),
                    DWORD(truncatingIfNeeded: length),
                    DWORD(truncatingIfNeeded: length >> 32)
                )
            }
        }
    #endif
}

extension Windows.`32`.Kernel.Lock {

    public enum Immediate {}
}

extension Windows.`32`.Kernel.Lock.Immediate {

    public static func lock(
        _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
        range: Windows.`32`.Kernel.Lock.Range,
        kind: Windows.`32`.Kernel.Lock.Kind
    ) throws(Windows.`32`.Kernel.Lock.Error) {
        #if os(Windows)

            guard try Windows.`32`.Kernel.Lock.validate(range) else { return }
            var overlapped = OVERLAPPED()
            let (offsetLow, offsetHigh, lengthLow, lengthHigh) = Windows.`32`.Kernel.Lock
                .lockParameters(range: range)
            overlapped.Offset = offsetLow
            overlapped.OffsetHigh = offsetHigh

            var flags: DWORD = DWORD(LOCKFILE_FAIL_IMMEDIATELY)
            if kind == .exclusive {
                flags |= DWORD(LOCKFILE_EXCLUSIVE_LOCK)
            }

            guard let handle = UnsafeMutableRawPointer(bitPattern: descriptor._rawValue) else {
                throw Windows.`32`.Kernel.Lock.Error(Error::Error.captureLastError())
            }
            guard unsafe LockFileEx(handle, flags, 0, lengthLow, lengthHigh, &overlapped) else {
                throw Windows.`32`.Kernel.Lock.Error(Error::Error.captureLastError())
            }
        #endif
    }
}
