#if os(Windows)
    public import Loader_Primitives
    public import WinSDK

    extension Windows.Loader.Symbol {

        @unsafe
        public static func lookup(
            name: String,
            in scope: Loader.Symbol.Scope
        ) throws(Loader.Error) -> UnsafeRawPointer {
            let procAddress: FARPROC?

            switch unsafe scope {
            case .handle(let handle):
                procAddress = name.withCString { namePtr in
                    unsafe GetProcAddress(
                        handle.rawValue.assumingMemoryBound(to: HINSTANCE__.self),
                        namePtr
                    )
                }

            case .default:

                if let mainHandle = Windows.Loader.Library.getHandle(moduleName: nil) {
                    procAddress = name.withCString { namePtr in
                        unsafe GetProcAddress(
                            mainHandle.rawValue.assumingMemoryBound(to: HINSTANCE__.self),
                            namePtr
                        )
                    }
                } else {
                    procAddress = nil
                }

            case .next:

                throw .symbol(
                    Loader.Message(ascii: "RTLD_NEXT equivalent not available on Windows")
                )
            }

            guard let procAddress else {
                throw .symbol(captureLastErrorMessage())
            }

            return unsafe unsafeBitCast(procAddress, to: UnsafeRawPointer.self)
        }

        @unsafe
        public static func lookup(
            ordinal: UInt16,
            in handle: Loader.Library.Handle
        ) throws(Loader.Error) -> UnsafeRawPointer {

            let namePtr = UnsafePointer<CChar>(bitPattern: UInt(ordinal))
            let procAddress = unsafe GetProcAddress(
                handle.rawValue.assumingMemoryBound(to: HINSTANCE__.self),
                namePtr
            )

            guard let procAddress else {
                throw .symbol(captureLastErrorMessage())
            }

            return unsafe unsafeBitCast(procAddress, to: UnsafeRawPointer.self)
        }
    }

#endif
