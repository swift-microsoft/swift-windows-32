extension Windows.`32`.Kernel.File.Direct.Mode {

    public enum Resolved: Sendable, Equatable {
        case direct
        case uncached
        case buffered
    }
}
