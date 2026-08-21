#if os(Windows)
    public import Error_Primitives

    extension Windows.`32`.Kernel.IO.Completion.Port.Read {

        public enum Result: Sendable, Equatable {

            case pending

            case completed(bytes: UInt32)
        }
    }

#endif
