#if os(Windows)
    public import Error_Primitives
    public import Memory_Primitives

    extension Memory.Map {

        public static func advise(
            addr: Memory.Address,
            length: Memory.Address.Count,
            advice: Memory.Map.Advice
        ) {

        }

        @unsafe
        public static func advise(
            addr: UnsafeMutableRawPointer,
            length: Memory.Address.Count,
            advice: Memory.Map.Advice
        ) {

        }

        @unsafe
        public static func advise(
            addr: UnsafeRawPointer,
            length: Memory.Address.Count,
            advice: Memory.Map.Advice
        ) {

        }
    }

#endif
