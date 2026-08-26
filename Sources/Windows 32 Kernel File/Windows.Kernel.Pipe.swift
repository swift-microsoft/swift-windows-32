public import Pair

#if os(Windows)
    internal import WinSDK
#endif

extension Windows.`32`.Kernel.Pipe {

    public typealias Descriptors = Tagged<
        Windows.`32`.Kernel.Pipe,
        Pair<Windows.`32`.Kernel.Descriptor, Windows.`32`.Kernel.Descriptor>
    >
}

extension Tagged
where
    Tag == Windows.`32`.Kernel.Pipe,
    Underlying == Pair<Windows.`32`.Kernel.Descriptor, Windows.`32`.Kernel.Descriptor>
{

    public var read: Windows.`32`.Kernel.Descriptor {
        @inlinable _read { yield underlying.first }
    }

    public var write: Windows.`32`.Kernel.Descriptor {
        @inlinable _read { yield underlying.second }
    }

    @inlinable
    package init(
        read: consuming Windows.`32`.Kernel.Descriptor,
        write: consuming Windows.`32`.Kernel.Descriptor
    ) {
        self.init(_unchecked: Pair(read, write))
    }
}

extension Windows.`32`.Kernel.Pipe {

    public static func pipe() throws(Error) -> Descriptors {
        #if os(Windows)
            var readHandle: HANDLE? = nil
            var writeHandle: HANDLE? = nil

            var security = SECURITY_ATTRIBUTES()
            security.nLength = DWORD(MemoryLayout<SECURITY_ATTRIBUTES>.size)
            security.bInheritHandle = true
            security.lpSecurityDescriptor = nil

            guard unsafe CreatePipe(&readHandle, &writeHandle, &security, 0) else {
                throw Error.current()
            }

            guard let read = readHandle, let write = writeHandle else {
                throw Error.current()
            }

            return Descriptors(
                read: Windows.`32`.Kernel.Descriptor(_raw: UInt(bitPattern: read)),
                write: Windows.`32`.Kernel.Descriptor(_raw: UInt(bitPattern: write))
            )
        #else

            throw Error.platform(Error.Error(code: .win32(0)))
        #endif
    }
}

extension Windows.`32`.Kernel.Pipe.Error {

    @usableFromInline
    internal static func current() -> Self {
        #if os(Windows)
            return Self(code: Error.Error.captureLastError())
        #else
            return .platform(Error.Error(code: .win32(0)))
        #endif
    }
}
