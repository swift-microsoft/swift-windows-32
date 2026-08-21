#if os(Windows)

    public import WinSDK

    extension Windows.`32`.Kernel.Thread {

        public struct ID: Hashable, Sendable, RawRepresentable, CustomStringConvertible {

            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Windows.`32`.Kernel.Thread.ID {
        public var description: String { "tid(\(rawValue))" }
    }

    extension Windows.`32`.Kernel.Thread.ID {

        public static var current: Self {
            .init(rawValue: UInt32(unsafe GetCurrentThreadId()))
        }
    }

#endif
