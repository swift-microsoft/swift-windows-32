#if os(Windows)
    public import Error_Primitives
    public import WinSDK

    extension Windows.`32`.Kernel.Socket {

        public struct OptionLevel: RawRepresentable, Sendable, Equatable {
            public let rawValue: Int32

            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }
        }

        public struct OptionName: RawRepresentable, Sendable, Equatable {
            public let rawValue: Int32

            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Windows.`32`.Kernel.Socket.OptionLevel {

        public static let socket = Self(rawValue: SOL_SOCKET)

        public static let tcp = Self(rawValue: IPPROTO_TCP.rawValue)

        public static let ipv4 = Self(rawValue: IPPROTO_IP)

        public static let ipv6 = Self(rawValue: IPPROTO_IPV6.rawValue)
    }

    extension Windows.`32`.Kernel.Socket.OptionName {

        public static let reuseAddr = Self(rawValue: SO_REUSEADDR)

        public static let keepAlive = Self(rawValue: SO_KEEPALIVE)

        public static let receiveBuffer = Self(rawValue: SO_RCVBUF)

        public static let sendBuffer = Self(rawValue: SO_SNDBUF)

        public static let receiveTimeout = Self(rawValue: SO_RCVTIMEO)

        public static let sendTimeout = Self(rawValue: SO_SNDTIMEO)

        public static let linger = Self(rawValue: SO_LINGER)

        package static let error = Self(rawValue: SO_ERROR)

        public static let type = Self(rawValue: SO_TYPE)

        public static let broadcast = Self(rawValue: SO_BROADCAST)

        public static let oobInline = Self(rawValue: SO_OOBINLINE)

        public static let tcpNoDelay = Self(rawValue: TCP_NODELAY)

        public static let ipv6Only = Self(rawValue: IPV6_V6ONLY)
    }

    extension Windows.`32`.Kernel.Socket {

        package static func getOption(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            level: OptionLevel,
            name: OptionName,
            value: UnsafeMutableRawPointer,
            length: UnsafeMutablePointer<Int32>
        ) throws(Error) {
            try getOption(socket._rawValue, level: level, name: name, value: value, length: length)
        }

        package static func getOption(
            _ socket: UInt,
            level: OptionLevel,
            name: OptionName,
            value: UnsafeMutableRawPointer,
            length: UnsafeMutablePointer<Int32>
        ) throws(Error) {
            let result = getsockopt(
                SOCKET(socket),
                level.rawValue,
                name.rawValue,
                value.assumingMemoryBound(to: CChar.self),
                length
            )
            guard result == 0 else {
                throw .platform(Error_Primitives.Error(code: captureLastSocketError()))
            }
        }

        package static func setOption(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            level: OptionLevel,
            name: OptionName,
            value: UnsafeRawPointer,
            length: Int32
        ) throws(Error) {
            try setOption(socket._rawValue, level: level, name: name, value: value, length: length)
        }

        package static func setOption(
            _ socket: UInt,
            level: OptionLevel,
            name: OptionName,
            value: UnsafeRawPointer,
            length: Int32
        ) throws(Error) {
            let result = setsockopt(
                SOCKET(socket),
                level.rawValue,
                name.rawValue,
                value.assumingMemoryBound(to: CChar.self),
                length
            )
            guard result == 0 else {
                throw .platform(Error_Primitives.Error(code: captureLastSocketError()))
            }
        }

        public static func getBoolOption(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            level: OptionLevel,
            name: OptionName
        ) throws(Error) -> Bool {
            var value: Int32 = 0
            var length = Int32(MemoryLayout<Int32>.size)
            try getOption(socket, level: level, name: name, value: &value, length: &length)
            return value != 0
        }

        public static func setBoolOption(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            level: OptionLevel,
            name: OptionName,
            value: Bool
        ) throws(Error) {
            var intValue: Int32 = value ? 1 : 0
            try setOption(
                socket,
                level: level,
                name: name,
                value: &intValue,
                length: Int32(MemoryLayout<Int32>.size)
            )
        }

        public static func getIntOption(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            level: OptionLevel,
            name: OptionName
        ) throws(Error) -> Int32 {
            var value: Int32 = 0
            var length = Int32(MemoryLayout<Int32>.size)
            try getOption(socket, level: level, name: name, value: &value, length: &length)
            return value
        }

        public static func setIntOption(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            level: OptionLevel,
            name: OptionName,
            value: Int32
        ) throws(Error) {
            var intValue = value
            try setOption(
                socket,
                level: level,
                name: name,
                value: &intValue,
                length: Int32(MemoryLayout<Int32>.size)
            )
        }

        public static func setReuseAddress(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            enabled: Bool
        ) throws(Error) {
            try setBoolOption(socket, level: .socket, name: .reuseAddr, value: enabled)
        }

        public static func setNoDelay(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            enabled: Bool
        ) throws(Error) {
            try setBoolOption(socket, level: .tcp, name: .tcpNoDelay, value: enabled)
        }

        package static func getError(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor
        ) throws(Error) -> Int32 {
            try getIntOption(socket, level: .socket, name: .error)
        }

        public static func setReceiveBuffer(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            size: Int32
        ) throws(Error) {
            try setIntOption(socket, level: .socket, name: .receiveBuffer, value: size)
        }

        public static func setSendBuffer(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            size: Int32
        ) throws(Error) {
            try setIntOption(socket, level: .socket, name: .sendBuffer, value: size)
        }

        public static func setKeepAlive(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            enabled: Bool
        ) throws(Error) {
            try setBoolOption(socket, level: .socket, name: .keepAlive, value: enabled)
        }
    }

    extension Windows.`32`.Kernel.Socket {

        package static func getSockName(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            address: UnsafeMutablePointer<sockaddr>,
            addressLength: UnsafeMutablePointer<Int32>
        ) throws(Error) {
            try getSockName(socket._rawValue, address: address, addressLength: addressLength)
        }

        package static func getSockName(
            _ socket: UInt,
            address: UnsafeMutablePointer<sockaddr>,
            addressLength: UnsafeMutablePointer<Int32>
        ) throws(Error) {
            let result = getsockname(SOCKET(socket), address, addressLength)
            guard result == 0 else {
                throw .platform(Error_Primitives.Error(code: captureLastSocketError()))
            }
        }

        package static func getPeerName(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            address: UnsafeMutablePointer<sockaddr>,
            addressLength: UnsafeMutablePointer<Int32>
        ) throws(Error) {
            try getPeerName(socket._rawValue, address: address, addressLength: addressLength)
        }

        package static func getPeerName(
            _ socket: UInt,
            address: UnsafeMutablePointer<sockaddr>,
            addressLength: UnsafeMutablePointer<Int32>
        ) throws(Error) {
            let result = getpeername(SOCKET(socket), address, addressLength)
            guard result == 0 else {
                throw .platform(Error_Primitives.Error(code: captureLastSocketError()))
            }
        }

        public static func localAddress(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor
        ) throws(Error) -> Windows.`32`.Kernel.Socket.Address.Storage {
            var address = Windows.`32`.Kernel.Socket.Address.Storage()
            try address.withUnsafeMutableAddress { pointer, length in
                try getSockName(socket._rawValue, address: pointer, addressLength: length)
            }
            return address
        }

        public static func peerAddress(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor
        ) throws(Error) -> Windows.`32`.Kernel.Socket.Address.Storage {
            var address = Windows.`32`.Kernel.Socket.Address.Storage()
            try address.withUnsafeMutableAddress { pointer, length in
                try getPeerName(socket._rawValue, address: pointer, addressLength: length)
            }
            return address
        }
    }

#endif
