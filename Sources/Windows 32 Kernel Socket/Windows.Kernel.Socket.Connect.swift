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
    public import WinSDK

    // MARK: - Socket Connect

    extension Windows.`32`.Kernel.Socket {
        /// Typed reactive connection operations.
        public enum Connect: Sendable {}

        /// Connects a socket to a remote address.
        ///
        /// Establishes a connection to a specified address. For stream sockets
        /// (TCP), this initiates the three-way handshake. For datagram sockets
        /// (UDP), this sets the default destination address.
        ///
        /// - Parameters:
        ///   - socket: The socket to connect.
        ///   - address: Pointer to the remote address.
        ///   - addressLength: Size of the address structure.
        /// - Throws: `Error.connect` on failure.
        ///
        /// ## Blocking Behavior
        ///
        /// For blocking sockets, this call blocks until the connection is
        /// established or fails. For non-blocking sockets, it returns
        /// immediately with `WSAEWOULDBLOCK` if the connection cannot be
        /// completed immediately.
        package static func connect(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            address: UnsafePointer<sockaddr>,
            addressLength: Int32
        ) throws(Error) {
            try connect(socket._rawValue, address: address, addressLength: addressLength)
        }

        /// Connects a SOCKET bit pattern to a remote address.
        ///
        /// Spec-literal raw `connect`. The typed L2 convenience
        /// (`connect(_:address:addressLength:)` taking
        /// `borrowing Windows.`32`.Kernel.Socket.Descriptor`) delegates to this raw SPI
        /// internally via `socket._rawValue`.
        ///
        /// - Parameters:
        ///   - socket: SOCKET bit pattern.
        ///   - address: Pointer to the remote address.
        ///   - addressLength: Size of the address structure.
        /// - Throws: `Error.connect` on failure.
        package static func connect(
            _ socket: UInt,
            address: UnsafePointer<sockaddr>,
            addressLength: Int32
        ) throws(Error) {
            let result = WinSDK.connect(SOCKET(socket), address, addressLength)
            guard result == 0 else {
                throw .platform(Error_Primitives.Error(code: captureLastSocketError()))
            }
        }
    }

    extension Windows.`32`.Kernel.Socket.Connect {
        /// Starts a connection without taking ownership of readiness or cancellation.
        public static func start(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            address: Windows.`32`.Kernel.Socket.Address.Storage
        ) throws(Windows.`32`.Kernel.Socket.Error) -> Start {
            do throws(Windows.`32`.Kernel.Socket.Error) {
                try address.withUnsafeAddress { pointer, length in
                    try Windows.`32`.Kernel.Socket.connect(
                        socket._rawValue,
                        address: pointer,
                        addressLength: length
                    )
                }
                return .connected
            } catch where error.disposition == .wouldBlock || error.disposition == .pending {
                return .pending
            }
        }

        /// Finishes a pending connection attempt after the socket becomes writable.
        public static func finish(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor
        ) throws(Windows.`32`.Kernel.Socket.Error) {
            let error = try Windows.`32`.Kernel.Socket.getError(socket)
            guard error == 0 else {
                throw Windows.`32`.Kernel.Socket.Error(
                    code: .win32(DWORD(UInt32(bitPattern: error)))
                )
            }
        }
    }

#endif
