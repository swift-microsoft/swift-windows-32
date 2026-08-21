extension Windows.`32`.Kernel {

    public struct Device: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: UInt64

        @inlinable
        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }

        @inlinable
        public init(_ value: UInt64) {
            self.rawValue = value
        }
    }
}

extension Windows.`32`.Kernel.Device: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: UInt64) {
        self.rawValue = value
    }
}
