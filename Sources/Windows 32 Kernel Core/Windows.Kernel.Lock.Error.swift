extension Windows.`32`.Kernel.Lock {

    public enum Error: Swift.Error, Sendable, Equatable, Hashable {

        case contention

        case deadlock

        case unavailable

        case timedOut

        case interrupted

        case invalidRange(start: Int64, end: Int64)

        case platform(code: Error::Error.Code)
    }
}

extension Windows.`32`.Kernel.Lock.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .contention: return "lock contention"
        case .deadlock: return "deadlock detected"
        case .unavailable: return "no locks available"
        case .timedOut: return "lock acquisition timed out"
        case .interrupted: return "lock wait interrupted"

        case .invalidRange(let start, let end):
            return "invalid lock range: start \(start), end \(end)"

        case .platform(let code): return "platform error \(code)"
        }
    }
}

extension Windows.`32`.Kernel.Lock.Error {

    public static let wouldBlock = Self.contention
}
