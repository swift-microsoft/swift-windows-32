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
    internal import WinSDK

    extension Windows.`32`.Kernel.Socket.Error {
        /// A socket failure whose recovery meaning is stable above Winsock.
        public enum Disposition: Sendable, Equatable {
            /// The non-blocking operation cannot make progress yet.
            case wouldBlock

            /// A connection attempt remains in progress.
            case pending

            /// The peer reset the connection.
            case connectionReset
        }

        /// The semantic disposition of a Winsock failure, when it has one.
        public var disposition: Disposition? {
            switch code {
            case .win32(DWORD(WSAEWOULDBLOCK)):
                return .wouldBlock

            case .win32(DWORD(WSAEINPROGRESS)), .win32(DWORD(WSAEALREADY)):
                return .pending

            case .win32(DWORD(WSAECONNRESET)):
                return .connectionReset

            default:
                return nil
            }
        }
    }
#endif
