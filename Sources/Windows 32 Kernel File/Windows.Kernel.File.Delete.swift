#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.File.Delete {

        public static func delete(
            path: borrowing Path
        ) throws(Windows.`32`.Kernel.File.Delete.Error) {
            try unsafe path.view.withUnsafePointer {
                ptr throws(Windows.`32`.Kernel.File.Delete.Error) in
                try delete(unsafePath: ptr)
            }
        }

        public static func delete(
            unsafePath: UnsafePointer<Path.Char>
        ) throws(Windows.`32`.Kernel.File.Delete.Error) {
            let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)
            guard DeleteFileW(wpath) else {
                throw .current()
            }
        }
    }

    extension Windows.`32`.Kernel.File.Delete.Error {

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

            case Error_Primitives.Error.Code.Access.sharingViolation:
                return .busy

            default:
                return .platform(Error_Primitives.Error(code: .win32(win32Code)))
            }
        }
    }

#endif
