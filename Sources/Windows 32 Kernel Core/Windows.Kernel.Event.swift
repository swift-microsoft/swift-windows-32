#if os(Windows)
    internal import WinSDK

    extension Windows.`32`.Kernel {
        public struct Event: ~Copyable, Sendable {
            private let descriptor: Descriptor

            public init() throws(Windows.`32`.Kernel.Event.Error) {
                guard let handle = unsafe CreateEventW(nil, true, false, nil) else {
                    throw .platform(.win32(unsafe GetLastError()))
                }
                descriptor = Descriptor(_raw: UInt(bitPattern: handle))
            }
        }
    }

    extension Windows.`32`.Kernel.Event {
        public func signal() throws(Error) {
            let handle = unsafe HANDLE(bitPattern: descriptor._raw)
            guard unsafe SetEvent(handle) else {
                throw .platform(.win32(unsafe GetLastError()))
            }
        }

        public func wait(timeout: UInt32) throws(Error) -> Bool {
            let handle = unsafe HANDLE(bitPattern: descriptor._raw)
            switch unsafe WaitForSingleObject(handle, timeout) {
            case UInt32(WAIT_OBJECT_0): return true
            case UInt32(WAIT_TIMEOUT): return false
            default: throw .platform(.win32(unsafe GetLastError()))
            }
        }
    }
#endif
