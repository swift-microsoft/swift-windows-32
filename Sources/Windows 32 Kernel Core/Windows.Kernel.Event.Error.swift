#if os(Windows)
    public import Error

    extension Windows.`32`.Kernel.Event {
        public enum Error: Swift.Error, Sendable, Equatable {
            case platform(Error::Error.Code)
        }
    }
#endif
