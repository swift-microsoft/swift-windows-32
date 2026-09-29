extension Windows.`32`.Kernel.File.Clone {

    public enum Error: Swift.Error, Sendable, Equatable {

        case notSupported

        case crossDevice

        case sourceNotFound

        case destinationExists

        case permissionDenied

        case isDirectory

        case platform(code: Error::Error.Code, operation: Operation)
    }
}

extension Windows.`32`.Kernel.File.Clone.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .notSupported:
            return "Reflink not supported on this filesystem"

        case .crossDevice:
            return "Source and destination are on different devices"

        case .sourceNotFound:
            return "Source file not found"

        case .destinationExists:
            return "Destination already exists"

        case .permissionDenied:
            return "Permission denied"

        case .isDirectory:
            return "Source is a directory"

        case .platform(let code, let operation):
            return "Platform error \(code) during \(operation)"
        }
    }
}
