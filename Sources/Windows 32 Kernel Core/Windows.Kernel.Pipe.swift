extension Windows.`32`.Kernel {

    public enum Pipe: Sendable {}
}

extension Windows.`32`.Kernel.Pipe {

    public enum Error: Swift.Error, Sendable {

        case handle(Windows.`32`.Kernel.Descriptor.Validity.Error)

        case platform(Error_Primitives.Error)
    }
}

extension Windows.`32`.Kernel.Pipe.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.handle(let l), .handle(let r)): return l == r
        case (.platform(let l), .platform(let r)): return l == r
        default: return false
        }
    }
}

extension Windows.`32`.Kernel.Pipe.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .handle(let e): return "handle: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}
