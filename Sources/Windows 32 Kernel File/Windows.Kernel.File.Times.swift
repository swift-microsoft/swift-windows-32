#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.File.Times {

        package static func set(
            creation creationTime: FILETIME? = nil,
            access lastAccessTime: FILETIME? = nil,
            modification lastWriteTime: FILETIME? = nil,
            on handle: UInt
        ) throws(Windows.`32`.Kernel.File.Times.Error) {
            var creation = creationTime
            var access = lastAccessTime
            var write = lastWriteTime

            let success = withUnsafePointer(to: &creation) { creationPtr in
                withUnsafePointer(to: &access) { accessPtr in
                    withUnsafePointer(to: &write) { writePtr in
                        SetFileTime(
                            UnsafeMutableRawPointer(bitPattern: handle)!,
                            creationTime != nil
                                ? creationPtr.pointee.map { withUnsafePointer(to: $0) { $0 } }
                                : nil,
                            lastAccessTime != nil
                                ? accessPtr.pointee.map { withUnsafePointer(to: $0) { $0 } } : nil,
                            lastWriteTime != nil
                                ? writePtr.pointee.map { withUnsafePointer(to: $0) { $0 } } : nil
                        )
                    }
                }
            }

            guard success else {
                throw .platform(
                    Error.Error(code: Error.Error.captureLastError())
                )
            }
        }

        @inlinable
        @discardableResult
        package static func set(
            creation creationTime: UnsafePointer<FILETIME>?,
            access lastAccessTime: UnsafePointer<FILETIME>?,
            modification lastWriteTime: UnsafePointer<FILETIME>?,
            on handle: UInt
        ) -> Bool {
            SetFileTime(
                UnsafeMutableRawPointer(bitPattern: handle)!,
                creationTime,
                lastAccessTime,
                lastWriteTime
            )
        }

        package static func getTimes(
            _ handle: UInt
        ) -> (creation: FILETIME, access: FILETIME, write: FILETIME)? {
            var creation = FILETIME()
            var access = FILETIME()
            var write = FILETIME()

            guard
                GetFileTime(
                    UnsafeMutableRawPointer(bitPattern: handle)!,
                    &creation,
                    &access,
                    &write
                )
            else {
                return nil
            }

            return (creation, access, write)
        }
    }

    extension Windows.`32`.Kernel.File.Times {

        public static func set(
            creation creationTime: FILETIME? = nil,
            access lastAccessTime: FILETIME? = nil,
            modification lastWriteTime: FILETIME? = nil,
            on descriptor: borrowing Windows.`32`.Kernel.Descriptor
        ) throws(Windows.`32`.Kernel.File.Times.Error) {
            try set(
                creation: creationTime,
                access: lastAccessTime,
                modification: lastWriteTime,
                on: descriptor._rawValue
            )
        }

        @inlinable
        @discardableResult
        public static func set(
            creation creationTime: UnsafePointer<FILETIME>?,
            access lastAccessTime: UnsafePointer<FILETIME>?,
            modification lastWriteTime: UnsafePointer<FILETIME>?,
            on descriptor: borrowing Windows.`32`.Kernel.Descriptor
        ) -> Bool {
            set(
                creation: creationTime,
                access: lastAccessTime,
                modification: lastWriteTime,
                on: descriptor._rawValue
            )
        }

        public static func getTimes(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor
        ) -> (creation: FILETIME, access: FILETIME, write: FILETIME)? {
            getTimes(descriptor._rawValue)
        }
    }

    extension Windows.`32`.Kernel.File {

        package static func fileTimeFromUnix(_ time: Windows.`32`.Kernel.Time) -> FILETIME {

            let epochDifference: UInt64 = 116_444_736_000_000_000

            let windowsTime =
                UInt64(time.secondsSinceUnixEpoch) * 10_000_000
                + UInt64(time.nanosecondFraction) / 100
                + epochDifference

            return FILETIME(
                dwLowDateTime: DWORD(windowsTime & 0xFFFF_FFFF),
                dwHighDateTime: DWORD(windowsTime >> 32)
            )
        }

        package static func unixFromFileTime(_ fileTime: FILETIME) -> Int64 {

            let epochDifference: UInt64 = 116_444_736_000_000_000

            let windowsTime =
                (UInt64(fileTime.dwHighDateTime) << 32) | UInt64(fileTime.dwLowDateTime)

            return Int64((windowsTime - epochDifference) / 10_000_000)
        }

        package static func currentFileTime() -> FILETIME {
            var fileTime = FILETIME()
            GetSystemTimeAsFileTime(&fileTime)
            return fileTime
        }
    }

    extension Windows.`32`.Kernel.File {

        public struct BasicInfo: Sendable {

            package var creationTime: LARGE_INTEGER

            package var lastAccessTime: LARGE_INTEGER

            package var lastWriteTime: LARGE_INTEGER

            package var changeTime: LARGE_INTEGER

            package var fileAttributes: DWORD

            public init() {
                self.creationTime = LARGE_INTEGER()
                self.lastAccessTime = LARGE_INTEGER()
                self.lastWriteTime = LARGE_INTEGER()
                self.changeTime = LARGE_INTEGER()
                self.fileAttributes = 0
            }

            init(_ info: FILE_BASIC_INFO) {
                self.creationTime = info.CreationTime
                self.lastAccessTime = info.LastAccessTime
                self.lastWriteTime = info.LastWriteTime
                self.changeTime = info.ChangeTime
                self.fileAttributes = info.FileAttributes
            }
        }
    }

    extension Windows.`32`.Kernel.File.BasicInfo {
        func toFileBasicInfo() -> FILE_BASIC_INFO {
            FILE_BASIC_INFO(
                CreationTime: creationTime,
                LastAccessTime: lastAccessTime,
                LastWriteTime: lastWriteTime,
                ChangeTime: changeTime,
                FileAttributes: fileAttributes
            )
        }
    }

    extension Windows.`32`.Kernel.File {

        package static func getBasicInfo(
            _ handle: UInt
        ) throws(Windows.`32`.Kernel.File.Stats.Error) -> BasicInfo {
            var info = FILE_BASIC_INFO()

            let success = GetFileInformationByHandleEx(
                UnsafeMutableRawPointer(bitPattern: handle)!,
                FileBasicInfo,
                &info,
                DWORD(MemoryLayout<FILE_BASIC_INFO>.size)
            )

            guard success else {
                throw .platform(
                    Error.Error(code: Error.Error.captureLastError())
                )
            }

            return BasicInfo(info)
        }

        package static func setBasicInfo(
            _ handle: UInt,
            _ info: BasicInfo
        ) throws(Windows.`32`.Kernel.File.Attributes.Error) {
            var fileInfo = info.toFileBasicInfo()

            let success = SetFileInformationByHandle(
                UnsafeMutableRawPointer(bitPattern: handle)!,
                FileBasicInfo,
                &fileInfo,
                DWORD(MemoryLayout<FILE_BASIC_INFO>.size)
            )

            guard success else {
                throw .platform(
                    Error.Error(code: Error.Error.captureLastError())
                )
            }
        }

        public static func getBasicInfo(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor
        ) throws(Windows.`32`.Kernel.File.Stats.Error) -> BasicInfo {
            try getBasicInfo(descriptor._rawValue)
        }

        public static func setBasicInfo(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
            _ info: BasicInfo
        ) throws(Windows.`32`.Kernel.File.Attributes.Error) {
            try setBasicInfo(descriptor._rawValue, info)
        }

    }

    extension Windows.`32`.Kernel.File {

        package static func touch(_ handle: UInt) -> Bool {
            var now = FILETIME()
            GetSystemTimeAsFileTime(&now)
            return SetFileTime(UnsafeMutableRawPointer(bitPattern: handle)!, nil, &now, &now)
        }

        public static func touch(_ descriptor: borrowing Windows.`32`.Kernel.Descriptor) -> Bool {
            touch(descriptor._rawValue)
        }
    }

#endif
