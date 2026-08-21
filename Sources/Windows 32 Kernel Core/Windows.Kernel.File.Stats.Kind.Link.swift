extension Windows.`32`.Kernel.File.Stats.Kind {

    public enum Link: Sendable, Equatable, Hashable {

        case symbolic

        case junction
    }
}
