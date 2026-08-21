#if os(Windows)
    internal import WinSDK
#endif

extension Windows.`32`.Kernel.Process {

    public struct ID: RawRepresentable, Sendable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

#if os(Windows)
    extension Windows.`32`.Kernel.Process.ID {

        public static var current: Self {
            Self(Int32(bitPattern: GetCurrentProcessId()))
        }
    }
#endif
