internal import Error
internal import Path
internal import Random
internal import System
internal import Windows_32_Core

#if os(Windows)
    public import WinSDK

    extension Windows_32_Core.Windows.File {

        public struct Stats: Sendable, Equatable {

            public let base: Windows.`32`.Kernel.File.Stats

            public let creationTime: Windows.`32`.Kernel.Time

            @inlinable
            public init(
                base: Windows.`32`.Kernel.File.Stats,
                creationTime: Windows.`32`.Kernel.Time
            ) {
                self.base = base
                self.creationTime = creationTime
            }
        }
    }

    extension Windows_32_Core.Windows.File.Stats {

        @inlinable
        public var size: Windows.`32`.Kernel.File.Size { base.size }

        @inlinable
        public var type: Windows.`32`.Kernel.File.Stats.Kind { base.type }

        @inlinable
        public var permissions: Windows.`32`.Kernel.File.Permissions { base.permissions }

        @inlinable
        public var uid: Windows.`32`.Kernel.User.ID { base.uid }

        @inlinable
        public var gid: Windows.`32`.Kernel.Group.ID { base.gid }

        @inlinable
        public var inode: Windows.`32`.Kernel.Inode { base.inode }

        @inlinable
        public var device: Windows.`32`.Kernel.Device { base.device }

        @inlinable
        public var linkCount: Windows.`32`.Kernel.Link.Count { base.linkCount }

        @inlinable
        public var accessTime: Windows.`32`.Kernel.Time { base.accessTime }

        @inlinable
        public var modificationTime: Windows.`32`.Kernel.Time { base.modificationTime }

        @inlinable
        public var changeTime: Windows.`32`.Kernel.Time { base.changeTime }
    }

    extension Windows_32_Core.Windows.File.Stats {

        public typealias Error = Windows.`32`.Kernel.File.Stats.Error

        public static func get(path: borrowing Path) throws(Error) -> Self {
            try unsafe path.view.withUnsafePointer { ptr throws(Error) in
                try get(path: UnsafeRawPointer(ptr).assumingMemoryBound(to: WCHAR.self))
            }
        }

        package static func get(path: UnsafePointer<WCHAR>) throws(Error) -> Self {
            let handle = CreateFileW(
                path,
                DWORD(FILE_READ_ATTRIBUTES),
                DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
                nil,
                DWORD(OPEN_EXISTING),
                DWORD(FILE_FLAG_BACKUP_SEMANTICS),
                nil
            )
            guard handle != INVALID_HANDLE_VALUE else {
                throw Error(_windowsError: GetLastError())
            }
            defer { CloseHandle(handle) }

            var info = BY_HANDLE_FILE_INFORMATION()
            guard GetFileInformationByHandle(handle, &info) else {
                throw Error(_windowsError: GetLastError())
            }
            return Self(_from: info)
        }

        public static func lget(path: borrowing Path) throws(Error) -> Self {
            try unsafe path.view.withUnsafePointer { ptr throws(Error) in
                try lget(path: UnsafeRawPointer(ptr).assumingMemoryBound(to: WCHAR.self))
            }
        }

        package static func lget(path: UnsafePointer<WCHAR>) throws(Error) -> Self {
            let handle = CreateFileW(
                path,
                DWORD(FILE_READ_ATTRIBUTES),
                DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
                nil,
                DWORD(OPEN_EXISTING),
                DWORD(FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OPEN_REPARSE_POINT),
                nil
            )
            guard handle != INVALID_HANDLE_VALUE else {
                throw Error(_windowsError: GetLastError())
            }
            defer { CloseHandle(handle) }

            var info = BY_HANDLE_FILE_INFORMATION()
            guard GetFileInformationByHandle(handle, &info) else {
                throw Error(_windowsError: GetLastError())
            }
            return Self(_from: info)
        }

        package static func get(handle: UInt) throws(Error) -> Self {
            var info = BY_HANDLE_FILE_INFORMATION()
            guard GetFileInformationByHandle(UnsafeMutableRawPointer(bitPattern: handle)!, &info)
            else {
                throw Error(_windowsError: GetLastError())
            }
            return Self(_from: info)
        }

        public static func get(
            descriptor: borrowing Windows.`32`.Kernel.Descriptor
        ) throws(Error) -> Self {
            try get(handle: descriptor._rawValue)
        }
    }

    extension Windows_32_Core.Windows.File.Stats {

        internal init(_from info: BY_HANDLE_FILE_INFORMATION) {
            self.init(
                base: Windows.`32`.Kernel.File.Stats(_from: info),
                creationTime: Windows.`32`.Kernel.Time(_from: info.ftCreationTime)
            )
        }
    }

    extension Windows.`32`.Kernel.File.Stats.Error {

        internal init(_windowsError error: DWORD) {
            let errorCode = Error::Error.Code.win32(error)
            if let e = Windows.`32`.Kernel.Descriptor.Validity.Error(code: errorCode) {
                self = .handle(e)
                return
            }
            self = .platform(Error::Error(code: errorCode))
        }
    }

    extension Windows.`32`.Kernel.Time {

        internal init(_from ft: FILETIME) {

            let intervals = (Int64(ft.dwHighDateTime) << 32) | Int64(ft.dwLowDateTime)

            let epochOffset: Int64 = 116_444_736_000_000_000
            let unixIntervals = intervals - epochOffset
            let seconds = unixIntervals / 10_000_000
            let nanoseconds = Int32((unixIntervals % 10_000_000) * 100)
            self.init(
                _unchecked: (),
                secondsSinceUnixEpoch: seconds,
                nanosecondFraction: nanoseconds
            )
        }
    }

#endif
