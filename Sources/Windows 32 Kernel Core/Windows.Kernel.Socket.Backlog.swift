extension Windows.`32`.Kernel.Socket {

    public struct Backlog: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        @inlinable
        public init(_ value: Int32) {
            self.rawValue = value
        }
    }
}

extension Windows.`32`.Kernel.Socket.Backlog {

    public static let `default` = Self(128)

    public static let small = Self(16)

    public static let large = Self(4096)
}

extension Windows.`32`.Kernel.Socket.Backlog: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: Int32) {
        self.rawValue = value
    }
}

extension Windows.`32`.Kernel.Socket.Backlog: CustomStringConvertible {
    public var description: Swift.String {
        "\(rawValue)"
    }
}
