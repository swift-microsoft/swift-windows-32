public import Error_Primitives

extension Windows.`32`.Kernel.Directory {

    public enum Error: Swift.Error, Sendable, Equatable {

        case notFound

        case permission

        case notDirectory

        case tooManyOpenFiles

        case io

        case closed

        case platform(Error_Primitives.Error)
    }
}

extension Windows.`32`.Kernel.Directory.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .notFound: return "directory not found"
        case .permission: return "permission denied"
        case .notDirectory: return "not a directory"
        case .tooManyOpenFiles: return "too many open files"
        case .io: return "I/O error"
        case .closed: return "directory stream used after close"
        case .platform(let e): return "\(e)"
        }
    }
}
