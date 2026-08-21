extension Windows.`32`.Kernel.File.Direct.Mode {

    public enum Policy: Sendable, Equatable {

        case fallbackToBuffered

        case errorOnViolation
    }
}
