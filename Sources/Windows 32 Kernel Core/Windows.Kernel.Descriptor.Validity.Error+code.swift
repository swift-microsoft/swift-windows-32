#if os(Windows)

    extension Windows.`32`.Kernel.Descriptor.Validity.Error {

        @inlinable
        public init?(code: Error.Error.Code) {
            switch code {
            case .Windows.ERROR_INVALID_HANDLE:
                self = .invalid

            case .Windows.ERROR_TOO_MANY_OPEN_FILES:
                self = .limit(.process)

            default:
                return nil
            }
        }
    }

    extension Windows.`32`.Kernel.Descriptor.Validity.Error {

        @inlinable
        public var code: Error.Error.Code {
            switch self {
            case .invalid: return .Windows.ERROR_INVALID_HANDLE
            case .limit: return .Windows.ERROR_TOO_MANY_OPEN_FILES
            }
        }
    }
#endif
