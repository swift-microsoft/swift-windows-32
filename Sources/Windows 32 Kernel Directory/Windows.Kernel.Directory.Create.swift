#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.Directory.Create {

        public static func create(
            path: borrowing Path,
            permissions: Windows.`32`.Kernel.File.Permissions = .standardDirectory
        ) throws(Windows.`32`.Kernel.Directory.Create.Error) {
            try unsafe path.view.withUnsafePointer {
                ptr throws(Windows.`32`.Kernel.Directory.Create.Error) in
                try create(unsafePath: ptr, permissions: permissions)
            }
        }

        public static func create(
            _ path: borrowing Path.Borrowed,
            permissions: Windows.`32`.Kernel.File.Permissions = .standardDirectory
        ) throws(Windows.`32`.Kernel.Directory.Create.Error) {
            try unsafe path.withUnsafePointer {
                ptr throws(Windows.`32`.Kernel.Directory.Create.Error) in
                try create(unsafePath: ptr, permissions: permissions)
            }
        }

        public static func create(
            unsafePath: UnsafePointer<Path.Char>,
            permissions: Windows.`32`.Kernel.File.Permissions = .standardDirectory
        ) throws(Windows.`32`.Kernel.Directory.Create.Error) {
            let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)
            guard CreateDirectoryW(wpath, nil) else {
                throw .current()
            }
        }
    }

    extension Windows.`32`.Kernel.Directory.Create.Error {

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
            case Error_Primitives.Error.Code.File.pathNotFound:
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
