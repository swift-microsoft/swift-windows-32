#if os(Windows)
    public import WinSDK
    public import String_Primitives

    extension Windows.`32`.Kernel.File.Stats {

        public static func get(
            path: borrowing Path.Borrowed
        ) throws(Windows.`32`.Kernel.File.Stats.Error) -> Windows.`32`.Kernel.File.Stats {
            try unsafe path.withUnsafePointer { ptr throws(Windows.`32`.Kernel.File.Stats.Error) in
                try _get(unsafePath: ptr, followSymlinks: true)
            }
        }

        public static func lget(
            path: borrowing Path.Borrowed
        ) throws(Windows.`32`.Kernel.File.Stats.Error) -> Windows.`32`.Kernel.File.Stats {
            try unsafe path.withUnsafePointer { ptr throws(Windows.`32`.Kernel.File.Stats.Error) in
                try _get(unsafePath: ptr, followSymlinks: false)
            }
        }

        public static func get(
            descriptor: borrowing Windows.`32`.Kernel.Descriptor
        ) throws(Windows.`32`.Kernel.File.Stats.Error) -> Windows.`32`.Kernel.File.Stats {
            try Windows.`32`.Kernel.File.getStats(descriptor._rawValue)
        }

        internal static func _get(
            unsafePath: UnsafePointer<Path.Char>,
            followSymlinks: Bool
        ) throws(Windows.`32`.Kernel.File.Stats.Error) -> Windows.`32`.Kernel.File.Stats {
            let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)
            var flags = DWORD(FILE_FLAG_BACKUP_SEMANTICS)
            if !followSymlinks {
                flags |= DWORD(FILE_FLAG_OPEN_REPARSE_POINT)
            }
            let handle = CreateFileW(
                wpath,
                DWORD(FILE_READ_ATTRIBUTES),
                DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
                nil,
                DWORD(OPEN_EXISTING),
                flags,
                nil
            )
            guard let handle, handle != INVALID_HANDLE_VALUE else {
                throw .platform(
                    Error_Primitives.Error(code: Error_Primitives.Error.captureLastError())
                )
            }
            defer { CloseHandle(handle) }

            var info = BY_HANDLE_FILE_INFORMATION()
            guard GetFileInformationByHandle(handle, &info) else {
                throw .platform(
                    Error_Primitives.Error(code: Error_Primitives.Error.captureLastError())
                )
            }
            return Windows.`32`.Kernel.File.Stats(_from: info)
        }
    }

    extension Windows.`32`.Kernel.File.Delete {

        public static func delete(
            _ path: borrowing Path.Borrowed
        ) throws(Windows.`32`.Kernel.File.Delete.Error) {
            try unsafe path.withUnsafePointer { ptr throws(Windows.`32`.Kernel.File.Delete.Error) in
                try delete(unsafePath: ptr)
            }
        }
    }

    extension Windows.`32`.Kernel.File.Open {

        public static func open(
            path: borrowing Path.Borrowed,
            mode: Windows.`32`.Kernel.File.Open.Mode,
            options: Windows.`32`.Kernel.File.Open.Options,
            permissions: Windows.`32`.Kernel.File.Permissions
        ) throws(Windows.`32`.Kernel.File.Open.Error) -> Windows.`32`.Kernel.Descriptor {
            try unsafe path.withUnsafePointer { ptr throws(Windows.`32`.Kernel.File.Open.Error) in
                try open(unsafePath: ptr, mode: mode, options: options, permissions: permissions)
            }
        }
    }

    extension Windows.`32`.Kernel.File.Times {

        public static func set(
            access accessTime: Windows.`32`.Kernel.Time,
            modification modificationTime: Windows.`32`.Kernel.Time,
            at path: borrowing Path.Borrowed,
            followSymlinks: Bool = true
        ) throws(Windows.`32`.Kernel.File.Times.Error) {
            try unsafe path.withUnsafePointer { ptr throws(Windows.`32`.Kernel.File.Times.Error) in
                let wpath = UnsafeRawPointer(ptr).assumingMemoryBound(to: WCHAR.self)
                var flags = DWORD(FILE_FLAG_BACKUP_SEMANTICS)
                if !followSymlinks {
                    flags |= DWORD(FILE_FLAG_OPEN_REPARSE_POINT)
                }
                let handle = CreateFileW(
                    wpath,
                    DWORD(FILE_WRITE_ATTRIBUTES),
                    DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
                    nil,
                    DWORD(OPEN_EXISTING),
                    flags,
                    nil
                )
                guard let handle, handle != INVALID_HANDLE_VALUE else {
                    throw .platform(
                        Error_Primitives.Error(code: Error_Primitives.Error.captureLastError())
                    )
                }
                defer { CloseHandle(handle) }

                var access = FILETIME(_from: accessTime)
                var write = FILETIME(_from: modificationTime)
                guard SetFileTime(handle, nil, &access, &write) else {
                    throw .platform(
                        Error_Primitives.Error(code: Error_Primitives.Error.captureLastError())
                    )
                }
            }
        }
    }

    extension Windows.`32`.Kernel.File.Attributes {

        public static func set(
            _ permissions: Windows.`32`.Kernel.File.Permissions,
            at path: borrowing Path.Borrowed
        ) throws(Windows.`32`.Kernel.File.Attributes.Error) {
            try unsafe path.withUnsafePointer {
                ptr throws(Windows.`32`.Kernel.File.Attributes.Error) in
                let wpath = UnsafeRawPointer(ptr).assumingMemoryBound(to: WCHAR.self)
                let current = GetFileAttributesW(wpath)
                guard current != INVALID_FILE_ATTRIBUTES else {
                    throw .platform(
                        Error_Primitives.Error(code: Error_Primitives.Error.captureLastError())
                    )
                }
                var updated = current
                if (permissions & .ownerWrite) == .none {
                    updated |= DWORD(FILE_ATTRIBUTE_READONLY)
                } else {
                    updated &= ~DWORD(FILE_ATTRIBUTE_READONLY)
                }
                guard updated == current || SetFileAttributesW(wpath, updated) else {
                    throw .platform(
                        Error_Primitives.Error(code: Error_Primitives.Error.captureLastError())
                    )
                }
            }
        }
    }

    extension Windows.`32`.Kernel.File.Move {

        public static func move(
            from oldPath: borrowing Path.Borrowed,
            to newPath: borrowing Path.Borrowed
        ) throws(Windows.`32`.Kernel.File.Move.Error) {
            try unsafe oldPath.withUnsafePointer {
                oldPtr throws(Windows.`32`.Kernel.File.Move.Error) in
                try unsafe newPath.withUnsafePointer {
                    newPtr throws(Windows.`32`.Kernel.File.Move.Error) in
                    try move(from: oldPtr, to: newPtr, replaceExisting: true)
                }
            }
        }
    }

    extension Windows.`32`.Kernel.File.Times {

        public static func set(
            access accessTime: Windows.`32`.Kernel.Time,
            modification modificationTime: Windows.`32`.Kernel.Time,
            on descriptor: borrowing Windows.`32`.Kernel.Descriptor
        ) throws(Windows.`32`.Kernel.File.Times.Error) {
            var access = FILETIME(_from: accessTime)
            var write = FILETIME(_from: modificationTime)
            let handle = UnsafeMutableRawPointer(bitPattern: descriptor._rawValue)
            guard SetFileTime(handle, nil, &access, &write) else {
                throw .platform(
                    Error_Primitives.Error(code: Error_Primitives.Error.captureLastError())
                )
            }
        }
    }

    extension Windows.`32`.Kernel.File.Seek {

        public typealias Whence = Origin

        @discardableResult
        public static func seek(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
            offset: Int64,
            whence: Whence
        ) throws(Windows.`32`.Kernel.File.Seek.Error) -> Int64 {
            try seek(descriptor, offset: offset, origin: whence)
        }
    }

    extension Windows.`32`.Kernel.Link {

        public static func create(
            at linkPath: borrowing Path.Borrowed,
            to existingPath: borrowing Path.Borrowed
        ) throws(Windows.`32`.Kernel.Link.Error) {
            try unsafe existingPath.withUnsafePointer {
                sourcePtr throws(Windows.`32`.Kernel.Link.Error) in
                try unsafe linkPath.withUnsafePointer {
                    linkPtr throws(Windows.`32`.Kernel.Link.Error) in
                    try create(source: sourcePtr, linkPath: linkPtr)
                }
            }
        }
    }

    extension Windows.`32`.Kernel.File.Attributes {

        public static func set(
            _ permissions: Windows.`32`.Kernel.File.Permissions,
            on descriptor: borrowing Windows.`32`.Kernel.Descriptor
        ) throws(Windows.`32`.Kernel.File.Attributes.Error) {
            let handle = UnsafeMutableRawPointer(bitPattern: descriptor._rawValue)
            var info = FILE_BASIC_INFO()
            guard
                GetFileInformationByHandleEx(
                    handle,
                    FileBasicInfo,
                    &info,
                    DWORD(MemoryLayout<FILE_BASIC_INFO>.size)
                )
            else {
                throw .platform(
                    Error_Primitives.Error(code: Error_Primitives.Error.captureLastError())
                )
            }
            let current = info.FileAttributes
            var updated = current
            if (permissions & .ownerWrite) == .none {
                updated |= DWORD(FILE_ATTRIBUTE_READONLY)
            } else {
                updated &= ~DWORD(FILE_ATTRIBUTE_READONLY)
            }
            guard updated != current else { return }
            info.FileAttributes = updated

            info.CreationTime.QuadPart = 0
            info.LastAccessTime.QuadPart = 0
            info.LastWriteTime.QuadPart = 0
            info.ChangeTime.QuadPart = 0
            guard
                SetFileInformationByHandle(
                    handle,
                    FileBasicInfo,
                    &info,
                    DWORD(MemoryLayout<FILE_BASIC_INFO>.size)
                )
            else {
                throw .platform(
                    Error_Primitives.Error(code: Error_Primitives.Error.captureLastError())
                )
            }
        }
    }

    extension Windows.`32`.Kernel.Link.Symbolic {

        public static func create(
            target: borrowing Path.Borrowed,
            at linkPath: borrowing Path.Borrowed
        ) throws(Windows.`32`.Kernel.Link.Symbolic.Error) {
            try unsafe target.withUnsafePointer {
                targetPtr throws(Windows.`32`.Kernel.Link.Symbolic.Error) in
                try unsafe linkPath.withUnsafePointer {
                    linkPtr throws(Windows.`32`.Kernel.Link.Symbolic.Error) in

                    let wTarget = UnsafeRawPointer(targetPtr).assumingMemoryBound(to: WCHAR.self)
                    let attributes = GetFileAttributesW(wTarget)
                    let isDirectory =
                        attributes != INVALID_FILE_ATTRIBUTES
                        && (attributes & DWORD(FILE_ATTRIBUTE_DIRECTORY)) != 0
                    try create(target: targetPtr, linkPath: linkPtr, isDirectory: isDirectory)
                }
            }
        }

        public static func readTarget(
            at path: borrowing Path.Borrowed
        ) throws(Windows.`32`.Kernel.Link.Symbolic.Error) -> String_Primitives.String {

            let capacity = 32768
            let raw = UnsafeMutablePointer<UInt16>.allocate(capacity: capacity)
            defer { unsafe raw.deallocate() }
            unsafe raw.initialize(repeating: 0, count: capacity)
            let buf = unsafe UnsafeMutableBufferPointer(start: raw, count: capacity)
            let length = try unsafe path.withUnsafePointer {
                ptr throws(Windows.`32`.Kernel.Link.Symbolic.Error) in
                try unsafe readTarget(unsafePath: ptr, into: buf)
            }

            var start = raw
            var count = length
            if length >= 4,
                unsafe raw[0] == 0x5C, unsafe raw[1] == 0x5C,
                unsafe raw[2] == 0x3F, unsafe raw[3] == 0x5C
            {
                start = unsafe raw.advanced(by: 4)
                count = length - 4
            }
            let view = unsafe String_Primitives.String.Borrowed(UnsafePointer(start), count: count)
            return unsafe String_Primitives.String(copying: view)
        }
    }

    extension FILETIME {

        internal init(_from instant: Windows.`32`.Kernel.Time) {
            let epochOffset: Int64 = 116_444_736_000_000_000
            let intervals =
                instant.secondsSinceUnixEpoch * 10_000_000
                + Int64(instant.nanosecondFraction) / 100
                + epochOffset
            self.init(
                dwLowDateTime: DWORD(truncatingIfNeeded: intervals),
                dwHighDateTime: DWORD(truncatingIfNeeded: intervals >> 32)
            )
        }
    }

#endif
