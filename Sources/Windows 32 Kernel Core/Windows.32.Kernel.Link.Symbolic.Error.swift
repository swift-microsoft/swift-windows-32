public import Error


extension Windows.`32`.Kernel.Link.Symbolic {
    public enum Error: Swift.Error, Sendable, Equatable {

        case notFound

        case permission

        case exists

        case notDirectory

        case readOnly

        case noSpace

        case loop

        case nameTooLong

        case notSymbolicLink

        case bufferTooSmall

        case platform(Error::Error)
    }
}
