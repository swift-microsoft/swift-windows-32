#if os(Windows)

    extension Windows.`32`.Kernel.Permission.Error {

        @inlinable
        public init?(code: Error.Error.Code) {
            switch code {
            case .Windows.ERROR_ACCESS_DENIED:
                self = .denied

            case .Windows.ERROR_WRITE_PROTECT:
                self = .readOnlyFilesystem

            default:
                return nil
            }
        }
    }
#endif
