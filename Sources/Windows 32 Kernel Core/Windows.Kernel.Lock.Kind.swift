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
    /// Lock type determining concurrency behavior.
    ///
    /// Mirrors `ISO_9945.Kernel.Lock.Kind` in shape. `LockFileEx` gives
    /// reader-writer semantics via `LOCKFILE_EXCLUSIVE_LOCK`: multiple
    /// shared locks on non-conflicting ranges can be held concurrently, but
    /// an exclusive lock requires no other lock on the range.
    ///
    /// ## See Also
    ///
    /// - ``Kernel/Lock/Range``
    /// - ``Kernel/Lock/lock(_:range:kind:)``
    public enum Kind: Sendable, Equatable, Hashable {
        /// Shared (read) lock allowing concurrent access.
        ///
        /// - Windows: `LockFileEx` without `LOCKFILE_EXCLUSIVE_LOCK`.
        case shared

        /// Exclusive (write) lock preventing all other access.
        ///
        /// - Windows: `LockFileEx` with `LOCKFILE_EXCLUSIVE_LOCK`.
        case exclusive
    }
}
