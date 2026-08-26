public import Error

extension Windows.`32`.Kernel.File {

    public enum Times {}
}

extension Windows.`32`.Kernel.File.Times {

    public enum Error: Swift.Error, Sendable, Equatable {

        case path(Path)

        case permission(Permission)

        case io(IO)

        case platform(Error.Error)
    }
}

extension Windows.`32`.Kernel.File.Times.Error {

    public enum Path: Swift.Error, Sendable, Equatable {
        case notFound
        case tooLong
        case loop
    }

    public enum Permission: Swift.Error, Sendable, Equatable {
        case denied
        case notPermitted
        case readOnlyFilesystem
    }

    public enum IO: Swift.Error, Sendable, Equatable {
        case hardware
    }
}

extension Windows.`32`.Kernel.File.Times.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .path(let pathError):
            return "file times path error: \(pathError)"

        case .permission(let permError):
            return "file times permission error: \(permError)"

        case .io(let ioError):
            return "file times I/O error: \(ioError)"

        case .platform(let e):
            return "file times error: \(e)"
        }
    }
}
