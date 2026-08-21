extension Windows.`32`.Kernel.File.Stats {

    public enum Kind: Sendable, Equatable, Hashable {

        case regular

        case directory

        case link(Link)

        case device(Device)

        case fifo

        case socket

        case unknown
    }
}
