#if os(Windows)

    extension Windows.`32`.Kernel.File.Clone.Error {

        public init(from syscall: Syscall) {
            switch syscall {
            case .notSupported:
                self = .notSupported

            case .platform(let code, let operation):
                self.init(code: code, operation: operation)
            }
        }

        @_spi(Syscall)
        public init(code: Error_Primitives.Error.Code, operation: Operation) {
            switch code {
            case _ where code == .Windows.ERROR_FILE_NOT_FOUND:
                self = .sourceNotFound

            case _ where code == .Windows.ERROR_FILE_EXISTS,
                _ where code == .Windows.ERROR_ALREADY_EXISTS:
                self = .destinationExists

            case _ where code == .Windows.ERROR_ACCESS_DENIED:
                self = .permissionDenied

            case _ where code == .Windows.ERROR_NOT_SAME_DEVICE:
                self = .crossDevice

            default:
                self = .platform(code: code, operation: operation)
            }
        }
    }
#endif
