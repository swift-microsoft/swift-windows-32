public import Error

extension Windows.`32`.Kernel.Directory.Create {
    public enum Error: Swift.Error, Sendable, Equatable {

        case notFound

        case permission

        case exists

        case notDirectory

        case readOnly

        case noSpace

        case loop

        case nameTooLong

        case platform(Error::Error)
    }
}
