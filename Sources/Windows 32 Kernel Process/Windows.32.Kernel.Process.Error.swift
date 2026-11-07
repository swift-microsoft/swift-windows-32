
extension Windows.`32`.Kernel.Process {
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {

        case create(Error::Error.Code)

        case wait(Error::Error.Code)

        case platform(Error::Error)
    }
}
