#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.File.Move {

        public struct Options: OptionSet, Sendable {
            public let rawValue: DWORD

            public init(rawValue: DWORD) {
                self.rawValue = rawValue
            }
        }
    }

    extension Windows.`32`.Kernel.File.Move.Options {

        public static let replaceExisting = Self(rawValue: DWORD(MOVEFILE_REPLACE_EXISTING))

        public static let writeThrough = Self(rawValue: DWORD(MOVEFILE_WRITE_THROUGH))

        public static let copyAllowed = Self(rawValue: DWORD(MOVEFILE_COPY_ALLOWED))

        public static let delayUntilReboot = Self(rawValue: DWORD(MOVEFILE_DELAY_UNTIL_REBOOT))
    }

    extension Windows.`32`.Kernel.File.Move {

        public static func move(
            from oldPath: borrowing Path,
            to newPath: borrowing Path,
            replaceExisting: Bool = false
        ) throws(Windows.`32`.Kernel.File.Move.Error) {
            let options: Options = replaceExisting ? .replaceExisting : []
            try move(from: oldPath, to: newPath, options: options)
        }

        public static func move(
            from oldPath: borrowing Path,
            to newPath: borrowing Path,
            options: Options
        ) throws(Windows.`32`.Kernel.File.Move.Error) {
            try unsafe oldPath.view.withUnsafePointer {
                oldPtr throws(Windows.`32`.Kernel.File.Move.Error) in
                try unsafe newPath.view.withUnsafePointer {
                    newPtr throws(Windows.`32`.Kernel.File.Move.Error) in
                    try move(
                        from: oldPtr,
                        to: newPtr,
                        options: options
                    )
                }
            }
        }

        public static func move(
            from oldPath: UnsafePointer<Path.Char>,
            to newPath: UnsafePointer<Path.Char>,
            replaceExisting: Bool = false
        ) throws(Windows.`32`.Kernel.File.Move.Error) {
            let options: Options = replaceExisting ? .replaceExisting : []
            try move(from: oldPath, to: newPath, options: options)
        }

        public static func move(
            from oldPath: UnsafePointer<Path.Char>,
            to newPath: UnsafePointer<Path.Char>,
            options: Options
        ) throws(Windows.`32`.Kernel.File.Move.Error) {
            let wOldPath = UnsafeRawPointer(oldPath).assumingMemoryBound(to: WCHAR.self)
            let wNewPath = UnsafeRawPointer(newPath).assumingMemoryBound(to: WCHAR.self)

            guard MoveFileExW(wOldPath, wNewPath, options.rawValue) else {
                throw .current()
            }
        }
    }

    extension Windows.`32`.Kernel.File.Move.Error {

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

            case Error_Primitives.Error.Code.Access.sharingViolation:
                return .busy

            default:
                return .platform(Error_Primitives.Error(code: .win32(win32Code)))
            }
        }
    }

#endif
