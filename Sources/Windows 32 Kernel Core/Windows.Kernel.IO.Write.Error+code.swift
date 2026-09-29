#if os(Windows)

    extension Windows.`32`.Kernel.IO.Write.Error {

        @inlinable
        public var code: Error::Error.Code {
            switch self {
            case .handle(let e): return e.code
            case .blocking: return .Windows.ERROR_NOT_SUPPORTED
            case .platform(let e): return e.code
            }
        }
    }

    extension Windows.`32`.Kernel.IO.Write.Error {

        @inlinable
        public init(code: Error::Error.Code) {
            if let e = Windows.`32`.Kernel.Descriptor.Validity.Error(code: code) {
                self = .handle(e)
                return
            }
            if let e = Windows.`32`.Kernel.IO.Blocking.Error(code: code) {
                self = .blocking(e)
                return
            }
            self = .platform(Error::Error(code: code))
        }
    }
#endif
