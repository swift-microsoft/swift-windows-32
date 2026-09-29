extension Windows.`32`.Kernel.File.System.Stats {

    public enum Error: Swift.Error, Sendable, Equatable {
        case path(Path.Resolution.Error)
        case handle(Windows.`32`.Kernel.Descriptor.Validity.Error)
        case platform(Error::Error)
    }
}

extension Windows.`32`.Kernel.File.System.Stats.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .path(let e): return "path: \(e)"
        case .handle(let e): return "handle: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}
