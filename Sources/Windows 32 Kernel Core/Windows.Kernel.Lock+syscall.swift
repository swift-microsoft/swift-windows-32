// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-32 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows-32 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Error_Primitives

#if os(Windows)
    internal import WinSDK
#endif

// MARK: - Win32 File Locking

extension Windows.`32`.Kernel.Lock {
    /// Acquires a lock on a byte range (blocking) using a typed descriptor.
    ///
    /// Wraps `LockFileEx` without `LOCKFILE_FAIL_IMMEDIATELY`, which blocks
    /// the calling thread until the lock is available.
    ///
    /// - Parameters:
    ///   - descriptor: The file handle.
    ///   - range: The byte range to lock.
    ///   - kind: The lock kind (shared or exclusive).
    /// - Throws: `Error.invalidRange` if the range's end precedes its start,
    ///           `Error.platform` (or the mapped case) for any other failure.
    public static func lock(
        _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
        range: Windows.`32`.Kernel.Lock.Range,
        kind: Windows.`32`.Kernel.Lock.Kind
    ) throws(Windows.`32`.Kernel.Lock.Error) {
        #if os(Windows)
            guard try validate(range) else { return }  // empty range locks nothing
            var overlapped = OVERLAPPED()
            let (offsetLow, offsetHigh, lengthLow, lengthHigh) = lockParameters(range: range)
            overlapped.Offset = offsetLow
            overlapped.OffsetHigh = offsetHigh

            var flags: DWORD = 0
            if kind == .exclusive {
                flags |= DWORD(LOCKFILE_EXCLUSIVE_LOCK)
            }

            guard let handle = UnsafeMutableRawPointer(bitPattern: descriptor._rawValue) else {
                throw Windows.`32`.Kernel.Lock.Error(Error_Primitives.Error.captureLastError())
            }
            guard unsafe LockFileEx(handle, flags, 0, lengthLow, lengthHigh, &overlapped) else {
                throw Windows.`32`.Kernel.Lock.Error(Error_Primitives.Error.captureLastError())
            }
        #endif
    }

    /// Releases a lock on a byte range using a typed descriptor.
    ///
    /// Wraps `UnlockFileEx`.
    ///
    /// - Parameters:
    ///   - descriptor: The file handle.
    ///   - range: The byte range to unlock.
    /// - Throws: `Error` if unlocking fails.
    public static func unlock(
        _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
        range: Windows.`32`.Kernel.Lock.Range
    ) throws(Windows.`32`.Kernel.Lock.Error) {
        #if os(Windows)
            guard try validate(range) else { return }  // empty range unlocks nothing
            var overlapped = OVERLAPPED()
            let (offsetLow, offsetHigh, lengthLow, lengthHigh) = lockParameters(range: range)
            overlapped.Offset = offsetLow
            overlapped.OffsetHigh = offsetHigh

            guard let handle = UnsafeMutableRawPointer(bitPattern: descriptor._rawValue) else {
                throw Windows.`32`.Kernel.Lock.Error(Error_Primitives.Error.captureLastError())
            }
            guard unsafe UnlockFileEx(handle, 0, lengthLow, lengthHigh, &overlapped) else {
                throw Windows.`32`.Kernel.Lock.Error(Error_Primitives.Error.captureLastError())
            }
        #endif
    }

    /// Validates a byte range.
    ///
    /// - Returns: `false` for an empty range (which locks/unlocks nothing),
    ///   `true` otherwise.
    /// - Throws: `Error.invalidRange` when the end precedes the start.
    static func validate(_ range: Windows.`32`.Kernel.Lock.Range) throws(Windows.`32`.Kernel.Lock.Error) -> Bool {
        guard case .bytes(let start, let end) = range else { return true }
        if end.underlying < start.underlying {
            throw .invalidRange(start: start.underlying, end: end.underlying)
        }
        return end.underlying != start.underlying
    }

    #if os(Windows)
        /// Splits a lock range into the `(offset, length)` DWORD pairs
        /// `LockFileEx`/`UnlockFileEx` require.
        ///
        /// `.file` locks the maximal representable range (both length
        /// `DWORD`s `0xFFFFFFFF`) starting at offset zero — the established
        /// Win32 idiom for "lock the whole file including future growth",
        /// since Windows has no POSIX-style `l_len == 0` sentinel.
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

// MARK: - Immediate (Non-blocking)

extension Windows.`32`.Kernel.Lock {
    /// Non-blocking lock operations.
    public enum Immediate {}
}

extension Windows.`32`.Kernel.Lock.Immediate {
    /// Attempts to acquire a lock without blocking, using a typed descriptor.
    ///
    /// Wraps `LockFileEx` with `LOCKFILE_FAIL_IMMEDIATELY`.
    ///
    /// - Parameters:
    ///   - descriptor: The file handle.
    ///   - range: The byte range to lock.
    ///   - kind: The lock kind (shared or exclusive).
    /// - Throws: `Error.contention` if the lock is held by another process
    ///           (`ERROR_LOCK_VIOLATION`), or the mapped case for any other failure.
    public static func lock(
        _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
        range: Windows.`32`.Kernel.Lock.Range,
        kind: Windows.`32`.Kernel.Lock.Kind
    ) throws(Windows.`32`.Kernel.Lock.Error) {
        #if os(Windows)
            guard try Windows.`32`.Kernel.Lock.validate(range) else { return }  // empty range locks nothing
            var overlapped = OVERLAPPED()
            let (offsetLow, offsetHigh, lengthLow, lengthHigh) = Windows.`32`.Kernel.Lock.lockParameters(range: range)
            overlapped.Offset = offsetLow
            overlapped.OffsetHigh = offsetHigh

            var flags: DWORD = DWORD(LOCKFILE_FAIL_IMMEDIATELY)
            if kind == .exclusive {
                flags |= DWORD(LOCKFILE_EXCLUSIVE_LOCK)
            }

            guard let handle = UnsafeMutableRawPointer(bitPattern: descriptor._rawValue) else {
                throw Windows.`32`.Kernel.Lock.Error(Error_Primitives.Error.captureLastError())
            }
            guard unsafe LockFileEx(handle, flags, 0, lengthLow, lengthHigh, &overlapped) else {
                throw Windows.`32`.Kernel.Lock.Error(Error_Primitives.Error.captureLastError())
            }
        #endif
    }
}
