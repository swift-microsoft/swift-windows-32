public import Error

extension Windows.`32`.Kernel.File.Delete {
    public enum Error: Swift.Error, Sendable, Equatable {

        case notFound

        case permission

        case isDirectory

        case notDirectory

        case readOnly

        case busy

        case loop

        case nameTooLong

        case platform(Error::Error)
    }
}
