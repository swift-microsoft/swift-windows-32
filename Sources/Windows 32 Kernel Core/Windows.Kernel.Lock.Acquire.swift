public import Clock_Primitives

extension Windows.`32`.Kernel.Lock {

    public enum Acquire: Sendable, Equatable {

        case `try`

        case wait

        case deadline(Clock.Continuous.Instant)
    }
}
