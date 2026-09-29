#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.File {

        public enum Rename {}
    }

    extension Windows.`32`.Kernel.File.Rename {

        public struct Error: Swift.Error, Sendable {
            public let code: Error::Error.Code

            public init(code: Error::Error.Code) {
                self.code = code
            }
        }
    }

    extension Windows.`32`.Kernel.File.Rename.Error {

        public static let destinationExists = Self(
            code: .win32(Error::Error.Code.File.alreadyExists)
        )

        public static let permissionDenied = Self(
            code: .win32(Error::Error.Code.Access.denied)
        )

        public static let sharingViolation = Self(
            code: .win32(Error::Error.Code.Access.sharingViolation)
        )

        public static let notSupported = Self(code: .win32(0x32))

        @usableFromInline
        internal static func current() -> Self {
            Self(code: Error.Error.captureLastError())
        }

        public var isTransient: Bool {
            guard let win32 = code.win32 else { return false }
            switch win32 {
            case Error::Error.Code.Access.denied,
                Error::Error.Code.Access.sharingViolation,
                Error::Error.Code.Access.lockViolation:
                return true

            default:
                return false
            }
        }

        public var isDestinationExists: Bool {
            guard let win32 = code.win32 else { return false }
            switch win32 {
            case Error::Error.Code.File.exists,
                Error::Error.Code.File.alreadyExists:
                return true

            default:
                return false
            }
        }
    }

    extension Windows.`32`.Kernel.File.Rename {

        public static func atomic(
            from source: borrowing Path,
            to destination: borrowing Path,
            replaceExisting: Bool
        ) throws(Error) {
            try unsafe source.view.withUnsafePointer { srcPtr throws(Error) in
                try unsafe destination.view.withUnsafePointer { dstPtr throws(Error) in
                    try atomic(
                        from: srcPtr,
                        to: dstPtr,
                        replaceExisting: replaceExisting
                    )
                }
            }
        }

        public static func atomic(
            from source: UnsafePointer<Path.Char>,
            to destination: UnsafePointer<Path.Char>,
            replaceExisting: Bool
        ) throws(Error) {
            let wSource = UnsafeRawPointer(source).assumingMemoryBound(to: WCHAR.self)
            let wDest = UnsafeRawPointer(destination).assumingMemoryBound(to: WCHAR.self)

            let handle = CreateFileW(
                wSource,
                DWORD(DELETE) | DWORD(SYNCHRONIZE),
                DWORD(FILE_SHARE_READ) | DWORD(FILE_SHARE_WRITE) | DWORD(FILE_SHARE_DELETE),
                nil,
                DWORD(OPEN_EXISTING),
                DWORD(FILE_FLAG_BACKUP_SEMANTICS),
                nil
            )

            guard handle != INVALID_HANDLE_VALUE else {
                throw .current()
            }
            defer { _ = CloseHandle(handle) }

            var destLength = 0
            var ptr = wDest
            while ptr.pointee != 0 {
                destLength += 1
                ptr += 1
            }

            guard let fileNameOffset = MemoryLayout<FILE_RENAME_INFO>.offset(of: \.FileName) else {
                throw .notSupported
            }

            let nameByteCount = (destLength + 1) * MemoryLayout<WCHAR>.size
            let totalSize = fileNameOffset + nameByteCount

            let alignment = max(
                MemoryLayout<FILE_RENAME_INFO>.alignment,
                MemoryLayout<WCHAR>.alignment
            )
            let buffer = UnsafeMutableRawPointer.allocate(
                byteCount: totalSize,
                alignment: alignment
            )
            defer { buffer.deallocate() }

            let headerSize = MemoryLayout<FILE_RENAME_INFO>.size
            buffer.initializeMemory(
                as: UInt8.self,
                repeating: 0,
                count: min(headerSize, totalSize)
            )

            let info = buffer.assumingMemoryBound(to: FILE_RENAME_INFO.self)
            info.pointee.Flags = replaceExisting ? DWORD(FILE_RENAME_FLAG_REPLACE_IF_EXISTS) : 0
            info.pointee.RootDirectory = nil
            info.pointee.FileNameLength = DWORD(nameByteCount - MemoryLayout<WCHAR>.size)

            let fileNamePtr = buffer.advanced(by: fileNameOffset).assumingMemoryBound(
                to: WCHAR.self
            )
            var srcPtr = wDest
            var dstIdx = 0
            while srcPtr.pointee != 0 {
                fileNamePtr[dstIdx] = srcPtr.pointee
                srcPtr += 1
                dstIdx += 1
            }
            fileNamePtr[dstIdx] = 0

            let success = SetFileInformationByHandle(
                handle,
                FileRenameInfoEx,
                buffer,
                DWORD(totalSize)
            )

            guard success else {
                throw .current()
            }
        }
    }

#endif
