#if os(Windows)
    public import Error_Primitives
    public import Memory_Primitives

    extension Memory.Map.Advice {

        public static var normal: Self {
            Self(rawValue: 0)
        }

        public static var sequential: Self {
            Self(rawValue: 1)
        }

        public static var random: Self {
            Self(rawValue: 2)
        }

        public static var willNeed: Self {
            Self(rawValue: 3)
        }

        public static var dontNeed: Self {
            Self(rawValue: 4)
        }
    }

#endif
