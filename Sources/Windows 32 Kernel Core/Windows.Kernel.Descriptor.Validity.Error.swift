extension Windows.`32`.Kernel.Descriptor.Validity {

    public enum Error: Swift.Error, Sendable, Equatable, Hashable {

        case invalid

        case limit(Limit)
    }
}

extension Windows.`32`.Kernel.Descriptor.Validity.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .invalid:
            return "invalid handle"

        case .limit(let limit):
            return limit.description
        }
    }
}
