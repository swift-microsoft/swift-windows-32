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

    extension Windows.`32`.Kernel.Socket.Address {
        /// Opaque storage large enough for every Winsock socket address.
        public struct Storage: Sendable {
            internal var value: sockaddr_storage
            internal var length: Int32

            /// Creates empty storage for an address written by Winsock.
            public init() {
                self.value = sockaddr_storage()
                self.length = Int32(MemoryLayout<sockaddr_storage>.size)
            }
        }
    }

    extension Windows.`32`.Kernel.Socket.Address.Storage {
        /// The address family reported by Winsock.
        public var family: Windows.`32`.Kernel.Socket.Family {
            Windows.`32`.Kernel.Socket.Family(rawValue: Int32(value.ss_family))
        }

        internal func withUnsafeAddress<Result, Failure: Swift.Error>(
            _ body: (UnsafePointer<sockaddr>, Int32) throws(Failure) -> Result
        ) throws(Failure) -> Result {
            try unsafe Swift.withUnsafePointer(to: value) { pointer throws(Failure) in
                try unsafe pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    try unsafe body($0, length)
                }
            }
        }

        internal mutating func withUnsafeMutableAddress<Result, Failure: Swift.Error>(
            _ body: (UnsafeMutablePointer<sockaddr>, UnsafeMutablePointer<Int32>) throws(Failure) -> Result
        ) throws(Failure) -> Result {
            try unsafe Swift.withUnsafeMutablePointer(to: &value) { pointer throws(Failure) in
                try unsafe pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { address in
                    try unsafe body(address, &length)
                }
            }
        }
    }
#endif
