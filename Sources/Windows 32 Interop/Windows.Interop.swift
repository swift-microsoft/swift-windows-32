#if os(Windows)
    public import WinSDK
    public import Windows_32_Core

    extension Windows_32_Core.Windows {

        public enum Interop {}
    }

    extension Windows_32_Core.Windows.Interop {

        @inline(always)
        package static func dword(_ value: UInt32) -> DWORD { value }

        @inline(always)
        package static func dword(_ value: Int32) -> DWORD { DWORD(bitPattern: value) }
    }

    extension Windows_32_Core.Windows.Interop {

        @inline(always)
        package static func mask(_ value: UInt32) -> DWORD { value }

        @inline(always)
        package static func mask(_ value: Int32) -> DWORD { DWORD(bitPattern: value) }
    }

    extension Windows_32_Core.Windows.Interop {

        @inline(always)
        public static func ok(_ value: Bool) -> Bool { value }

        @inline(always)
        public static func ok(_ value: BOOLEAN) -> Bool { value != 0 }
    }
#endif
