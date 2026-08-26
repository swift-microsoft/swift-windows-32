#if os(Windows)
    public import Error
    public import Memory
    public import WinSDK

    extension Memory.Map.Options {

        public static let shared = Self(rawValue: 1)

        public static let `private` = Self(rawValue: 2)

        public static let anonymous = Self(rawValue: 4)
    }

    extension Memory.Map.Options {

        @usableFromInline
        internal var isAnonymous: Bool {
            (rawValue & Self.anonymous.rawValue) != 0
        }

        @usableFromInline
        internal var isPrivate: Bool {
            (rawValue & Self.private.rawValue) != 0
        }

        @usableFromInline
        internal var isShared: Bool {
            (rawValue & Self.shared.rawValue) != 0
        }
    }

#endif
