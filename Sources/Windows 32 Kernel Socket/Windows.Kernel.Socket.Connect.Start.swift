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
    extension Windows.`32`.Kernel.Socket.Connect {
        /// The synchronous result of starting a reactive connection attempt.
        public enum Start: Sendable, Equatable {
            /// The connection completed immediately.
            case connected

            /// The caller must wait for writability and then call `finish(_:)`.
            case pending
        }
    }
#endif
