extension Windows.`32`.Kernel.Pipe {
    public enum Error: Swift.Error, Sendable {

        case handle(Windows.`32`.Kernel.Descriptor.Validity.Error)

        case platform(Error::Error)
    }
}
