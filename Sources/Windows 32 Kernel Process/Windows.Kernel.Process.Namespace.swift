extension Windows.`32`.Kernel {

    public enum Process: Sendable {}
}

extension Windows.`32`.Kernel.Process {

    public enum Error: Swift.Error, Sendable, Equatable, Hashable {

        case create(Error_Primitives.Error.Code)

        case wait(Error_Primitives.Error.Code)

        case platform(Error_Primitives.Error)
    }
}

extension Windows.`32`.Kernel.Process.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .create(let c): return "create: \(c)"
        case .wait(let c): return "wait: \(c)"
        case .platform(let e): return "\(e)"
        }
    }
}
