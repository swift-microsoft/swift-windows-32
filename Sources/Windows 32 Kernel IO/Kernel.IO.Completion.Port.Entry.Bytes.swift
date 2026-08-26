#if os(Windows)
    public import Error
    public import WinSDK

    extension Windows.`32`.Kernel.IO.Completion.Port.Entry {

        public struct Bytes: Sendable {
            @usableFromInline
            let entry: Windows.`32`.Kernel.IO.Completion.Port.Entry

            @usableFromInline
            init(entry: Windows.`32`.Kernel.IO.Completion.Port.Entry) {
                self.entry = entry
            }
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Entry.Bytes {

        @inlinable
        public var transferred: Windows.`32`.Kernel.File.Size {
            Windows.`32`.Kernel.File.Size(Int64(entry.raw.dwNumberOfBytesTransferred))
        }
    }

#endif
