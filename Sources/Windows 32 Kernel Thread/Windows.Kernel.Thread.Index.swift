#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.Thread {

        public final class Index: @unchecked Sendable {
            private var index: DWORD

            public init() {
                self.index = TlsAlloc()
            }

            deinit {
                _ = TlsFree(index)
            }
        }
    }

    extension Windows.`32`.Kernel.Thread.Index {

        public var value: UnsafeMutableRawPointer? {
            get {
                TlsGetValue(index)
            }
            set {
                _ = TlsSetValue(index, newValue)
            }
        }
    }

#endif
