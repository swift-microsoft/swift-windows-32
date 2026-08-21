#if os(Windows)

    extension Windows.`32`.Kernel.File.Control.Error {

        @usableFromInline
        internal init(code: Error_Primitives.Error.Code) {
            if let e = Windows.`32`.Kernel.Descriptor.Validity.Error(code: code) {
                self = .handle(e)
                return
            }
            self = .platform(Error_Primitives.Error(code: code))
        }
    }
#endif
