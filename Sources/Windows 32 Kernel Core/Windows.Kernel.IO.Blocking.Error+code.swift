#if os(Windows)

    extension Windows.`32`.Kernel.IO.Blocking.Error {

        @inlinable
        public init?(code: Error_Primitives.Error.Code) {
            return nil
        }
    }
#endif
