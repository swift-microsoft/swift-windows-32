public import Error


extension Windows.`32`.Kernel.File.Times.Error {
    public enum IO: Swift.Error, Sendable, Equatable {
        case hardware
    }
}
