public import Error

extension Windows.`32`.Kernel.Environment {

    public enum Error: Swift.Error, Sendable {
        case permission(Windows.`32`.Kernel.Permission.Error)
        case invalid(Invalid)
        case platform(Error.Error)
    }
}

extension Windows.`32`.Kernel.Environment.Error {

    public enum Invalid: Swift.Error, Sendable, Equatable, Hashable {

        case emptyName

        case nameContainsEquals
    }
}

#if os(Windows)
    extension Windows.`32`.Kernel.Environment.Error {

        public init(code: Error::Error.Code) {
            if let permission = Windows.`32`.Kernel.Permission.Error(code: code) {
                self = .permission(permission)
            } else {
                self = .platform(Error.Error(code: code))
            }
        }
    }
#endif

extension Windows.`32`.Kernel.Environment.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.permission(let l), .permission(let r)): return l == r
        case (.invalid(let l), .invalid(let r)): return l == r
        case (.platform(let l), .platform(let r)): return l == r
        default: return false
        }
    }
}

extension Windows.`32`.Kernel.Environment.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .permission(let e): return "permission: \(e)"
        case .invalid(let e): return "invalid: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}

extension Windows.`32`.Kernel.Environment.Error.Invalid: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .emptyName: return "empty variable name"
        case .nameContainsEquals: return "variable name contains '='"
        }
    }
}
