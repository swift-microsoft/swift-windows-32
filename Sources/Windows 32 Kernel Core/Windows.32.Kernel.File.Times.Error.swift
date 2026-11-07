public import Error


extension Windows.`32`.Kernel.File.Times {
    public enum Error: Swift.Error, Sendable, Equatable {

        case path(Path)

        case permission(Permission)

        case io(IO)

        case platform(Error::Error)
    }
}
