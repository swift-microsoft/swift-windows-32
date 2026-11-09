#if os(Windows)
    public import Error
    public import WinSDK

    extension Windows.`32`.Kernel.Thread {

        public final class Index: @unchecked Sendable {
            private var index: DWORD

            public init() throws(Windows.`32`.Kernel.Thread.Error) {
                let index = TlsAlloc()
                guard index != DWORD.max else {
                    throw .index(Error::Error(code: Error::Error.captureLastError()))
                }
                self.index = index
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
