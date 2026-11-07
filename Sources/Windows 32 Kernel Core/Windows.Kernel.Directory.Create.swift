import Error

extension Windows.`32`.Kernel.Directory {

    public enum Create: Sendable {}
}

extension Windows.`32`.Kernel.Directory.Create {
}

extension Windows.`32`.Kernel.Directory.Create.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .notFound: return "path component not found"
        case .permission: return "permission denied"
        case .exists: return "path already exists"
        case .notDirectory: return "path component is not a directory"
        case .readOnly: return "read-only filesystem"
        case .noSpace: return "no space left on device"
        case .loop: return "too many symbolic links"
        case .nameTooLong: return "path name too long"
        case .platform(let e): return "\(e)"
        }
    }
}
