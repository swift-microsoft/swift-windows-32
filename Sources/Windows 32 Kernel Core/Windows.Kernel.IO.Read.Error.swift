extension Windows.`32`.Kernel.IO.Read {

    public enum Error: Swift.Error, Sendable {
        case handle(Windows.`32`.Kernel.Descriptor.Validity.Error)
        case blocking(Windows.`32`.Kernel.IO.Blocking.Error)
        case platform(Error.Error)
    }
}

extension Windows.`32`.Kernel.IO.Read.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.handle(let l), .handle(let r)): return l == r
        case (.blocking(let l), .blocking(let r)): return l == r
        case (.platform(let l), .platform(let r)): return l == r
        default: return false
        }
    }
}

extension Windows.`32`.Kernel.IO.Read.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .handle(let e): return "handle: \(e)"
        case .blocking(let e): return "blocking: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}
