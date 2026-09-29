#if os(Windows)

    public import Path

    extension Path.Resolution.Error {

        @inlinable
        public init?(code: Error::Error.Code) {
            switch code {
            case .Windows.ERROR_FILE_NOT_FOUND, .Windows.ERROR_PATH_NOT_FOUND:
                self = .notFound

            case .Windows.ERROR_FILE_EXISTS, .Windows.ERROR_ALREADY_EXISTS:
                self = .exists

            case .Windows.ERROR_DIRECTORY:
                self = .isDirectory

            case .Windows.ERROR_DIR_NOT_EMPTY:
                self = .notEmpty

            case .Windows.ERROR_NOT_SAME_DEVICE:
                self = .crossDevice

            case .Windows.ERROR_CANT_RESOLVE_FILENAME:
                self = .loop

            case .Windows.ERROR_FILENAME_EXCED_RANGE:
                self = .nameTooLong

            default:
                return nil
            }
        }
    }
#endif
