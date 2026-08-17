// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-32 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-windows-32 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
    public import Error_Primitives
    public import Memory_Primitives

    // MARK: - Windows Memory Advise (No-Op)
    //
    // Windows does not have an equivalent to POSIX madvise().
    // These functions are provided for API compatibility and are no-ops.

    extension Memory.Map {
        /// Advises the kernel about expected memory access patterns.
        ///
        /// Typed L2 form, mirroring the ISO 9945 typed convenience
        /// (`ISO_9945.Kernel.Memory.Map.advise(addr:length:advice:)`): portable
        /// callers hold a `Memory.Address`, not a raw pointer, and must not be
        /// forced through an `unsafe` pointer overload to express a hint.
        ///
        /// On Windows, this is a no-op since there is no equivalent to `madvise(2)`.
        /// Advice is advisory on every platform, so the Windows realisation of
        /// the contract is total and cannot fail.
        ///
        /// - Parameters:
        ///   - addr: The base address of the memory region.
        ///   - length: The length of the region in bytes.
        ///   - advice: The access pattern hint (ignored on Windows).
        public static func advise(
            addr: Memory.Address,
            length: Memory.Address.Count,
            advice: Memory.Map.Advice
        ) {
            // No-op on Windows
        }

        /// Advises the kernel about expected memory access patterns.
        ///
        /// On Windows, this is a no-op since there is no equivalent to `madvise(2)`.
        /// The function is provided for cross-platform API compatibility.
        ///
        /// - Parameters:
        ///   - addr: The base address of the memory region.
        ///   - length: The length of the region in bytes.
        ///   - advice: The access pattern hint (ignored on Windows).
        @unsafe
        public static func advise(
            addr: UnsafeMutableRawPointer,
            length: Memory.Address.Count,
            advice: Memory.Map.Advice
        ) {
            // No-op on Windows
        }

        /// Advises the kernel about expected memory access patterns.
        ///
        /// On Windows, this is a no-op since there is no equivalent to `madvise(2)`.
        ///
        /// - Parameters:
        ///   - addr: The base address of the memory region.
        ///   - length: The length of the region in bytes.
        ///   - advice: The access pattern hint (ignored on Windows).
        @unsafe
        public static func advise(
            addr: UnsafeRawPointer,
            length: Memory.Address.Count,
            advice: Memory.Map.Advice
        ) {
            // No-op on Windows
        }
    }

#endif
