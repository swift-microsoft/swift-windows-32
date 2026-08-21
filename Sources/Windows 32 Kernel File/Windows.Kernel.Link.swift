#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.Link {

        public static func create(
            source: borrowing Path,
            linkPath: borrowing Path
        ) throws(Windows.`32`.Kernel.Link.Error) {
            try unsafe source.view.withUnsafePointer {
                sourcePtr throws(Windows.`32`.Kernel.Link.Error) in
                try unsafe linkPath.view.withUnsafePointer {
                    linkPtr throws(Windows.`32`.Kernel.Link.Error) in
                    try create(source: sourcePtr, linkPath: linkPtr)
                }
            }
        }

        public static func create(
            source: UnsafePointer<Path.Char>,
            linkPath: UnsafePointer<Path.Char>
        ) throws(Windows.`32`.Kernel.Link.Error) {
            let wSource = UnsafeRawPointer(source).assumingMemoryBound(to: WCHAR.self)
            let wLink = UnsafeRawPointer(linkPath).assumingMemoryBound(to: WCHAR.self)

            guard CreateHardLinkW(wLink, wSource, nil) else {
                throw .current()
            }
        }
    }

    extension Windows.`32`.Kernel.Link.Error {

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
