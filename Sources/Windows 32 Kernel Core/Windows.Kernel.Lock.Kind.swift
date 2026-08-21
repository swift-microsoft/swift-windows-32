extension Windows.`32`.Kernel.Lock {

    public enum Kind: Sendable, Equatable, Hashable {

        case shared

        case exclusive
    }
}
