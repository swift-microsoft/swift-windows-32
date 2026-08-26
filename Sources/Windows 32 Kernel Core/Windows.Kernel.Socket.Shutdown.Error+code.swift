#if os(Windows)

    extension Windows.`32`.Kernel.Socket.Shutdown.Error {

        @usableFromInline
        internal init(code: Error.Error.Code) {
            self = .platform(Error.Error(code: code))
        }
    }
#endif
