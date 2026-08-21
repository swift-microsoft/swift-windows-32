#if os(Windows)
    internal import WinSDK
    public import String_Primitives

    extension Path.Canonical {

        public static func resolve(
            path: borrowing Path,
            into buffer: UnsafeMutableBufferPointer<UInt16>
        ) throws(Path.Canonical.Error) -> Cardinal {
            try unsafe path.view.withUnsafePointer { ptr throws(Path.Canonical.Error) in
                try resolve(unsafePath: ptr, into: buffer)
            }
        }

        public static func resolve(
            unsafePath: UnsafePointer<Path.Char>,
            into buffer: UnsafeMutableBufferPointer<UInt16>
        ) throws(Path.Canonical.Error) -> Cardinal {
            let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)
            let wbuffer = UnsafeMutableRawPointer(buffer.baseAddress!).assumingMemoryBound(
                to: WCHAR.self
            )

            let result = GetFullPathNameW(wpath, DWORD(buffer.count), wbuffer, nil)

            guard result > 0 else {
                throw .current()
            }

            if result > buffer.count {
                throw .platform(
                    Error_Primitives.Error(code: .win32(DWORD(ERROR_INSUFFICIENT_BUFFER)))
                )
            }

            return Cardinal(result)
        }

        public static func resolve(
            path: borrowing Path
        ) throws(Path.Canonical.Error) -> [UInt16] {
            try unsafe path.view.withUnsafePointer { ptr throws(Path.Canonical.Error) in
                try resolve(unsafePath: ptr)
            }
        }

        public static func resolve(
            unsafePath: UnsafePointer<Path.Char>
        ) throws(Path.Canonical.Error) -> [UInt16] {
            let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)

            let requiredSize = GetFullPathNameW(wpath, 0, nil, nil)
            guard requiredSize > 0 else {
                throw .current()
            }

            var buffer = [UInt16](repeating: 0, count: Int(requiredSize))

            let written = GetFullPathNameW(wpath, requiredSize, &buffer, nil)
            guard written > 0, written < requiredSize else {
                throw .current()
            }

            return Array(buffer.prefix(Int(written)))
        }
    }

    extension Path.Canonical {

        public static func withCanonicalBytes<R: ~Copyable>(
            _ path: borrowing Path.Borrowed,
            _ body: (Swift.Span<Path.Char>) -> R
        ) throws(Path.Canonical.Error) -> R {
            try unsafe path.withUnsafePointer { unsafePath throws(Path.Canonical.Error) in
                try withFinalPath(unsafePath: unsafePath) { pointer, count in
                    let span = unsafe Swift.Span(_unsafeStart: pointer, count: count)
                    return body(span)
                }
            }
        }

        public static func withCanonical<R: ~Copyable>(
            _ path: borrowing Path.Borrowed,
            _ body: (borrowing String_Primitives.String.Borrowed) -> R
        ) throws(Path.Canonical.Error) -> R {
            try unsafe path.withUnsafePointer { unsafePath throws(Path.Canonical.Error) in
                try withFinalPath(unsafePath: unsafePath) { pointer, count in
                    let view = unsafe String_Primitives.String.Borrowed(pointer, count: count)
                    return body(view)
                }
            }
        }

        public static func canonicalize(
            _ path: borrowing Path.Borrowed
        ) throws(Path.Canonical.Error) -> String_Primitives.String {
            try withCanonical(path) { view in
                String_Primitives.String(copying: view)
            }
        }

        private static func withFinalPath<R: ~Copyable>(
            unsafePath: UnsafePointer<Path.Char>,
            _ body: (UnsafePointer<Path.Char>, Int) -> R
        ) throws(Path.Canonical.Error) -> R {
            let wpath = unsafe UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)
            let handle = CreateFileW(
                wpath,
                0,
                DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
                nil,
                DWORD(OPEN_EXISTING),
                DWORD(FILE_FLAG_BACKUP_SEMANTICS),
                nil
            )

            guard handle != INVALID_HANDLE_VALUE else {
                throw .current()
            }
            defer { _ = CloseHandle(handle) }

            let flags = DWORD(FILE_NAME_NORMALIZED)
            let requiredSize = GetFinalPathNameByHandleW(handle, nil, 0, flags)
            guard requiredSize > 0 else {
                throw .current()
            }

            var capacity = Int(requiredSize)
            while true {
                let buffer = UnsafeMutablePointer<Path.Char>.allocate(capacity: capacity)
                let wbuffer = unsafe UnsafeMutableRawPointer(buffer)
                    .assumingMemoryBound(to: WCHAR.self)
                let written = GetFinalPathNameByHandleW(
                    handle,
                    wbuffer,
                    DWORD(capacity),
                    flags
                )

                guard written > 0 else {
                    unsafe buffer.deallocate()
                    throw .current()
                }

                if Int(written) < capacity {
                    let result = body(unsafe UnsafePointer(buffer), Int(written))
                    unsafe buffer.deallocate()
                    return result
                }

                unsafe buffer.deallocate()
                capacity = Int(written)
            }
        }
    }

    extension Path.Canonical.Error {

        @usableFromInline
        internal static func current() -> Self {
            let code = Error_Primitives.Error.captureLastError()
            if let e = Path.Resolution.Error(code: code) {
                return .path(e)
            }
            return .platform(Error_Primitives.Error(code: code))
        }
    }

#endif
