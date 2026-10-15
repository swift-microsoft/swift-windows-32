public import System_Primitives

#if os(Windows)
    internal import WinSDK

    extension System.Topology.NUMA {

        public static func discover() -> System.Topology.NUMA.State {
            var highestNode: ULONG = 0
            guard GetNumaHighestNodeNumber(&highestNode) else {
                return .unavailable
            }

            var nodes: [System.Topology.NUMA.Node] = []

            for nodeID in 0...Int(highestNode) {
                guard let cpus = getCPUsForNode(UCHAR(nodeID)) else {
                    continue
                }

                nodes.append(
                    System.Topology.NUMA.Node(
                        id: nodeID,
                        cpus: cpus,
                        isSynthetic: false
                    )
                )
            }

            switch nodes.count {
            case 0:
                return .unavailable

            case 1:
                return .uniformAccess

            default:
                return .nonUniform(nodes: nodes)
            }
        }

        private static func getCPUsForNode(_ nodeNumber: UCHAR) -> Set<Int>? {
            var groupAffinity = GROUP_AFFINITY()

            guard GetNumaNodeProcessorMaskEx(USHORT(nodeNumber), &groupAffinity) else {
                var mask: ULONGLONG = 0
                guard GetNumaNodeProcessorMask(nodeNumber, &mask) else {
                    return nil
                }
                return maskToCPUSet(mask, groupOffset: 0)
            }

            let groupOffset = Int(groupAffinity.Group) * 64
            return maskToCPUSet(groupAffinity.Mask, groupOffset: groupOffset)
        }

        private static func maskToCPUSet(_ mask: KAFFINITY, groupOffset: Int) -> Set<Int> {
            var cpus = Set<Int>()
            var remaining = mask

            for bit in 0..<64 {
                if remaining & 1 != 0 {
                    cpus.insert(groupOffset + bit)
                }
                remaining >>= 1
                if remaining == 0 { break }
            }

            return cpus
        }
    }
#else
    extension System.Topology.NUMA {

        public static func discover() -> System.Topology.NUMA.State {
            .unavailable
        }
    }
#endif
