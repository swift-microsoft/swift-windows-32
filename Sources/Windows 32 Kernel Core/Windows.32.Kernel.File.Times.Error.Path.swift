public import Error


extension Windows.`32`.Kernel.File.Times.Error {
    public enum Path: Swift.Error, Sendable, Equatable {
        case notFound
        case tooLong
        case loop
    }
}
