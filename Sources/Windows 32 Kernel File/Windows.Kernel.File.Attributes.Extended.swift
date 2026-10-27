#if os(Windows)
    public import WinSDK
    public import Path
    import Error

    extension Windows.`32`.Kernel.File.Attributes {

        public enum Extended {}
    }

    extension Windows.`32`.Kernel.File.Attributes.Extended {

        public struct Error: Swift::Error, Sendable {
            public let code: Error::Error.Code

            public init(code: Error::Error.Code) {
                self.code = code
            }
        }
    }

    extension Windows.`32`.Kernel.File.Attributes.Extended.Error {

        public static let notFound = Self(code: .win32(UInt32(ERROR_NOT_FOUND)))

        public static let noSpace = Self(code: .win32(UInt32(ERROR_DISK_FULL)))

        public static let permissionDenied = Self(code: .win32(UInt32(ERROR_ACCESS_DENIED)))

        @usableFromInline
        internal static func current() -> Self {
            Self(code: Error::Error.captureLastError())
        }
    }

    extension Windows.`32`.Kernel.File.Attributes.Extended {

        private static func stream(
            _ name: Swift::String,
            of path: borrowing Path.Borrowed
        ) -> [WCHAR] {
            let base = unsafe path.withUnsafePointer { pointer in
                unsafe Array(
                    UnsafeBufferPointer(
                        start: UnsafeRawPointer(pointer).assumingMemoryBound(to: WCHAR.self),
                        count: path.count
                    )
                )
            }
            return base + [WCHAR(UInt8(ascii: ":"))] + Array(name.utf16) + [0]
        }

        private static func requireFile(_ path: borrowing Path.Borrowed) throws(Windows.`32`.Kernel.File.Attributes.Extended.Error) {
            let exists = unsafe path.withUnsafePointer { pointer in
                unsafe GetFileAttributesW(
                    UnsafeRawPointer(pointer).assumingMemoryBound(to: WCHAR.self)
                ) != INVALID_FILE_ATTRIBUTES
            }
            guard exists else { throw .current() }
        }

        private static func open(
            _ stream: [WCHAR],
            access: DWORD,
            disposition: DWORD
        ) throws(Windows.`32`.Kernel.File.Attributes.Extended.Error) -> HANDLE {
            let handle = unsafe stream.withUnsafeBufferPointer { buffer in
                unsafe CreateFileW(
                    buffer.baseAddress,
                    access,
                    DWORD(FILE_SHARE_READ),
                    nil,
                    disposition,
                    DWORD(FILE_ATTRIBUTE_NORMAL),
                    nil
                )
            }
            guard let handle, handle != INVALID_HANDLE_VALUE else {
                let error = Error.current()
                if error.code == .win32(UInt32(ERROR_FILE_NOT_FOUND)) { throw .notFound }
                throw error
            }
            return handle
        }
    }

    extension Windows.`32`.Kernel.File.Attributes.Extended {

        public static func list(
            path: borrowing Path.Borrowed,
            followSymlinks: Bool = true
        ) throws(Windows.`32`.Kernel.File.Attributes.Extended.Error) -> [Swift::String] {
            var data = WIN32_FIND_STREAM_DATA()
            let find = unsafe path.withUnsafePointer { pointer in
                unsafe FindFirstStreamW(
                    UnsafeRawPointer(pointer).assumingMemoryBound(to: WCHAR.self),
                    FindStreamInfoStandard,
                    &data,
                    0
                )
            }
            guard let find, find != INVALID_HANDLE_VALUE else {
                let error = Error.current()
                if error.code == .win32(UInt32(ERROR_HANDLE_EOF)) { return [] }
                throw error
            }
            defer { _ = FindClose(find) }

            var names: [Swift::String] = []
            repeat {
                let full = unsafe withUnsafeBytes(of: data.cStreamName) { bytes in
                    let units = unsafe bytes.bindMemory(to: WCHAR.self)
                    return Swift::String(decoding: units.prefix { $0 != 0 }, as: UTF16.self)
                }
                let parts = full.split(separator: ":", omittingEmptySubsequences: false)
                if parts.count == 3, !parts[1].isEmpty {
                    names.append(Swift::String(parts[1]))
                }
            } while unsafe FindNextStreamW(find, &data)

            let error = Error.current()
            guard error.code == .win32(UInt32(ERROR_HANDLE_EOF)) else { throw error }
            return names
        }

        public static func get(
            name: Swift::String,
            path: borrowing Path.Borrowed,
            followSymlinks: Bool = true
        ) throws(Windows.`32`.Kernel.File.Attributes.Extended.Error) -> [UInt8] {
            try requireFile(path)
            let handle = try open(
                stream(name, of: path),
                access: DWORD(GENERIC_READ),
                disposition: DWORD(OPEN_EXISTING)
            )
            defer { _ = CloseHandle(handle) }

            var size = LARGE_INTEGER()
            guard unsafe GetFileSizeEx(handle, &size) else { throw .current() }

            var bytes = [UInt8](repeating: 0, count: Int(size.QuadPart))
            var filled = 0
            while filled < bytes.count {
                var read: DWORD = 0
                let success = unsafe bytes.withUnsafeMutableBytes { buffer in
                    guard let base = buffer.baseAddress else { return false }
                    return unsafe ReadFile(
                        handle,
                        base + filled,
                        DWORD(buffer.count - filled),
                        &read,
                        nil
                    )
                }
                guard success else { throw .current() }
                if read == 0 { break }
                filled += Int(read)
            }
            return Array(bytes.prefix(filled))
        }

        public static func set(
            name: Swift::String,
            value: UnsafeRawBufferPointer,
            path: borrowing Path.Borrowed,
            followSymlinks: Bool = true
        ) throws(Windows.`32`.Kernel.File.Attributes.Extended.Error) {
            try requireFile(path)
            let handle = try open(
                stream(name, of: path),
                access: DWORD(GENERIC_WRITE),
                disposition: DWORD(CREATE_ALWAYS)
            )
            defer { _ = CloseHandle(handle) }

            guard let base = value.baseAddress else { return }
            var written = 0
            while written < value.count {
                var count: DWORD = 0
                guard
                    unsafe WriteFile(
                        handle,
                        base + written,
                        DWORD(value.count - written),
                        &count,
                        nil
                    )
                else { throw .current() }
                written += Int(count)
            }
        }

        public static func remove(
            name: Swift::String,
            path: borrowing Path.Borrowed,
            followSymlinks: Bool = true
        ) throws(Windows.`32`.Kernel.File.Attributes.Extended.Error) {
            try requireFile(path)
            let deleted = unsafe stream(name, of: path).withUnsafeBufferPointer { buffer in
                unsafe DeleteFileW(buffer.baseAddress)
            }
            guard deleted else {
                let error = Error.current()
                if error.code == .win32(UInt32(ERROR_FILE_NOT_FOUND)) { throw .notFound }
                throw error
            }
        }
    }

#endif
