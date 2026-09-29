#if os(Windows)

    extension Error::Error {

        public typealias Number = Tagged<Error::Error, UInt32>
    }
#endif
