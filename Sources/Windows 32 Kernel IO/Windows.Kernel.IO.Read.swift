#if os(Windows)
    public import Byte
    public import Error
    public import WinSDK

    extension Windows.`32`.Kernel.IO.Read {

        package static func read(
            _ handle: UInt,
            into buffer: UnsafeMutableRawBufferPointer
        ) throws(Error) -> Int {
            guard let baseAddress = buffer.baseAddress else {
                return 0
            }
            guard let pointer = UnsafeMutableRawPointer(bitPattern: handle) else {
                throw .handle(.invalid)
            }

            var bytesRead: DWORD = 0
            let success = ReadFile(
                pointer,
                baseAddress,
                DWORD(buffer.count),
                &bytesRead,
                nil
            )

            if !success {
                let error = GetLastError()

                if error == Error::Error.Code.IO.handleEOF {
                    return 0
                }
                throw .current()
            }

            return Int(bytesRead)
        }

        package static func pread(
            _ handle: UInt,
            into buffer: UnsafeMutableRawBufferPointer,
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

            var bytesRead: DWORD = 0
            let readSuccess = ReadFile(
                pointer,
                baseAddress,
                DWORD(buffer.count),
                &bytesRead,
                nil
            )

            _ = SetFilePointerEx(pointer, currentPos, nil, DWORD(FILE_BEGIN))

            if !readSuccess {
                let error = GetLastError()
                if error == Error::Error.Code.IO.handleEOF {
                    return 0
                }
                throw .current()
            }

            return Int(bytesRead)
        }
    }

    extension Windows.`32`.Kernel.IO.Read {

        public static func read(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
            into buffer: UnsafeMutableRawBufferPointer
        ) throws(Error) -> Int {
            guard descriptor.isValid else {
                throw .handle(.invalid)
            }
            return try read(descriptor._rawValue, into: buffer)
        }

        public static func pread(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
            into buffer: UnsafeMutableRawBufferPointer,
            at offset: Windows.`32`.Kernel.File.Offset
        ) throws(Error) -> Int {
            guard descriptor.isValid else {
                throw .handle(.invalid)
            }
            return try pread(descriptor._rawValue, into: buffer, at: offset)
        }
    }

    extension Windows.`32`.Kernel.IO.Read {

        public static func read(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
            into output: inout Swift.OutputSpan<Byte>
        ) throws(Error) -> Int {
            try unsafe output.withUnsafeMutableBufferPointer {
                buffer,
                initializedCount throws(Error) -> Int in
                guard initializedCount < buffer.count else { return 0 }

                let bytes = unsafe UnsafeMutableRawBufferPointer(buffer)
                let offset = initializedCount * MemoryLayout<Byte>.stride
                let free = unsafe UnsafeMutableRawBufferPointer(
                    rebasing: bytes[offset..<bytes.count]
                )
                let read = try unsafe read(descriptor, into: free)
                initializedCount += read
                return read
            }
        }

        @inlinable
        public static func read(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
            into span: inout MutableSpan<UInt8>
        ) throws(Error) -> Int {
            try span.withUnsafeMutableBytes {
                (buffer: UnsafeMutableRawBufferPointer) throws(Error) -> Int in
                try read(descriptor, into: buffer)
            }
        }

        @inlinable
        public static func pread(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
            into span: inout MutableSpan<UInt8>,
            at offset: Windows.`32`.Kernel.File.Offset
        ) throws(Error) -> Int {
            try span.withUnsafeMutableBytes {
                (buffer: UnsafeMutableRawBufferPointer) throws(Error) -> Int in
                try pread(descriptor, into: buffer, at: offset)
            }
        }
    }

    extension Windows.`32`.Kernel.IO.Read {
        public typealias Error = Windows.`32`.Kernel.IO.Read.Error
    }

    extension Windows.`32`.Kernel.IO.Read.Error {

        @usableFromInline
        internal static func current() -> Self {
            Self(code: Error.Error.captureLastError())
        }
    }

#endif
