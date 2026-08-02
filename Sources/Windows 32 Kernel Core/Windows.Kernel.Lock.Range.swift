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

public import Memory_Allocation_Primitives

extension Windows.`32`.Kernel.Lock {
    /// The range of bytes to lock within a file.
    ///
    /// Mirrors `ISO_9945.Kernel.Lock.Range` in shape. `LockFileEx`/
    /// `UnlockFileEx` operate on a 64-bit byte offset plus a 64-bit length
    /// split across two `DWORD` parameters; the raw syscall wrapper performs
    /// that split.
    ///
    /// ## See Also
    ///
    /// - ``Kernel/Lock/Kind``
    /// - ``Kernel/Lock/lock(_:range:kind:)``
    /// - ``Kernel/Lock/unlock(_:range:)``
    public enum Range: Sendable, Equatable, Hashable {
        /// Locks the entire file, including any bytes appended later.
        ///
        /// Windows has no "lock to current EOF, tracking growth" length
        /// sentinel analogous to POSIX's `l_len == 0`. The established Win32
        /// idiom instead locks the maximal representable range
        /// (`0`..<`0xFFFFFFFF_FFFFFFFF`, i.e. both length `DWORD`s set to
        /// `0xFFFFFFFF`), which covers every byte the file could ever
        /// contain — the raw syscall wrapper performs this translation.
        case file

        /// Locks a specific byte range.
        ///
        /// - Parameters:
        ///   - start: The starting byte offset (inclusive).
        ///   - end: The ending byte offset (exclusive). Use `.max` to lock to EOF.
        ///
        /// Follows Swift's `Range` semantics (half-open interval). Locks on
        /// non-overlapping ranges don't conflict, enabling concurrent access
        /// to different parts of a file.
        case bytes(start: Windows.`32`.Kernel.File.Offset, end: Windows.`32`.Kernel.File.Offset)

        /// Creates a lock range suitable for a memory mapping.
        ///
        /// The range is rounded up to the specified allocation granularity
        /// to ensure the lock covers every byte that could be faulted.
        ///
        /// - Parameters:
        ///   - offset: The aligned start offset of the mapping.
        ///   - length: The mapping length.
        ///   - granularity: The system allocation granularity. Use
        ///     `Memory.Allocation.system` from platform packages.
        @inlinable
        public init(
            forMappingAt offset: Windows.`32`.Kernel.File.Offset,
            length: Windows.`32`.Kernel.File.Size,
            granularity: Memory.Allocation.Granularity
        ) {
            // Saturate rather than trap: a sum beyond Int64.max clamps to
            // the maximum representable offset ("to end of file" in effect).
            let (sum, overflow) = offset.underlying.addingReportingOverflow(length.underlying)
            guard !overflow else {
                self = .bytes(start: offset, end: .max)
                return
            }
            let roundedEnd = granularity.underlying.alignUp(Windows.`32`.Kernel.File.Offset(sum))
            self = .bytes(start: offset, end: roundedEnd)
        }
    }
}

extension Windows.`32`.Kernel.Lock.Range {
    /// Creates a byte range from start to end offsets.
    ///
    /// - Parameters:
    ///   - start: The starting byte offset (inclusive).
    ///   - length: The number of bytes to lock.
    @inlinable
    public static func bytes(start: Windows.`32`.Kernel.File.Offset, length: Windows.`32`.Kernel.File.Size) -> Self {
        // Saturate rather than trap: a sum beyond Int64.max clamps to the
        // maximum representable offset ("to end of file" in effect).
        let (sum, overflow) = start.underlying.addingReportingOverflow(length.underlying)
        return .bytes(start: start, end: overflow ? .max : Windows.`32`.Kernel.File.Offset(sum))
    }
}
