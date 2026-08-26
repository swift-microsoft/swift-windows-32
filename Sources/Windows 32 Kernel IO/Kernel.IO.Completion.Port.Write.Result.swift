#if os(Windows)
    public import Error

    extension Windows.`32`.Kernel.IO.Completion.Port.Write {

        public enum Result: Sendable, Equatable {

            case pending

            case completed(bytes: UInt32)
        }
    }

#endif
