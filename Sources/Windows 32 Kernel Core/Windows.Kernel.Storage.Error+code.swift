#if os(Windows)

    extension Windows.`32`.Kernel.Storage.Error {

        @inlinable
        public init?(code: Error_Primitives.Error.Code) {
            switch code {
            case .Windows.ERROR_DISK_FULL:
                self = .exhausted

            default:
                return nil
            }
        }
    }
#endif
