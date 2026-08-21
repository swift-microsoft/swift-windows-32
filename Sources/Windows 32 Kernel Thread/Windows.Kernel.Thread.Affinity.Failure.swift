#if os(Windows)

    extension Windows.`32`.Kernel.Thread.Affinity {

        public enum Failure: Sendable, Equatable {

            case ignore

            case report

            case fatal
        }
    }

#endif
