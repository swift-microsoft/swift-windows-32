#if os(Windows)

    extension Error_Primitives.Error {

        public typealias Number = Tagged<Error_Primitives.Error, UInt32>
    }
#endif
