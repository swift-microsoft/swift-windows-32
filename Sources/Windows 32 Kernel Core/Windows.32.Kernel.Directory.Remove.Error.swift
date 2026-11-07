public import Error


extension Windows.`32`.Kernel.Directory.Remove {
    public enum Error: Swift.Error, Sendable, Equatable {

        case notFound

        case permission

        case notEmpty

        case notDirectory

        case busy

        case readOnly

        case loop

        case nameTooLong

        case platform(Error::Error)
    }
}
