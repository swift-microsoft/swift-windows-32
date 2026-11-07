import Error

extension Windows.`32`.Kernel.Link {

    public enum Symbolic: Sendable {}
}

extension Windows.`32`.Kernel.Link.Symbolic {
}

extension Windows.`32`.Kernel.Link.Symbolic.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .notFound: return "path not found"
        case .permission: return "permission denied"
        case .exists: return "path already exists"
        case .notDirectory: return "path component is not a directory"
        case .readOnly: return "read-only filesystem"
        case .noSpace: return "no space left on device"
        case .loop: return "too many symbolic links"
        case .nameTooLong: return "path name too long"
        case .notSymbolicLink: return "not a symbolic link"
        case .bufferTooSmall: return "buffer too small"
        case .platform(let e): return "\(e)"
        }
    }
}
