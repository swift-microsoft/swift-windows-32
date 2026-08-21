extension Windows.`32`.Kernel.IO.Blocking {

    public enum Error: Swift.Error, Sendable, Equatable, Hashable {

        case wouldBlock
    }
}

extension Windows.`32`.Kernel.IO.Blocking.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .wouldBlock:
            return "operation would block"
        }
    }
}
