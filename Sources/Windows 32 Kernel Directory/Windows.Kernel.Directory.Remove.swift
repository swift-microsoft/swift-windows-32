#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.Directory.Remove {

        public static func remove(
            path: borrowing Path
        ) throws(Windows.`32`.Kernel.Directory.Remove.Error) {
            try unsafe path.view.withUnsafePointer {
                ptr throws(Windows.`32`.Kernel.Directory.Remove.Error) in
                try remove(unsafePath: ptr)
            }
        }

        public static func remove(
            _ path: borrowing Path.Borrowed
        ) throws(Windows.`32`.Kernel.Directory.Remove.Error) {
            try unsafe path.withUnsafePointer {
                ptr throws(Windows.`32`.Kernel.Directory.Remove.Error) in
                try remove(unsafePath: ptr)
            }
        }

        public static func remove(
            unsafePath: UnsafePointer<Path.Char>
        ) throws(Windows.`32`.Kernel.Directory.Remove.Error) {
            let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)
            guard RemoveDirectoryW(wpath) else {
                throw .current()
            }
        }
    }

    extension Windows.`32`.Kernel.Directory.Remove.Error {

        @usableFromInline
        internal static func current() -> Self {
            let code = Error.Error.captureLastError()
            guard let win32Code = code.win32 else {
                return .platform(Error.Error(code: code))
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

            case Error::Error.Code.Directory.notEmpty:
                return .notEmpty

            case Error::Error.Code.Access.sharingViolation:
                return .busy

            default:
                return .platform(Error.Error(code: .win32(win32Code)))
            }
        }
    }

#endif
