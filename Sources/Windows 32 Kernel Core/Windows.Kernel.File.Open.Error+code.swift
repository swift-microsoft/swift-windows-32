#if os(Windows)

    extension Windows.`32`.Kernel.File.Open.Error {

        @inlinable
        package init(code: Error_Primitives.Error.Code) {
            if let e = Path.Resolution.Error(code: code) {
                self = .path(e)
                return
            }
            if let e = Windows.`32`.Kernel.Descriptor.Validity.Error(code: code) {
                self = .handle(e)
                return
            }
            self = .platform(Error_Primitives.Error(code: code))
        }
    }
#endif
