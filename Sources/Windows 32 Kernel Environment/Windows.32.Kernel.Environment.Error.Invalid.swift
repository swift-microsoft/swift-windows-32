public import Error


extension Windows.`32`.Kernel.Environment.Error {
    public enum Invalid: Swift.Error, Sendable, Equatable, Hashable {

        case emptyName

        case nameContainsEquals
    }
}
