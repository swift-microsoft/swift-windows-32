public import Error

extension Windows.`32`.Kernel.File.Move {
    public enum Error: Swift.Error, Sendable, Equatable {

        case notFound

        case permission

        case exists

        case busy

        case crossDevice

        case notEmpty

        case notDirectory

        case invalidArgument

        case isDirectory

        case readOnly

        case loop

        case nameTooLong

        case noSpace

        case platform(Error::Error)
    }
}
