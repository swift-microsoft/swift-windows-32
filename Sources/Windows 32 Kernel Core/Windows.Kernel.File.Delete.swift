public import Error_Primitives

extension Windows.`32`.Kernel.File {

    public enum Delete: Sendable {}
}

extension Windows.`32`.Kernel.File.Delete {

    public enum Error: Swift.Error, Sendable, Equatable {

        case notFound

        case permission

        case isDirectory

        case notDirectory

        case readOnly

        case busy

        case loop

        case nameTooLong

        case platform(Error_Primitives.Error)
    }
}

extension Windows.`32`.Kernel.File.Delete.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .notFound: return "file not found"
        case .permission: return "permission denied"
        case .isDirectory: return "is a directory"
        case .notDirectory: return "path component is not a directory"
        case .readOnly: return "read-only filesystem"
        case .busy: return "file busy"
        case .loop: return "too many symbolic links"
        case .nameTooLong: return "path name too long"
        case .platform(let e): return "\(e)"
        }
    }
}
