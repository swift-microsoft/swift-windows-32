#if os(Windows)
    public import Byte
    public import Error
    public import WinSDK

    extension Windows.`32`.Kernel.IO.Write {

        package static func write(
            _ handle: UInt,
            from buffer: UnsafeRawBufferPointer
        ) throws(Error) -> Int {
            guard let baseAddress = buffer.baseAddress else {
                return 0
            }
            guard let pointer = UnsafeMutableRawPointer(bitPattern: handle) else {
                throw .handle(.invalid)
            }

            var bytesWritten: DWORD = 0
            let success = WriteFile(
                pointer,
                baseAddress,
                DWORD(buffer.count),
                &bytesWritten,
                nil
            )

            guard success else {
                throw .current()
            }

            return Int(bytesWritten)
        }

        package static func pwrite(
            _ handle: UInt,
            from buffer: UnsafeRawBufferPointer,
            at offset: Windows.`32`.Kernel.File.Offset
        ) throws(Error) -> Int {
            guard let baseAddress = buffer.baseAddress else {
                return 0
            }
            guard let pointer = UnsafeMutableRawPointer(bitPattern: handle) else {
                throw .handle(.invalid)
            }

            var currentPos: LARGE_INTEGER = LARGE_INTEGER()
            var zero: LARGE_INTEGER = LARGE_INTEGER()
            zero.QuadPart = 0
            guard SetFilePointerEx(pointer, zero, &currentPos, DWORD(FILE_CURRENT)) else {
                throw .current()
            }

            var targetPos: LARGE_INTEGER = LARGE_INTEGER()
            targetPos.QuadPart = offset.underlying
            guard SetFilePointerEx(pointer, targetPos, nil, DWORD(FILE_BEGIN)) else {
                throw .current()
            }

            var bytesWritten: DWORD = 0
            let writeSuccess = WriteFile(
                pointer,
                baseAddress,
                DWORD(buffer.count),
                &bytesWritten,
                nil
            )

            _ = SetFilePointerEx(pointer, currentPos, nil, DWORD(FILE_BEGIN))

            guard writeSuccess else {
                throw .current()
            }

            return Int(bytesWritten)
        }
    }

    extension Windows.`32`.Kernel.IO.Write {

        public static func write(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
            from buffer: UnsafeRawBufferPointer
        ) throws(Error) -> Int {
            guard descriptor.isValid else {
                throw .handle(.invalid)
            }
            return try write(descriptor._rawValue, from: buffer)
        }

        public static func pwrite(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
            from buffer: UnsafeRawBufferPointer,
            at offset: Windows.`32`.Kernel.File.Offset
        ) throws(Error) -> Int {
            guard descriptor.isValid else {
                throw .handle(.invalid)
            }
            return try pwrite(descriptor._rawValue, from: buffer, at: offset)
        }
    }

    extension Windows.`32`.Kernel.IO.Write {

        public static func write(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
            from span: borrowing Swift.Span<Byte>
        ) throws(Error) -> Int {
            try unsafe span.withUnsafeBytes {
                (buffer: UnsafeRawBufferPointer) throws(Error) -> Int in
                try unsafe write(descriptor, from: buffer)
            }
        }

        @inlinable
        public static func write(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
            from span: Swift.Span<UInt8>
        ) throws(Error) -> Int {
            try span.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) throws(Error) -> Int in
                try write(descriptor, from: buffer)
            }
        }

        @inlinable
        public static func pwrite(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
            from span: Swift.Span<UInt8>,
            at offset: Windows.`32`.Kernel.File.Offset
        ) throws(Error) -> Int {
            try span.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) throws(Error) -> Int in
                try pwrite(descriptor, from: buffer, at: offset)
            }
        }
    }

    extension Windows.`32`.Kernel.IO.Write {
        public typealias Error = Windows.`32`.Kernel.IO.Write.Error
    }

    extension Windows.`32`.Kernel.IO.Write.Error {

        @usableFromInline
        internal static func current() -> Self {
            Self(code: Error::Error.captureLastError())
        }
    }

#endif
