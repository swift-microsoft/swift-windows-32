#if os(Windows)

    extension Windows.`32`.Kernel.IO.Error {

        @inlinable
        public init?(code: Error::Error.Code) {
            switch code {
            case .Windows.ERROR_BROKEN_PIPE:
                self = .broken

            case .win32(1167):
                self = .hardware

            default:
                return nil
            }
        }
    }
#endif
