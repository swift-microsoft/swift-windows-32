#if os(Windows)

    extension Windows.`32`.Kernel.File.Flush.Error {

        @inlinable
        public var code: Error.Error.Code {
            switch self {
            case .handle(let e): return e.code
            case .platform(let e): return e.code
            }
        }
    }
#endif
