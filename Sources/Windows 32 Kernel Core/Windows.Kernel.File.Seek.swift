public import Error_Primitives

extension Windows.`32`.Kernel.File {

    public enum Seek: Sendable {}
}

extension Windows.`32`.Kernel.File.Seek {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidDescriptor

        case negativeOffset

        case notSeekable

        case overflow

        case platform(code: Error_Primitives.Error.Code)
    }
}

extension Windows.`32`.Kernel.File.Seek.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .invalidDescriptor:
            return "Invalid file descriptor"

        case .negativeOffset:
            return "Resulting offset would be negative"

        case .notSeekable:
            return "File descriptor is not seekable (pipe, socket, or FIFO)"

        case .overflow:
            return "Resulting offset would overflow"

        case .platform(let code):
            return "Seek failed: \(code)"
        }
    }
}
