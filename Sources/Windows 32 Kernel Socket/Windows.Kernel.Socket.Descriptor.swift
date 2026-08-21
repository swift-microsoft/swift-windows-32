#if os(Windows)
    internal import WinSDK

    extension Windows.`32`.Kernel.Socket {

        public struct Descriptor: ~Copyable, Sendable {
            @usableFromInline
            package var _raw: UInt64

            @usableFromInline
            package init(_raw: UInt64) {
                self._raw = _raw
            }

            deinit {
                guard isValid else { return }
                #if os(Windows)
                    _ = unsafe closesocket(SOCKET(_raw))
                #endif
            }
        }
    }

    extension Windows.`32`.Kernel.Socket.Descriptor {

        public static var invalid: Self {
            Self(_raw: UInt64.max)
        }

        @inlinable
        public var isValid: Bool {
            _raw != UInt64.max
        }
    }

    extension Windows.`32`.Kernel.Socket.Descriptor {

        @inlinable
        package init(_rawValue: UInt) {
            self.init(_raw: UInt64(_rawValue))
        }

        @inlinable
        package var _rawValue: UInt { UInt(_raw) }
    }
#endif
