#if os(Windows)
    public import Error_Primitives
    public import WinSDK

    extension Windows.`32`.Kernel.IO.Completion.Port {

        @safe
        public struct Entry: @unchecked Sendable {

            @usableFromInline
            internal var raw: OVERLAPPED_ENTRY

            @inlinable
            public init() {
                raw = OVERLAPPED_ENTRY()
            }
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Entry {

        @unsafe
        @inlinable
        public var overlapped:
            UnsafeMutablePointer<Windows.`32`.Kernel.IO.Completion.Port.Overlapped>?
        {
            guard let rawPtr = unsafe raw.lpOverlapped else { return nil }
            return unsafe UnsafeMutableRawPointer(rawPtr)
                .assumingMemoryBound(to: Windows.`32`.Kernel.IO.Completion.Port.Overlapped.self)
        }

        @inlinable
        public var key: Windows.`32`.Kernel.IO.Completion.Port.Key {
            Windows.`32`.Kernel.IO.Completion.Port.Key(rawValue: raw.lpCompletionKey)
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Entry {

        public var bytes: Bytes { Bytes(entry: self) }
    }

#endif
