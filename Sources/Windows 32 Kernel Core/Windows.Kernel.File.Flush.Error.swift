extension Windows.`32`.Kernel.File.Flush {

    public enum Error: Swift.Error, Sendable {

        case handle(Windows.`32`.Kernel.Descriptor.Validity.Error)

        case platform(Error::Error)
    }
}

extension Windows.`32`.Kernel.File.Flush.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.handle(let l), .handle(let r)): return l == r
        case (.platform(let l), .platform(let r)): return l == r
        default: return false
        }
    }
}

extension Windows.`32`.Kernel.File.Flush.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .handle(let e): return "handle: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}
