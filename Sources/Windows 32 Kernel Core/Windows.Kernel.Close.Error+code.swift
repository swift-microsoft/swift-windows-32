#if os(Windows)

    extension Windows.`32`.Kernel.Close.Error {

        @inlinable
        public init(code: Error::Error.Code) {
            if let e = Windows.`32`.Kernel.Descriptor.Validity.Error(code: code) {
                self = .handle(e)
                return
            }
            self = .platform(Error.Error(code: code))
        }
    }
#endif
