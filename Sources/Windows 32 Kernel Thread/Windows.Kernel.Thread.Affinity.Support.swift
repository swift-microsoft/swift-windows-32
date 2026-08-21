#if os(Windows)

    extension Windows.`32`.Kernel.Thread.Affinity {

        public enum Support: Sendable, Equatable {

            case none

            case advisory

            case enforced
        }
    }

#endif
