#if os(Windows)
    public import Error
    public import WinSDK

    extension Windows.`32`.Kernel.IO.Completion {

        public enum Port {

        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port {

        @inlinable
        public static func create(
            threads: UInt32 = 0
        ) throws(Error) -> Windows.`32`.Kernel.Descriptor {
            let handle = CreateIoCompletionPort(
                INVALID_HANDLE_VALUE,
                nil,
                0,
                DWORD(threads)
            )
            guard let handle, handle != INVALID_HANDLE_VALUE else {
                throw .create(Error::Error.captureLastError())
            }
            return Windows.`32`.Kernel.Descriptor(_raw: UInt(bitPattern: handle))
        }

        @inlinable
        package static func associate(
            _ port: UInt,
            handle: UInt,
            key: Key
        ) throws(Error) {
            let result = CreateIoCompletionPort(
                UnsafeMutableRawPointer(bitPattern: handle)!,
                UnsafeMutableRawPointer(bitPattern: port)!,
                key.rawValue,
                0
            )
            guard result != nil else {
                throw .associate(Error::Error.captureLastError())
            }
        }

        @unsafe
        @inlinable
        package static func post(
            _ port: UInt,
            bytes: DWORD = 0,
            key: Key = .zero,
            overlapped: LPOVERLAPPED? = nil
        ) throws(Error) {
            let result = unsafe PostQueuedCompletionStatus(
                UnsafeMutableRawPointer(bitPattern: port)!,
                bytes,
                key.rawValue,
                overlapped
            )
            guard result else {
                throw .post(Error::Error.captureLastError())
            }
        }

        @unsafe
        @inlinable
        package static func read(
            _ handle: UInt,
            into buffer: UnsafeMutableRawBufferPointer,
            overlapped: UnsafeMutablePointer<Overlapped>
        ) throws(Error) -> Read.Result {
            var count: DWORD = 0
            let success = unsafe withUnsafeMutablePointer(to: &overlapped.pointee.raw) { rawPtr in
                ReadFile(
                    UnsafeMutableRawPointer(bitPattern: handle)!,
                    buffer.baseAddress,
                    DWORD(buffer.count),
                    &count,
                    rawPtr
                )
            }

            if success {
                return .completed(bytes: count)
            }

            let error = GetLastError()
            if error == Error.Code.IO.pending {
                return .pending
            }

            throw .read(.win32(UInt32(error)))
        }

        @unsafe
        @inlinable
        package static func write(
            _ handle: UInt,
            from buffer: UnsafeRawBufferPointer,
            overlapped: UnsafeMutablePointer<Overlapped>
        ) throws(Error) -> Write.Result {
            var count: DWORD = 0
            let success = unsafe withUnsafeMutablePointer(to: &overlapped.pointee.raw) { rawPtr in
                WriteFile(
                    UnsafeMutableRawPointer(bitPattern: handle)!,
                    buffer.baseAddress,
                    DWORD(buffer.count),
                    &count,
                    rawPtr
                )
            }

            if success {
                return .completed(bytes: count)
            }

            let error = GetLastError()
            if error == Error.Code.IO.pending {
                return .pending
            }

            throw .write(.win32(UInt32(error)))
        }

        @inlinable
        package static func result(
            _ handle: UInt,
            overlapped: inout Overlapped,
            wait: Bool = false
        ) throws(Error) -> UInt32 {
            var count: DWORD = 0
            let success = unsafe withUnsafeMutablePointer(to: &overlapped.raw) { rawPtr in
                GetOverlappedResult(
                    UnsafeMutableRawPointer(bitPattern: handle)!,
                    rawPtr,
                    &count,
                    wait
                )
            }

            if success {
                return count
            }

            throw .result(Error::Error.captureLastError())
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port {

        @inlinable
        public static func associate(
            _ port: borrowing Windows.`32`.Kernel.Descriptor,
            handle: borrowing Windows.`32`.Kernel.Descriptor,
            key: Key
        ) throws(Error) {
            try associate(port._rawValue, handle: handle._rawValue, key: key)
        }

        @unsafe
        @inlinable
        public static func post(
            _ port: borrowing Windows.`32`.Kernel.Descriptor,
            bytes: DWORD = 0,
            key: Key = .zero,
            overlapped: LPOVERLAPPED? = nil
        ) throws(Error) {
            try unsafe post(port._rawValue, bytes: bytes, key: key, overlapped: overlapped)
        }

        public static func close(_ port: consuming Windows.`32`.Kernel.Descriptor) {
            do throws(Windows.`32`.Kernel.Close.Error) {
                try Windows.`32`.Kernel.Close.close(port)
            } catch {

            }
        }

        @unsafe
        @inlinable
        public static func read(
            _ handle: borrowing Windows.`32`.Kernel.Descriptor,
            into buffer: UnsafeMutableRawBufferPointer,
            overlapped: UnsafeMutablePointer<Overlapped>
        ) throws(Error) -> Read.Result {
            try unsafe read(handle._rawValue, into: buffer, overlapped: overlapped)
        }

        @unsafe
        @inlinable
        public static func write(
            _ handle: borrowing Windows.`32`.Kernel.Descriptor,
            from buffer: UnsafeRawBufferPointer,
            overlapped: UnsafeMutablePointer<Overlapped>
        ) throws(Error) -> Write.Result {
            try unsafe write(handle._rawValue, from: buffer, overlapped: overlapped)
        }

        @inlinable
        public static func result(
            _ handle: borrowing Windows.`32`.Kernel.Descriptor,
            overlapped: inout Overlapped,
            wait: Bool = false
        ) throws(Error) -> UInt32 {
            try result(handle._rawValue, overlapped: &overlapped, wait: wait)
        }
    }

#endif
