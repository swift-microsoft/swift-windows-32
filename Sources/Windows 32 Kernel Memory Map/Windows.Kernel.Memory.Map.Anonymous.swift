#if os(Windows)
    public import Error
    public import Memory
    public import WinSDK

    extension Memory.Map.Anonymous {

        public static func map(
            length: Memory.Address.Count,
            protection: Memory.Map.Protection = [.read, .write]
        ) throws(Memory.Map.Error) -> Memory.Map.Region {
            let addr = try Memory.Map.mapAnonymous(
                length: length,
                protection: protection
            )

            return Memory.Map.Region(base: addr, length: length)
        }

        public static func map(
            addr: Memory.Address,
            length: Memory.Address.Count,
            protection: Memory.Map.Protection
        ) throws(Memory.Map.Error) -> Memory.Map.Region {
            let mappedAddr = try Memory.Map.mapAnonymous(
                addr: addr,
                length: length,
                protection: protection
            )

            return Memory.Map.Region(base: mappedAddr, length: length)
        }
    }

#endif
