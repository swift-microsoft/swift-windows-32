public import Error_Primitives

extension Windows.`32`.Kernel.Directory {

    public enum Remove: Sendable {}
}

extension Windows.`32`.Kernel.Directory.Remove {

    public enum Error: Swift.Error, Sendable, Equatable {

        case notFound

        case permission

        case notEmpty

        case notDirectory

        case busy

        case readOnly

        case loop

        case nameTooLong

        case platform(Error_Primitives.Error)
    }
}

extension Windows.`32`.Kernel.Directory.Remove.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .notFound: return "directory not found"
        case .permission: return "permission denied"
        case .notEmpty: return "directory not empty"
        case .notDirectory: return "not a directory"
        case .busy: return "directory busy"
        case .readOnly: return "read-only filesystem"
        case .loop: return "too many symbolic links"
        case .nameTooLong: return "path name too long"
        case .platform(let e): return "\(e)"
        }
    }
}
