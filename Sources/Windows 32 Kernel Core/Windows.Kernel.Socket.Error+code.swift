#if os(Windows)

    extension Windows.`32`.Kernel.Socket.Error {

        @inlinable
        public var code: Error::Error.Code {
            switch self {
            case .platform(let e): return e.code
            }
        }
    }

    extension Windows.`32`.Kernel.Socket.Error {

        @inlinable
        public init(code: Error::Error.Code) {
            self = .platform(Error.Error(code: code))
        }
    }
#endif
