#if os(Windows)
    public import Error
    public import WinSDK

    extension Windows.`32`.Kernel.Socket {

        public struct SendOptions: OptionSet, Sendable {
            public let rawValue: Int32

            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Windows.`32`.Kernel.Socket.SendOptions {

        public static let outOfBand = Self(rawValue: MSG_OOB)

        public static let dontRoute = Self(rawValue: MSG_DONTROUTE)

        public static let none = Self(rawValue: 0)
    }

    extension Windows.`32`.Kernel.Socket {

        package static func send(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            buffer: UnsafeRawPointer,
            length: Int,
            flags: SendOptions = .none
        ) throws(Error) -> Int {
            try send(socket._rawValue, buffer: buffer, length: length, flags: flags)
        }

        package static func send(
            _ socket: UInt,
            buffer: UnsafeRawPointer,
            length: Int,
            flags: SendOptions = .none
        ) throws(Error) -> Int {
            let result = WinSDK.send(
                SOCKET(socket),
                buffer.assumingMemoryBound(to: CChar.self),
                Int32(length),
                flags.rawValue
            )
            guard result != SOCKET_ERROR else {
                throw .platform(Error::Error(code: captureLastSocketError()))
            }
            return Int(result)
        }

        package static func send(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            buffer: UnsafeBufferPointer<UInt8>,
            flags: SendOptions = .none
        ) throws(Error) -> Int {
            guard let baseAddress = buffer.baseAddress else {
                return 0
            }
            return try send(socket, buffer: baseAddress, length: buffer.count, flags: flags)
        }

        package static func sendTo(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            buffer: UnsafeRawPointer,
            length: Int,
            flags: SendOptions = .none,
            destAddr: UnsafePointer<sockaddr>,
            destAddrLength: Int32
        ) throws(Error) -> Int {
            try sendTo(
                socket._rawValue,
                buffer: buffer,
                length: length,
                flags: flags,
                destAddr: destAddr,
                destAddrLength: destAddrLength
            )
        }

        package static func sendTo(
            _ socket: UInt,
            buffer: UnsafeRawPointer,
            length: Int,
            flags: SendOptions = .none,
            destAddr: UnsafePointer<sockaddr>,
            destAddrLength: Int32
        ) throws(Error) -> Int {
            let result = sendto(
                SOCKET(socket),
                buffer.assumingMemoryBound(to: CChar.self),
                Int32(length),
                flags.rawValue,
                destAddr,
                destAddrLength
            )
            guard result != SOCKET_ERROR else {
                throw .platform(Error::Error(code: captureLastSocketError()))
            }
            return Int(result)
        }
    }

    extension Windows.`32`.Kernel.Socket {

        public static func send(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            from span: Swift.Span<UInt8>,
            to address: Windows.`32`.Kernel.Socket.Address.Storage,
            flags: SendOptions = .none
        ) throws(Error) -> Int {
            try unsafe span.withUnsafeBytes { buffer throws(Error) in
                var zero: UInt8 = 0
                return try unsafe Swift.withUnsafePointer(to: &zero) { fallback throws(Error) in
                    try address.withUnsafeAddress { pointer, length in
                        try sendTo(
                            socket._rawValue,
                            buffer: buffer.baseAddress ?? UnsafeRawPointer(fallback),
                            length: buffer.count,
                            flags: flags,
                            destAddr: pointer,
                            destAddrLength: length
                        )
                    }
                }
            }
        }
    }

#endif
