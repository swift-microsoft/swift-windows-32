#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.File.Stats {

        internal init(_from info: BY_HANDLE_FILE_INFORMATION) {
            let size = (Int64(info.nFileSizeHigh) << 32) | Int64(info.nFileSizeLow)

            let type: Windows.`32`.Kernel.File.Stats.Kind
            if (info.dwFileAttributes & DWORD(FILE_ATTRIBUTE_DIRECTORY)) != 0 {
                type = .directory
            } else if (info.dwFileAttributes & DWORD(FILE_ATTRIBUTE_REPARSE_POINT)) != 0 {
                type = .link(.symbolic)
            } else {
                type = .regular
            }

            var permissions: Windows.`32`.Kernel.File.Permissions = .standard
            if (info.dwFileAttributes & DWORD(FILE_ATTRIBUTE_READONLY)) != 0 {

                permissions = Windows.`32`.Kernel.File.Permissions(rawValue: 0o444)
            }
            if (info.dwFileAttributes & DWORD(FILE_ATTRIBUTE_DIRECTORY)) != 0 {

                permissions = permissions | Windows.`32`.Kernel.File.Permissions(rawValue: 0o111)
            }

            let inode = (UInt64(info.nFileIndexHigh) << 32) | UInt64(info.nFileIndexLow)

            self.init(
                size: Windows.`32`.Kernel.File.Size(size),
                type: type,
                permissions: permissions,
                uid: .root,
                gid: .root,
                inode: Windows.`32`.Kernel.Inode(inode),
                device: Windows.`32`.Kernel.Device(UInt64(info.dwVolumeSerialNumber)),
                linkCount: Windows.`32`.Kernel.Link.Count(
                    _unchecked: Cardinal(UInt(info.nNumberOfLinks))
                ),
                accessTime: Instant(_from: info.ftLastAccessTime),
                modificationTime: Instant(_from: info.ftLastWriteTime),
                changeTime: Instant(_from: info.ftLastWriteTime)
            )
        }
    }

    extension Windows.`32`.Kernel.File {

        package static func getStats(
            _ handle: UInt
        ) throws(Windows.`32`.Kernel.File.Stats.Error) -> Stats {
            var info = BY_HANDLE_FILE_INFORMATION()

            guard GetFileInformationByHandle(UnsafeMutableRawPointer(bitPattern: handle)!, &info)
            else {
                throw .platform(
                    Error.Error(code: Error.Error.captureLastError())
                )
            }

            return Stats(_from: info)
        }

        @inlinable
        public static func getAttributes(
            path: UnsafePointer<WCHAR>
        ) -> DWORD {
            GetFileAttributesW(path)
        }

        package static func getSize(
            _ handle: UInt
        ) -> UInt64? {
            var size: LARGE_INTEGER = LARGE_INTEGER()
            guard GetFileSizeEx(UnsafeMutableRawPointer(bitPattern: handle)!, &size) else {
                return nil
            }
            return UInt64(bitPattern: size.QuadPart)
        }
    }

    extension Windows.`32`.Kernel.File {

        public static func getStats(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor
        ) throws(Windows.`32`.Kernel.File.Stats.Error) -> Stats {
            try getStats(descriptor._rawValue)
        }

        public static func getSize(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor
        ) -> UInt64? {
            getSize(descriptor._rawValue)
        }
    }

    extension Windows.`32`.Kernel.File {

        @inlinable
        public static func exists(path: borrowing Path) -> Bool {
            unsafe path.view.withUnsafePointer { ptr in
                let wpath = UnsafeRawPointer(ptr).assumingMemoryBound(to: WCHAR.self)
                return GetFileAttributesW(wpath) != INVALID_FILE_ATTRIBUTES
            }
        }

        @inlinable
        package static func exists(path: UnsafePointer<WCHAR>) -> Bool {
            GetFileAttributesW(path) != INVALID_FILE_ATTRIBUTES
        }

        @inlinable
        public static func getAttributes(path: borrowing Path) -> Attributes? {
            unsafe path.view.withUnsafePointer { ptr in
                let wpath = UnsafeRawPointer(ptr).assumingMemoryBound(to: WCHAR.self)
                let result = GetFileAttributesW(wpath)
                guard result != INVALID_FILE_ATTRIBUTES else {
                    return nil
                }
                return Attributes(rawValue: result)
            }
        }

        @inlinable
        public static func isDirectory(path: borrowing Path) -> Bool {
            guard let attrs = getAttributes(path: path) else {
                return false
            }
            return attrs.contains(.directory)
        }

        @inlinable
        public static func isRegularFile(path: borrowing Path) -> Bool {
            guard let attrs = getAttributes(path: path) else {
                return false
            }
            return !attrs.contains(.directory) && !attrs.contains(.reparsePoint)
        }
    }

    extension Windows.`32`.Kernel.File {

        public enum FileType: DWORD, Sendable {

            case unknown = 0x0000

            case disk = 0x0001

            case char = 0x0002

            case pipe = 0x0003
        }

        @inlinable
        package static func getType(
            _ handle: UInt
        ) -> FileType {
            let type = GetFileType(UnsafeMutableRawPointer(bitPattern: handle)!)
            return FileType(rawValue: type) ?? .unknown
        }

        public static func getType(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor
        ) -> FileType {
            getType(descriptor._rawValue)
        }
    }

#endif
