public import Error_Primitives

extension Windows.`32`.Kernel.Link {

    public enum Error: Swift.Error, Sendable, Equatable {

        case notFound

        case permission

        case exists

        case crossDevice

        case isDirectory

        case notDirectory

        case readOnly

        case tooManyLinks

        case noSpace

        case loop

        case nameTooLong

        case platform(Error_Primitives.Error)
    }
}

extension Windows.`32`.Kernel.Link.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .notFound: return "source not found"
        case .permission: return "permission denied"
        case .exists: return "link already exists"
        case .crossDevice: return "cross-device link not allowed"
        case .isDirectory: return "cannot link directories"
        case .notDirectory: return "path component is not a directory"
        case .readOnly: return "read-only filesystem"
        case .tooManyLinks: return "too many links to file"
        case .noSpace: return "no space left on device"
        case .loop: return "too many symbolic links"
        case .nameTooLong: return "path name too long"
        case .platform(let e): return "\(e)"
        }
    }
}
