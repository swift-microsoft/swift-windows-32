#if os(Windows)
    public import Error
    public import WinSDK

    extension Windows.`32`.Kernel.Socket {

        public static func startup() throws(Error) {
            var wsaData = WSADATA()
            let result = WSAStartup(makeWord(2, 2), &wsaData)
            guard result == 0 else {
                throw .platform(
                    Error.Error(code: Error.Error.Code.win32(DWORD(result)))
                )
            }
        }

        @discardableResult
        public static func cleanup() -> Bool {
            WSACleanup() == 0
        }
    }

    extension Windows.`32`.Kernel.Socket {

        public struct Family: RawRepresentable, Sendable, Equatable {
            public let rawValue: Int32

            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }
        }

        public struct SocketType: RawRepresentable, Sendable, Equatable {
            public let rawValue: Int32

            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }
        }

        public struct `Protocol`: RawRepresentable, Sendable, Equatable {
            public let rawValue: Int32

            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Windows.`32`.Kernel.Socket.Family {

        public static let inet = Self(rawValue: AF_INET)

        public static let inet6 = Self(rawValue: AF_INET6)

        public static let unix = Self(rawValue: AF_UNIX)

        public static let unspec = Self(rawValue: AF_UNSPEC)
    }

    extension Windows.`32`.Kernel.Socket.SocketType {

        public static let stream = Self(rawValue: SOCK_STREAM)

        public static let datagram = Self(rawValue: SOCK_DGRAM)

        public static let raw = Self(rawValue: SOCK_RAW)
    }

    extension Windows.`32`.Kernel.Socket.`Protocol` {

        public static let tcp = Self(rawValue: IPPROTO_TCP.rawValue)

        public static let udp = Self(rawValue: IPPROTO_UDP.rawValue)

        public static let `default` = Self(rawValue: 0)
    }

    extension Windows.`32`.Kernel.Socket {

        public static func create(
            family: Family,
            type: SocketType,
            protocol: `Protocol` = .default
        ) throws(Error) -> Windows.`32`.Kernel.Socket.Descriptor {
            let sock = socket(family.rawValue, type.rawValue, `protocol`.rawValue)
            guard sock != INVALID_SOCKET else {
                throw .platform(Error.Error(code: captureLastSocketError()))
            }
            return Windows.`32`.Kernel.Socket.Descriptor(_rawValue: UInt(sock))
        }

        public static func close(_ socket: consuming Windows.`32`.Kernel.Socket.Descriptor) {

        }
    }

    @inlinable
    package func makeWord(_ low: UInt8, _ high: UInt8) -> WORD {
        WORD(low) | (WORD(high) << 8)
    }

    @usableFromInline
    internal func captureLastSocketError() -> Error.Error.Code {
        .win32(DWORD(WSAGetLastError()))
    }

#endif
