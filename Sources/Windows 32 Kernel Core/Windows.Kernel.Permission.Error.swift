extension Windows.`32`.Kernel.Permission {

    public enum Error: Swift.Error, Sendable, Equatable, Hashable {

        case denied

        case notPermitted

        case readOnlyFilesystem
    }
}

extension Windows.`32`.Kernel.Permission.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .denied:
            return "permission denied"

        case .notPermitted:
            return "operation not permitted"

        case .readOnlyFilesystem:
            return "read-only filesystem"
        }
    }
}
