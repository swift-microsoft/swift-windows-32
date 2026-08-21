#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.File {

        public enum Copy {}
    }

    extension Windows.`32`.Kernel.File.Copy {

        public enum Error: Swift.Error, Sendable, Equatable {

            case sourceNotFound

            case destinationExists

            case isDirectory

            case permissionDenied

            case clone(Windows.`32`.Kernel.File.Clone.Error)

            case unlink(Windows.`32`.Kernel.File.Delete.Error)

            case attributes(Windows.`32`.Kernel.File.Attributes.Error)

            case times(Windows.`32`.Kernel.File.Times.Error)

            case mkdir(Windows.`32`.Kernel.Directory.Create.Error)

            case rmdir(Windows.`32`.Kernel.Directory.Remove.Error)

            case operation(Swift.String)
        }
    }

    extension Windows.`32`.Kernel.File.Copy.Error {

        public var isSourceNotFound: Bool {
            if case .sourceNotFound = self { return true }
            return false
        }

        public var isDestinationExists: Bool {
            if case .destinationExists = self { return true }
            return false
        }

        public var isDirectory: Bool {
            if case .isDirectory = self { return true }
            return false
        }

        public var isPermissionDenied: Bool {
            if case .permissionDenied = self { return true }
            return false
        }
    }

    extension Windows.`32`.Kernel.File.Copy.Error: CustomStringConvertible {
        public var description: Swift.String {
            switch self {
            case .sourceNotFound: return "source not found"
            case .destinationExists: return "destination already exists"
            case .isDirectory: return "is a directory"
            case .permissionDenied: return "permission denied"
            case .clone(let e): return "clone: \(e)"
            case .unlink(let e): return "unlink: \(e)"
            case .attributes(let e): return "attributes: \(e)"
            case .times(let e): return "times: \(e)"
            case .mkdir(let e): return "mkdir: \(e)"
            case .rmdir(let e): return "rmdir: \(e)"
            case .operation(let s): return "operation failed: \(s)"
            }
        }
    }

    extension Windows.`32`.Kernel.File.Copy {

        public struct Options: Sendable, Equatable {

            public var overwrite: Bool

            public var copyAttributes: Bool

            public var followSymlinks: Bool

            public init(
                overwrite: Bool = false,
                copyAttributes: Bool = true,
                followSymlinks: Bool = true
            ) {
                self.overwrite = overwrite
                self.copyAttributes = copyAttributes
                self.followSymlinks = followSymlinks
            }
        }
    }

    extension Windows.`32`.Kernel.File.Copy {

        public static func copy(
            from source: borrowing Path,
            to destination: borrowing Path,
            overwrite: Bool = false
        ) throws(Error) {
            try unsafe source.view.withUnsafePointer { srcPtr throws(Error) in
                try unsafe destination.view.withUnsafePointer { dstPtr throws(Error) in
                    try copy(
                        from: srcPtr,
                        to: dstPtr,
                        overwrite: overwrite
                    )
                }
            }
        }

        public static func copy(
            from source: UnsafePointer<Path.Char>,
            to destination: UnsafePointer<Path.Char>,
            overwrite: Bool = false
        ) throws(Error) {
            let wSource = UnsafeRawPointer(source).assumingMemoryBound(to: WCHAR.self)
            let wDest = UnsafeRawPointer(destination).assumingMemoryBound(to: WCHAR.self)

            let failIfExists = !overwrite

            guard CopyFileW(wSource, wDest, failIfExists) else {
                throw Error(fromLastError: Error_Primitives.Error.captureLastError())
            }
        }

        public static func file(
            source: borrowing Path.Borrowed,
            destination: borrowing Path.Borrowed
        ) throws(Windows.`32`.Kernel.File.Clone.Error.Syscall) {
            try unsafe source.withUnsafePointer {
                srcPtr throws(Windows.`32`.Kernel.File.Clone.Error.Syscall) in
                try unsafe destination.withUnsafePointer {
                    dstPtr throws(Windows.`32`.Kernel.File.Clone.Error.Syscall) in
                    let wSource = UnsafeRawPointer(srcPtr).assumingMemoryBound(to: WCHAR.self)
                    let wDest = UnsafeRawPointer(dstPtr).assumingMemoryBound(to: WCHAR.self)
                    guard CopyFileW(wSource, wDest, true) else {
                        throw .platform(
                            code: Error_Primitives.Error.captureLastError(),
                            operation: .copyfile
                        )
                    }
                }
            }
        }
    }

    extension Windows.`32`.Kernel.File.Copy.Error {

        internal init(fromLastError code: Error_Primitives.Error.Code) {
            switch code {
            case _ where code == .Windows.ERROR_FILE_NOT_FOUND,
                _ where code == .Windows.ERROR_PATH_NOT_FOUND:
                self = .sourceNotFound

            case _ where code == .Windows.ERROR_FILE_EXISTS,
                _ where code == .Windows.ERROR_ALREADY_EXISTS:
                self = .destinationExists

            case _ where code == .Windows.ERROR_ACCESS_DENIED:
                self = .permissionDenied

            default:
                self = .operation("CopyFileW failed: \(code)")
            }
        }
    }

#endif
