#if os(Windows)
    internal import WinSDK
#endif

extension Windows.`32`.Kernel {

    public struct Descriptor: ~Copyable, Sendable {
        @usableFromInline
        package var _raw: UInt

        @usableFromInline
        package init(_raw: UInt) {
            self._raw = _raw
        }

        deinit {
            guard isValid else { return }
            #if os(Windows)
                guard let pointer = UnsafeMutableRawPointer(bitPattern: _raw) else { return }
                _ = unsafe CloseHandle(pointer)
            #endif
        }
    }
}

extension Windows.`32`.Kernel.Descriptor {

    public typealias RawValue = UInt

    public static var invalid: Self {
        Self(_raw: ~0)
    }

    @inlinable
    public var isValid: Bool {
        _raw != 0 && _raw != ~0
    }
}

extension Windows.`32`.Kernel.Descriptor {

    @inlinable
    public init(_rawValue: UInt) {
        self._raw = _rawValue
    }

    @inlinable
    public var _rawValue: UInt { _raw }
}
