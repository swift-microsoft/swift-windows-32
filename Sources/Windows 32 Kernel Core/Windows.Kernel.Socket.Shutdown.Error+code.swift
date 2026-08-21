#if os(Windows)

    extension Windows.`32`.Kernel.Socket.Shutdown.Error {

        @usableFromInline
        internal init(code: Error_Primitives.Error.Code) {
            self = .platform(Error_Primitives.Error(code: code))
        }
    }
#endif
