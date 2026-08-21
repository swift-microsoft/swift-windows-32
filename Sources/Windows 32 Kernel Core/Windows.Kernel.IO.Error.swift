extension Windows.`32`.Kernel.IO {

    public enum Error: Swift.Error, Sendable, Equatable, Hashable {

        case broken

        case reset

        case hardware

        case illegalSeek

        case deviceUnsupported

        case deviceUnavailable

        case unsupported
    }
}

extension Windows.`32`.Kernel.IO.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .broken:
            return "broken pipe"

        case .reset:
            return "connection reset"

        case .hardware:
            return "I/O error"

        case .illegalSeek:
            return "illegal seek"

        case .deviceUnsupported:
            return "operation not supported by device"

        case .deviceUnavailable:
            return "device unavailable"

        case .unsupported:
            return "operation not supported"
        }
    }
}
