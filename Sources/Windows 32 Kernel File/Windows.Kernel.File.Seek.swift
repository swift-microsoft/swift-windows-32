#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.File.Seek {

        @discardableResult
        package static func seek(
            _ handle: UInt,
            offset: Int64,
            origin: Origin
        ) throws(Error) -> Int64 {
            var distance: LARGE_INTEGER = LARGE_INTEGER()
            distance.QuadPart = offset

            var newPosition: LARGE_INTEGER = LARGE_INTEGER()
            let success = SetFilePointerEx(
                UnsafeMutableRawPointer(bitPattern: handle)!,
                distance,
                &newPosition,
                origin.windowsMoveMethod
            )

            guard success else {
                throw Error.current()
            }

            return newPosition.QuadPart
        }

        package static func tell(_ handle: UInt) throws(Error) -> Int64 {
            try seek(handle, offset: 0, origin: .current)
        }
    }

    extension Windows.`32`.Kernel.File.Seek {

        @discardableResult
        public static func seek(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
            offset: Int64,
            origin: Origin
        ) throws(Error) -> Int64 {
            guard descriptor.isValid else {
                throw .invalidDescriptor
            }
            return try seek(descriptor._rawValue, offset: offset, origin: origin)
        }

        public static func tell(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor
        ) throws(Error) -> Int64 {
            guard descriptor.isValid else {
                throw .invalidDescriptor
            }
            return try tell(descriptor._rawValue)
        }
    }

    extension Windows.`32`.Kernel.File.Seek.Origin {

        @usableFromInline
        package var windowsMoveMethod: DWORD {
            switch self {
            case .start:
                return DWORD(FILE_BEGIN)

            case .current:
                return DWORD(FILE_CURRENT)

            case .end:
                return DWORD(FILE_END)
            }
        }
    }

    extension Windows.`32`.Kernel.File.Seek {
        public typealias Error = Windows.`32`.Kernel.File.Seek.Error
        public typealias Origin = Windows.`32`.Kernel.File.Seek.Origin
    }

    extension Windows.`32`.Kernel.File.Seek.Error {

        internal static func current() -> Self {
            let code = Error.Error.captureLastError()
            guard let win32Code = code.win32 else {
                return .platform(code: code)
            }

            switch win32Code {
            case Error::Error.Code.Handle.invalid:
                return .invalidDescriptor

            case Error::Error.Code.General.invalidParameter:
                return .negativeOffset

            case Error::Error.Code.IO.brokenPipe:
                return .notSeekable

            default:
                return .platform(code: code)
            }
        }
    }

#endif
