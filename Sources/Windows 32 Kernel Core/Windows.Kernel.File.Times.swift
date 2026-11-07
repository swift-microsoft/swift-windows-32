import Error

extension Windows.`32`.Kernel.File {

    public enum Times {}
}

extension Windows.`32`.Kernel.File.Times {
}

extension Windows.`32`.Kernel.File.Times.Error {
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
