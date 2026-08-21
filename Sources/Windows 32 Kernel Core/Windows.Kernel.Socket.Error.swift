extension Windows.`32`.Kernel.Socket {

    public enum Error: Swift.Error, Sendable {

        case platform(Error_Primitives.Error)
    }
}

extension Windows.`32`.Kernel.Socket.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.platform(let l), .platform(let r)): return l == r
        }
    }
}

extension Windows.`32`.Kernel.Socket.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .platform(let e): return "\(e)"
        }
    }
}
