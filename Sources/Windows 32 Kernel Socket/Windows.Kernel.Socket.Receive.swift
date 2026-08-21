#if os(Windows)
    public import Error_Primitives
    public import WinSDK

    extension Windows.`32`.Kernel.Socket {

        public struct ReceiveOptions: OptionSet, Sendable {
            public let rawValue: Int32

            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Windows.`32`.Kernel.Socket.ReceiveOptions {

        public static let peek = Self(rawValue: MSG_PEEK)

        public static let outOfBand = Self(rawValue: MSG_OOB)

        public static let waitAll = Self(rawValue: MSG_WAITALL)

        public static let none = Self(rawValue: 0)
    }

    extension Windows.`32`.Kernel.Socket {

        package static func receive(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            buffer: UnsafeMutableRawPointer,
            length: Int,
            flags: ReceiveOptions = .none
        ) throws(Error) -> Int {
            try receive(socket._rawValue, buffer: buffer, length: length, flags: flags)
        }

        package static func receive(
            _ socket: UInt,
            buffer: UnsafeMutableRawPointer,
            length: Int,
            flags: ReceiveOptions = .none
        ) throws(Error) -> Int {
            let result = recv(
                SOCKET(socket),
                buffer.assumingMemoryBound(to: CChar.self),
                Int32(length),
                flags.rawValue
            )
            guard result != SOCKET_ERROR else {
                throw .platform(Error_Primitives.Error(code: captureLastSocketError()))
            }
            return Int(result)
        }

        package static func receive(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            buffer: UnsafeMutableBufferPointer<UInt8>,
            flags: ReceiveOptions = .none
        ) throws(Error) -> Int {
            guard let baseAddress = buffer.baseAddress else {
                return 0
            }
            return try receive(socket, buffer: baseAddress, length: buffer.count, flags: flags)
        }

        package static func receiveFrom(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            buffer: UnsafeMutableRawPointer,
            length: Int,
            flags: ReceiveOptions = .none,
            srcAddr: UnsafeMutablePointer<sockaddr>,
            srcAddrLength: UnsafeMutablePointer<Int32>
        ) throws(Error) -> Int {
            try receiveFrom(
                socket._rawValue,
                buffer: buffer,
                length: length,
                flags: flags,
                srcAddr: srcAddr,
                srcAddrLength: srcAddrLength
            )
        }

        package static func receiveFrom(
            _ socket: UInt,
            buffer: UnsafeMutableRawPointer,
            length: Int,
            flags: ReceiveOptions = .none,
            srcAddr: UnsafeMutablePointer<sockaddr>,
            srcAddrLength: UnsafeMutablePointer<Int32>
        ) throws(Error) -> Int {
            let result = recvfrom(
                SOCKET(socket),
                buffer.assumingMemoryBound(to: CChar.self),
                Int32(length),
                flags.rawValue,
                srcAddr,
                srcAddrLength
            )
            guard result != SOCKET_ERROR else {
                throw .platform(Error_Primitives.Error(code: captureLastSocketError()))
            }
            return Int(result)
        }
    }

    extension Windows.`32`.Kernel.Socket {

        public static func receive(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            into span: inout Swift.MutableSpan<UInt8>,
            flags: ReceiveOptions = .none
        ) throws(Error) -> (count: Int, address: Windows.`32`.Kernel.Socket.Address.Storage) {
            try unsafe span.withUnsafeMutableBytes { buffer throws(Error) in
                var address = Windows.`32`.Kernel.Socket.Address.Storage()
                var zero: UInt8 = 0
                let count = try unsafe Swift.withUnsafeMutablePointer(to: &zero) {
                    fallback throws(Error) in
                    try address.withUnsafeMutableAddress { pointer, length in
                        try receiveFrom(
                            socket._rawValue,
                            buffer: buffer.baseAddress ?? UnsafeMutableRawPointer(fallback),
                            length: buffer.count,
                            flags: flags,
                            srcAddr: pointer,
                            srcAddrLength: length
                        )
                    }
                }
                return (count: count, address: address)
            }
        }
    }

#endif
