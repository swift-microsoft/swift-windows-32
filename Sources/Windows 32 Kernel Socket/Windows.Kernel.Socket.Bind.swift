#if os(Windows)
    public import Error
    public import WinSDK

    extension Windows.`32`.Kernel.Socket {

        package static func bind(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            address: UnsafePointer<sockaddr>,
            addressLength: Int32
        ) throws(Error) {
            try bind(socket._rawValue, address: address, addressLength: addressLength)
        }

        public static func bind(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            address: Windows.`32`.Kernel.Socket.Address.Storage
        ) throws(Error) {
            try address.withUnsafeAddress { pointer, length in
                try bind(socket._rawValue, address: pointer, addressLength: length)
            }
        }

        package static func bind(
            _ socket: UInt,
            address: UnsafePointer<sockaddr>,
            addressLength: Int32
        ) throws(Error) {
            let result = WinSDK.bind(SOCKET(socket), address, addressLength)
            guard result == 0 else {
                throw .platform(Error.Error(code: captureLastSocketError()))
            }
        }
    }

    extension Windows.`32`.Kernel.Socket {

        @inlinable
        public static func htons(_ port: UInt16) -> UInt16 {
            port.bigEndian
        }

        @inlinable
        public static func ntohs(_ port: UInt16) -> UInt16 {
            UInt16(bigEndian: port)
        }

        @inlinable
        public static func htonl(_ value: UInt32) -> UInt32 {
            value.bigEndian
        }

        @inlinable
        public static func ntohl(_ value: UInt32) -> UInt32 {
            UInt32(bigEndian: value)
        }
    }

#endif
