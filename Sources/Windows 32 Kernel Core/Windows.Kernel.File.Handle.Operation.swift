extension Windows.`32`.Kernel.File.Handle {

    public enum Operation: Swift.String, Sendable {
        case read
        case write
        case seek
        case sync
    }
}
