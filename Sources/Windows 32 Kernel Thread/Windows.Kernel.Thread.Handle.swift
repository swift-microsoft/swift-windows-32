#if os(Windows)

    extension Windows.`32`.Kernel.Thread {

        public struct Handle: Sendable, RawRepresentable, Hashable {

            public let rawValue: UInt

            @inlinable
            public init(rawValue: UInt) {
                self.rawValue = rawValue
            }
        }
    }

#endif
