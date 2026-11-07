extension Windows.`32`.Kernel {

    public enum Process: Sendable {}
}

extension Windows.`32`.Kernel.Process {
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
