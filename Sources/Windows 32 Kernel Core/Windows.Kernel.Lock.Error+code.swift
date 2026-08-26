#if os(Windows)

    extension Windows.`32`.Kernel.Lock.Error {

        @inlinable
        public init?(code: Error.Error.Code) {
            switch code {
            case .Windows.ERROR_LOCK_VIOLATION:
                self = .contention

            default:
                return nil
            }
        }

        @usableFromInline
        internal init(_ code: Error.Error.Code) {
            if let mapped = Self(code: code) {
                self = mapped
            } else {
                self = .platform(code: code)
            }
        }
    }
#endif
