extension Windows.`32`.Kernel.Directory.Working {

    public enum Error: Swift.Error, Sendable {

        case path(Path.Resolution.Error)

        case platform(Error::Error)
    }
}

extension Windows.`32`.Kernel.Directory.Working.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.path(let l), .path(let r)): return l == r
        case (.platform(let l), .platform(let r)): return l == r
        default: return false
        }
    }
}

extension Windows.`32`.Kernel.Directory.Working.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .path(let e): return "working directory: \(e)"
        case .platform(let e): return "working directory: \(e)"
        }
    }
}
