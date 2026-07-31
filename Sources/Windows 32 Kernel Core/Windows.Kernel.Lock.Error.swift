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

extension Windows.`32`.Kernel.Lock {
    /// Lock operation errors.
    ///
    /// Type shape mirrors `ISO_9945.Kernel.Lock.Error` exactly (the cross-platform
    /// contract); the Win32 code mapping lives in `Windows.Kernel.Lock.Error+code`.
    ///
    /// Two POSIX-side cases have no Win32 analogue and are never produced by
    /// `init(code:)` on this platform: Win32 file locking has no deadlock
    /// detector (`.deadlock` is kept only for cross-platform case parity),
    /// and a blocking `LockFileEx` wait is not interruptible by a POSIX-style
    /// signal (`.interrupted` is likewise never thrown here). Both stay real,
    /// non-aliased cases so cross-platform callers can exhaustively switch
    /// over `ISO_9945.Kernel.Lock.Error`-shaped vocabulary without a
    /// platform-conditional case set.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// Lock contention — another process holds a conflicting lock
        /// (`ERROR_LOCK_VIOLATION`). Only surfaced for non-blocking acquisition.
        case contention

        /// Deadlock detected by the kernel.
        ///
        /// Win32 file locking has no deadlock detector; this case is never
        /// produced by `init(code:)` on Windows.
        case deadlock

        /// No locks available — the system lock table is exhausted.
        case unavailable

        /// Lock acquisition timed out.
        ///
        /// Thrown when `.deadline(...)` acquisition cannot acquire the lock
        /// before the deadline expires. Distinct from ``contention``: the
        /// lock may or may not still be held when the deadline expires.
        case timedOut

        /// The blocking lock wait was interrupted.
        ///
        /// Win32 `LockFileEx`'s blocking wait is not interruptible by a
        /// POSIX-style signal; this case is never produced by `init(code:)`
        /// on Windows and exists for cross-platform case parity.
        case interrupted

        /// The requested byte range is invalid (end precedes start).
        case invalidRange(start: Int64, end: Int64)

        /// A platform error the lock vocabulary does not classify.
        ///
        /// Carries the platform code so a misuse code (`ERROR_INVALID_HANDLE`,
        /// `ERROR_INVALID_PARAMETER`, …) stays distinguishable from contention.
        case platform(code: Error_Primitives.Error.Code)
    }
}

extension Windows.`32`.Kernel.Lock.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .contention: return "lock contention"
        case .deadlock: return "deadlock detected"
        case .unavailable: return "no locks available"
        case .timedOut: return "lock acquisition timed out"
        case .interrupted: return "lock wait interrupted"
        case .invalidRange(let start, let end): return "invalid lock range: start \(start), end \(end)"
        case .platform(let code): return "platform error \(code)"
        }
    }
}

extension Windows.`32`.Kernel.Lock.Error {
    /// Lock would block, for non-blocking acquisition (semantically reuses
    /// `.contention`: `LOCKFILE_FAIL_IMMEDIATELY` surfaces the same
    /// `ERROR_LOCK_VIOLATION` code as blocking contention on Windows).
    public static let wouldBlock = Self.contention
}
