#if os(Windows)

    extension Windows.`32`.Kernel.File.Direct.Error {

        @usableFromInline
        internal init(code: Error_Primitives.Error.Code, operation: Operation) {

            self = .platform(code: code, operation: operation)
        }
    }
#endif
