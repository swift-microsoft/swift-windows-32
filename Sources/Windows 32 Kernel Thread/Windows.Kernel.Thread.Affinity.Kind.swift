#if os(Windows)

    extension Windows.`32`.Kernel.Thread.Affinity {

        public enum Kind: Sendable, Equatable {

            case any

            case cores(Set<Int>)

            case numaNode(Int)
        }
    }

#endif
