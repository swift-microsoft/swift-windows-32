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

    // MARK: - Windows Error Code Mapping

    extension Windows.`32`.Kernel.Lock.Error {
        /// Creates a lock error from a Windows error code, if applicable.
        ///
        /// - Parameter code: The kernel error code.
        /// - Returns: A lock error, or `nil` if not applicable.
        ///
        /// Only `ERROR_LOCK_VIOLATION` classifies as a lock-specific code on
        /// Windows. `.deadlock` and `.interrupted` have no Win32 code to map
        /// from (see the doc comment on `Windows.Kernel.Lock.Error`); any
        /// other code falls through to `nil` here, and the raw `lock`/`unlock`
        /// syscalls fall back to `.platform(code:)` via `init(_:)` below.
        @inlinable
        public init?(code: Error_Primitives.Error.Code) {
            switch code {
            case .Windows.ERROR_LOCK_VIOLATION:
                self = .contention

            default:
                return nil
            }
        }

        /// Creates a lock error from a captured Win32 error code,
        /// unconditionally — falls back to `.platform(code:)`.
        ///
        /// Used internally by the raw `lock`/`unlock` syscalls immediately
        /// after a failing `LockFileEx`/`UnlockFileEx` call.
        @usableFromInline
        internal init(_ code: Error_Primitives.Error.Code) {
            if let mapped = Self(code: code) {
                self = mapped
            } else {
                self = .platform(code: code)
            }
        }
    }
#endif
