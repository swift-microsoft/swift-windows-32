import CPU

#if os(Windows)
    internal import WinSDK

    extension CPU.NUMA {

        /// The NUMA nodes up to `GetNumaHighestNodeNumber`, each with its processor mask.
        public static var state: State {
            var highest: ULONG = 0
            guard GetNumaHighestNodeNumber(&highest) else {
                return .unavailable
            }

            var nodes: [Node] = []

            (0...UInt(highest)).forEach { number in
                guard let processors = processors(of: USHORT(number)) else {
                    return
                }
                nodes.append(Node(id: Node.ID(_unchecked: Ordinal(number)), processors: processors))
            }

            switch nodes.count {
            case 0:
                return .unavailable

            case 1:
                return .uniform

            default:
                return .nonUniform(nodes: nodes)
            }
        }

        private static func processors(of node: USHORT) -> Set<CPU.Logical.ID>? {
            var affinity = GROUP_AFFINITY()

            guard GetNumaNodeProcessorMaskEx(node, &affinity) else {
                var mask: ULONGLONG = 0
                guard GetNumaNodeProcessorMask(UCHAR(node), &mask) else {
                    return nil
                }
                return processors(in: KAFFINITY(mask), group: 0)
            }

            return processors(in: affinity.Mask, group: UInt(affinity.Group))
        }

        private static func processors(in mask: KAFFINITY, group: UInt) -> Set<CPU.Logical.ID> {
            var processors = Set<CPU.Logical.ID>()
            var remaining = mask

            for bit in 0..<UInt(64) {
                if remaining & 1 != 0 {
                    processors.insert(CPU.Logical.ID(_unchecked: Ordinal(group * 64 + bit)))
                }
                remaining >>= 1
                if remaining == 0 { break }
            }

            return processors
        }
    }

#endif
