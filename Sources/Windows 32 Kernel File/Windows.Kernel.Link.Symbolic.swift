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
                DWORD(FILE_FLAG_BACKUP_SEMANTICS),
                nil
            )

            guard handle != INVALID_HANDLE_VALUE else {
                throw .current()
            }
            defer { _ = CloseHandle(handle) }

            let wbuffer = UnsafeMutableRawPointer(buffer.baseAddress!).assumingMemoryBound(
                to: WCHAR.self
            )
            let result = GetFinalPathNameByHandleW(
                handle,
                wbuffer,
                DWORD(buffer.count),
                DWORD(FILE_NAME_NORMALIZED)
            )

            guard result > 0 else {
                throw .current()
            }

            if result > buffer.count {
                throw .bufferTooSmall
            }

            return Int(result)
        }
    }

    extension Windows.`32`.Kernel.Link.Symbolic.Error {

        @usableFromInline
        internal static func current() -> Self {
            let code = Error_Primitives.Error.captureLastError()
            guard let win32Code = code.win32 else {
                return .platform(Error_Primitives.Error(code: code))
            }
            return current(from: win32Code)
        }

        package static func current(from win32Code: UInt32) -> Self {
            switch win32Code {
            case Error_Primitives.Error.Code.File.notFound,
                Error_Primitives.Error.Code.File.pathNotFound:
                return .notFound

            case Error_Primitives.Error.Code.Access.denied:
                return .permission

            case Error_Primitives.Error.Code.File.exists,
                Error_Primitives.Error.Code.File.alreadyExists:
                return .exists

            case Error_Primitives.Error.Code.Storage.diskFull,
                Error_Primitives.Error.Code.Storage.handleDiskFull:
                return .noSpace

            default:
                return .platform(Error_Primitives.Error(code: .win32(win32Code)))
            }
        }
    }

#endif
