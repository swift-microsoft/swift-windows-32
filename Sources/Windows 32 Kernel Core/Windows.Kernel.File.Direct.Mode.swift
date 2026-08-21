extension Windows.`32`.Kernel.File.Direct {

    public enum Mode: Sendable, Equatable {

        case direct

        case uncached

        case buffered

        case auto(policy: Policy)
    }
}

extension Windows.`32`.Kernel.File.Direct.Mode {

    public func resolve(
        given requirements: Windows.`32`.Kernel.File.Direct.Requirements
    ) throws(Windows.`32`.Kernel.File.Direct.Error) -> Resolved {
        switch self {
        case .buffered:
            return .buffered

        case .uncached:

            return .buffered

        case .direct:
            guard case .known = requirements else {
                throw .notSupported
            }
            return .direct

        case .auto(let policy):
            if case .known = requirements {
                return .direct
            }
            switch policy {
            case .fallbackToBuffered:
                return .buffered

            case .errorOnViolation:
                throw .notSupported
            }
        }
    }
}
