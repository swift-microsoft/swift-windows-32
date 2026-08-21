extension Windows.`32`.Kernel.Descriptor {

    public enum Duplicate: Sendable {}
}

extension Windows.`32`.Kernel.Descriptor.Duplicate {

    public enum Error: Swift.Error, Sendable, Equatable {

        case handle(Windows.`32`.Kernel.Descriptor.Validity.Error)

        case tooManyOpen

        case platform(Error_Primitives.Error)
    }
}
