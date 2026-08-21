#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.Directory {

        public struct Iterator: ~Copyable {
            @usableFromInline
            internal var handle: HANDLE
            @usableFromInline
            internal var findData: WIN32_FIND_DATAW
            @usableFromInline
            internal var firstEntry: Bool

            @usableFromInline
            internal init(handle: HANDLE, findData: WIN32_FIND_DATAW) {
                self.handle = handle
                self.findData = findData
                self.firstEntry = true
            }

            deinit {
                if handle != INVALID_HANDLE_VALUE {
                    _ = FindClose(handle)
                }
            }
        }
    }

    extension Windows.`32`.Kernel.Directory.Iterator {

        public static func open(
            path: borrowing Path
        ) throws(Windows.`32`.Kernel.Directory.Error) -> Self {
            try unsafe path.view.withUnsafePointer {
                ptr throws(Windows.`32`.Kernel.Directory.Error) in
                try open(unsafePath: ptr)
            }
        }

        public static func open(
            unsafePath: UnsafePointer<Path.Char>
        ) throws(Windows.`32`.Kernel.Directory.Error) -> Self {
            var findData = WIN32_FIND_DATAW()
            let handle = _findFirst(unsafePath: unsafePath, findData: &findData)

            guard let handle, handle != INVALID_HANDLE_VALUE else {
                let error = GetLastError()
                throw Windows.`32`.Kernel.Directory.Error(_windowsError: error)
            }

            return Self(handle: handle, findData: findData)
        }

        internal static func _findFirst(
            unsafePath: UnsafePointer<Path.Char>,
            findData: inout WIN32_FIND_DATAW
        ) -> HANDLE? {

            let pathChars = unsafePath
            var length = 0
            while pathChars[length] != 0 { length += 1 }

            var pattern = [UInt16](repeating: 0, count: length + 3)
            for i in 0..<length {
                pattern[i] = pathChars[i]
            }

            let lastChar = length > 0 ? pattern[length - 1] : 0
            var patternLength = length
            if lastChar != 0x5C && lastChar != 0x2F {
                pattern[patternLength] = 0x5C
                patternLength += 1
            }
            pattern[patternLength] = 0x2A
            patternLength += 1
            pattern[patternLength] = 0

            return pattern.withUnsafeBufferPointer { patternBuffer in
                let wpath = UnsafeRawPointer(patternBuffer.baseAddress!).assumingMemoryBound(
                    to: WCHAR.self
                )
                return FindFirstFileW(wpath, &findData)
            }
        }

        public mutating func next() throws(Windows.`32`.Kernel.Directory.Error) -> Windows.`32`
            .Kernel.Directory.Entry?
        {
            if firstEntry {
                firstEntry = false
                return entryFromFindData()
            }

            guard FindNextFileW(handle, &findData) else {
                let error = GetLastError()
                if error == DWORD(ERROR_NO_MORE_FILES) {
                    return nil
                }
                throw Windows.`32`.Kernel.Directory.Error(_windowsError: error)
            }

            return entryFromFindData()
        }

        public consuming func close() {
            if handle != INVALID_HANDLE_VALUE {
                _ = FindClose(handle)

                handle = INVALID_HANDLE_VALUE
            }
        }

        @usableFromInline
        internal func entryFromFindData() -> Windows.`32`.Kernel.Directory.Entry {
            Self._entry(from: findData)
        }

        internal static func _entry(
            from findData: WIN32_FIND_DATAW
        ) -> Windows.`32`.Kernel.Directory.Entry {

            var nameChars = withUnsafeBytes(of: findData.cFileName) { buffer in
                let ptr = buffer.baseAddress!.assumingMemoryBound(to: UInt16.self)
                let capacity =
                    MemoryLayout.size(ofValue: findData.cFileName) / MemoryLayout<UInt16>.size
                var length = 0
                while length < capacity && ptr[length] != 0 {
                    length += 1
                }
                return Array(UnsafeBufferPointer(start: ptr, count: length))
            }
            nameChars.append(0)

            let type: Windows.`32`.Kernel.File.Stats.Kind?
            if (findData.dwFileAttributes & DWORD(FILE_ATTRIBUTE_DIRECTORY)) != 0 {
                type = .directory
            } else if (findData.dwFileAttributes & DWORD(FILE_ATTRIBUTE_REPARSE_POINT)) != 0 {
                type = .link(.symbolic)
            } else {
                type = .regular
            }

            return Windows.`32`.Kernel.Directory.Entry(rawName: nameChars, inode: nil, type: type)
        }
    }

    extension Windows.`32`.Kernel.Directory.Error {

        package init(_windowsError error: DWORD) {
            switch error {
            case Error_Primitives.Error.Code.File.notFound,
                Error_Primitives.Error.Code.File.pathNotFound:
                self = .notFound

            case Error_Primitives.Error.Code.Access.denied:
                self = .permission

            case Error_Primitives.Error.Code.Directory.invalidName:

                self = .notDirectory

            default:
                self = .platform(Error_Primitives.Error(code: .win32(error)))
            }
        }
    }

#endif
