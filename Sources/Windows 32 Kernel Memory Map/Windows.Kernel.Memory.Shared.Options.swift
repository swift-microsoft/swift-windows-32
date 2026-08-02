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

#if os(Windows)
    public import Memory_Primitives

    extension Memory.Shared {
        /// Creation options for named Windows shared memory objects.
        public struct Options: OptionSet, Sendable, Hashable {
            public let rawValue: UInt8

            @inlinable
            public init(rawValue: UInt8) {
                self.rawValue = rawValue
            }
        }
    }

    extension Memory.Shared.Options {
        /// Creates the mapping if it does not already exist.
        public static let create = Self(rawValue: 1 << 0)

        /// Fails when a mapping of the same name already exists.
        public static let exclusive = Self(rawValue: 1 << 1)

        /// Portable truncation option; Windows accepts it without changing an
        /// existing page-file mapping's size.
        public static let truncate = Self(rawValue: 1 << 2)
    }
#endif
