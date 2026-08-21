public import Windows_32_Core

#if os(Windows)
    public import WinSDK

    extension Windows_32_Core.Windows.`32`.Kernel.Descriptor {

        public static func owning(handle: HANDLE) -> Self {
            Self(_rawValue: UInt(bitPattern: handle))
        }

        public var handle: HANDLE {
            HANDLE(bitPattern: _rawValue)!
        }
    }
#endif
