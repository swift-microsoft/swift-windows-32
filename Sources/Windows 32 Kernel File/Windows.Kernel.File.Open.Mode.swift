#if os(Windows)
    public import WinSDK
#endif

extension Windows.`32`.Kernel.File.Open {

    public struct Mode: Sendable, Hashable {

        public let read: Bool

        public let write: Bool

        @inlinable
        public init(read: Bool, write: Bool) {
            self.read = read
            self.write = write
        }
    }
}

extension Windows.`32`.Kernel.File.Open.Mode {

    public static let read = Self(read: true, write: false)

    public static let write = Self(read: false, write: true)

    public static let readWrite = Self(read: true, write: true)
}

#if os(Windows)

    extension Windows.`32`.Kernel.File.Open.Mode {

        package var windowsDesiredAccess: DWORD {
            var access: DWORD = 0

            if read {
                access |= DWORD(GENERIC_READ)
            }
            if write {
                access |= DWORD(GENERIC_WRITE)
            }

            return access
        }
    }

#endif
