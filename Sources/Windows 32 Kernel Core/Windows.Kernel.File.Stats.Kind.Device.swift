extension Windows.`32`.Kernel.File.Stats.Kind {

    public enum Device: Sendable, Equatable, Hashable {

        case block

        case character
    }
}
