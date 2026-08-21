#if os(Windows)
    extension Windows.`32`.Kernel.Socket.Connect {

        public enum Start: Sendable, Equatable {

            case connected

            case pending
        }
    }
#endif
