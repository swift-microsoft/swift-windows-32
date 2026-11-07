public import Error


extension Windows.`32`.Kernel.File.Seek {
    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidDescriptor

        case negativeOffset

        case notSeekable

        case overflow

        case platform(code: Error::Error.Code)
    }
}
