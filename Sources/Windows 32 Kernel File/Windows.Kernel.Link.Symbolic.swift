#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.Link.Symbolic {

        public static func create(
            target: borrowing Path,
            linkPath: borrowing Path,
            isDirectory: Bool = false
        ) throws(Windows.`32`.Kernel.Link.Symbolic.Error) {
            try unsafe target.view.withUnsafePointer {
                targetPtr throws(Windows.`32`.Kernel.Link.Symbolic.Error) in
                try unsafe linkPath.view.withUnsafePointer {
                    linkPtr throws(Windows.`32`.Kernel.Link.Symbolic.Error) in
                    try create(
                        target: targetPtr,
                        linkPath: linkPtr,
                        isDirectory: isDirectory
                    )
                }
            }
        }

        public static func create(
            target: UnsafePointer<Path.Char>,
            linkPath: UnsafePointer<Path.Char>,
            isDirectory: Bool = false
        ) throws(Windows.`32`.Kernel.Link.Symbolic.Error) {
            let wTarget = UnsafeRawPointer(target).assumingMemoryBound(to: WCHAR.self)
            let wLink = UnsafeRawPointer(linkPath).assumingMemoryBound(to: WCHAR.self)

            var flags: DWORD = DWORD(SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE)
            if isDirectory {
                flags |= DWORD(SYMBOLIC_LINK_FLAG_DIRECTORY)
            }

            guard CreateSymbolicLinkW(wLink, wTarget, flags) != 0 else {
                throw .current()
            }
        }

        public static func readTarget(
            path: borrowing Path,
            into buffer: UnsafeMutableBufferPointer<UInt16>
        ) throws(Windows.`32`.Kernel.Link.Symbolic.Error) -> Int {
            try unsafe path.view.withUnsafePointer {
                ptr throws(Windows.`32`.Kernel.Link.Symbolic.Error) in
                try readTarget(unsafePath: ptr, into: buffer)
            }
        }

        public static func readTarget(
            unsafePath: UnsafePointer<Path.Char>,
            into buffer: UnsafeMutableBufferPointer<UInt16>
        ) throws(Windows.`32`.Kernel.Link.Symbolic.Error) -> Int {
            let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)

            let handle = CreateFileW(
                wpath,
                0,
                DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
                nil,
                DWORD(OPEN_EXISTING),
                DWORD(FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OPEN_REPARSE_POINT),
                nil
            )

            guard handle != INVALID_HANDLE_VALUE else {
                throw .current()
            }
            defer { _ = CloseHandle(handle) }

            let capacity = 16 * 1024
            let reparse = UnsafeMutableRawPointer.allocate(
                byteCount: capacity,
                alignment: MemoryLayout<UInt32>.alignment
            )
            defer { reparse.deallocate() }

            let control: DWORD = 0x0009_00A8
            var returned: DWORD = 0
            guard
                DeviceIoControl(
                    handle,
                    control,
                    nil,
                    0,
                    reparse,
                    DWORD(capacity),
                    &returned,
                    nil
                )
            else {
                throw .current()
            }

            let symbolicTag: UInt32 = 0xA000_000C
            let junctionTag: UInt32 = 0xA000_0003
            let available = Int(returned)
            guard available >= 16 else {
                throw .notSymbolicLink
            }
            let pathBuffer: Int
            switch reparse.load(as: UInt32.self) {
            case symbolicTag:
                pathBuffer = 20
            case junctionTag:
                pathBuffer = 16
            default:
                throw .notSymbolicLink
            }

            let substituteOffset = Int(reparse.load(fromByteOffset: 8, as: UInt16.self))
            let substituteLength = Int(reparse.load(fromByteOffset: 10, as: UInt16.self))
            let printOffset = Int(reparse.load(fromByteOffset: 12, as: UInt16.self))
            let printLength = Int(reparse.load(fromByteOffset: 14, as: UInt16.self))

            var start = pathBuffer + printOffset
            var length = printLength
            if printLength == 0 {
                start = pathBuffer + substituteOffset
                length = substituteLength
                if length >= 8,
                    start + 8 <= available,
                    reparse.load(fromByteOffset: start, as: UInt16.self) == 0x5C,
                    reparse.load(fromByteOffset: start + 2, as: UInt16.self) == 0x3F,
                    reparse.load(fromByteOffset: start + 4, as: UInt16.self) == 0x3F,
                    reparse.load(fromByteOffset: start + 6, as: UInt16.self) == 0x5C
                {
                    start += 8
                    length -= 8
                }
            }

            guard start + length <= available else {
                throw .notSymbolicLink
            }

            let count = length / MemoryLayout<UInt16>.size
            if count > buffer.count {
                throw .bufferTooSmall
            }
            if count > 0 {
                UnsafeMutableRawPointer(buffer.nonEmptyBaseAddress).copyMemory(
                    from: reparse + start,
                    byteCount: count * MemoryLayout<UInt16>.size
                )
            }
            if count < buffer.count {
                buffer[count] = 0
            }

            return count
        }
    }

    extension Windows.`32`.Kernel.Link.Symbolic.Error {

        @usableFromInline
        internal static func current() -> Self {
            let code = Error::Error.captureLastError()
            guard let win32Code = code.win32 else {
                return .platform(Error::Error(code: code))
            }
            return current(from: win32Code)
        }

        package static func current(from win32Code: UInt32) -> Self {
            switch win32Code {
            case Error::Error.Code.File.notFound,
                Error::Error.Code.File.pathNotFound:
                return .notFound

            case Error::Error.Code.Access.denied:
                return .permission

            case Error::Error.Code.File.exists,
                Error::Error.Code.File.alreadyExists:
                return .exists

            case Error::Error.Code.Storage.diskFull,
                Error::Error.Code.Storage.handleDiskFull:
                return .noSpace

            case UInt32(ERROR_NOT_A_REPARSE_POINT):
                return .notSymbolicLink

            default:
                return .platform(Error::Error(code: .win32(win32Code)))
            }
        }
    }

#endif
