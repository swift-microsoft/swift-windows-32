#if os(Windows)
    public import Error_Primitives
    public import WinSDK

    extension Windows.`32`.Kernel.IO.Completion.Port {

        @safe
        public struct Overlapped: @unchecked Sendable {

            @usableFromInline
            internal var raw: OVERLAPPED

            @inlinable
            public init() {
                raw = OVERLAPPED()
            }
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Overlapped {

        @inlinable
        public var offset: Int64 {
            get { Int64(raw.Offset) | (Int64(raw.OffsetHigh) << 32) }
            set {
                raw.Offset = DWORD(truncatingIfNeeded: newValue)
                raw.OffsetHigh = DWORD(truncatingIfNeeded: newValue >> 32)
            }
        }
    }

#endif
