#if os(Windows)

    extension Windows.`32`.Kernel.File.System.Stats.Error {

        @usableFromInline
        internal init(code: Error::Error.Code) {
            if let e = Path.Resolution.Error(code: code) {
                self = .path(e)
                return
            }
            if let e = Windows.`32`.Kernel.Descriptor.Validity.Error(code: code) {
                self = .handle(e)
                return
            }
            self = .platform(Error.Error(code: code))
        }
    }
#endif
