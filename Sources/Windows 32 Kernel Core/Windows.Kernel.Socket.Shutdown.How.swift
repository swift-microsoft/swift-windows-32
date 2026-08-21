extension Windows.`32`.Kernel.Socket.Shutdown {

    public enum How: Int32, Sendable {

        case read = 0

        case write = 1

        case both = 2
    }
}
