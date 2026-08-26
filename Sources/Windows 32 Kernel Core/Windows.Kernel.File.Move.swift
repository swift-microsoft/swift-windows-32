public import Error

extension Windows.`32`.Kernel.File {

    public enum Move: Sendable {}
}

extension Windows.`32`.Kernel.File.Move {

    public enum Error: Swift.Error, Sendable, Equatable {

        case notFound

        case permission

        case exists

        case busy

        case crossDevice

        case notEmpty

        case notDirectory

        case invalidArgument

        case isDirectory

        case readOnly

        case loop

        case nameTooLong

        case noSpace

        case platform(Error.Error)
    }
}

extension Windows.`32`.Kernel.File.Move.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .notFound: return "source path not found"
        case .permission: return "permission denied"
        case .exists: return "destination already exists"
        case .busy: return "file in use by another process"
        case .crossDevice: return "cross-device move not supported"
        case .notEmpty: return "destination directory not empty"
        case .notDirectory: return "path component is not a directory"
        case .invalidArgument: return "invalid argument"
        case .isDirectory: return "cannot overwrite directory with file"
        case .readOnly: return "read-only filesystem"
        case .loop: return "too many symbolic links"
        case .nameTooLong: return "path name too long"
        case .noSpace: return "no space left on device"
        case .platform(let e): return "\(e)"
        }
    }
}
