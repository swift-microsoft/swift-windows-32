#if os(Windows)

    extension Windows.`32`.Kernel.Lock.Error {

        @inlinable
        public init?(code: Error_Primitives.Error.Code) {
            switch code {
            case .Windows.ERROR_LOCK_VIOLATION:
                self = .contention

            default:
                return nil
            }
        }

        @usableFromInline
        internal init(_ code: Error_Primitives.Error.Code) {
            if let mapped = Self(code: code) {
                self = mapped
            } else {
                self = .platform(code: code)
            }
        }
    }
#endif
