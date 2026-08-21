#if os(Windows)
    public import Memory_Primitives

    extension Memory.Shared {

        public struct Options: OptionSet, Sendable, Hashable {
            public let rawValue: UInt8

            @inlinable
            public init(rawValue: UInt8) {
                self.rawValue = rawValue
            }
        }
    }

    extension Memory.Shared.Options {

        public static let create = Self(rawValue: 1 << 0)

        public static let exclusive = Self(rawValue: 1 << 1)

        public static let truncate = Self(rawValue: 1 << 2)
    }
#endif
