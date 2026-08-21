extension Windows.`32`.Kernel.File.Open {

    public struct Options: OptionSet, Sendable, Hashable {

        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}
