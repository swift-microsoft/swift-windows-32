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

            case Error::Error.Code.File.exists,
                Error::Error.Code.File.alreadyExists:
                return .exists

            case Error::Error.Code.Storage.diskFull,
                Error::Error.Code.Storage.handleDiskFull:
                return .noSpace

            default:
                return .platform(Error.Error(code: .win32(win32Code)))
            }
        }
    }

#endif
