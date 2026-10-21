public import Windows_32_Core

#if os(Windows)
    public import WinSDK

    extension Windows_32_Core.Windows.`32`.Kernel.Descriptor {

        public static func owning(handle: HANDLE) -> Self {
            Self(_rawValue: UInt(bitPattern: handle))
        }

        public var handle: HANDLE {
            Self.handle(from: _rawValue)
        }

        /// Reconstructs the `HANDLE` for a raw descriptor value.
        ///
        /// A zero raw value is never a valid descriptor, so it traps.
        @inlinable
        package static func handle(from rawValue: UInt) -> HANDLE {
            guard let handle = HANDLE(bitPattern: rawValue) else {
                preconditionFailure("Descriptor raw value 0 is not a valid HANDLE")
            }
            return handle
        }
    }
#endif
