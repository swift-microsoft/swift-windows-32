#if os(Windows)
    public import Error
    public import Memory
    public import WinSDK

    extension Memory.Shared {

        package static func create(
            unsafeName: UnsafePointer<WCHAR>,
            size: UInt64,
            protection: Memory.Map.Protection
        ) throws(Memory.Shared.Error) -> HANDLE {
            let sizeHigh = DWORD(size >> 32)
            let sizeLow = DWORD(size & 0xFFFF_FFFF)

            let handle = CreateFileMappingW(
                INVALID_HANDLE_VALUE,
                nil,
                protection.windowsFileMapProtect,
                sizeHigh,
                sizeLow,
                unsafeName
            )

            guard let handle, handle != INVALID_HANDLE_VALUE else {
                throw .open(Error.Error.captureLastError())
            }

            return handle
        }

        package static func open(
            unsafeName: UnsafePointer<WCHAR>,
            access: DWORD
        ) throws(Memory.Shared.Error) -> HANDLE {
            let handle = OpenFileMappingW(
                access,
                false,
                unsafeName
            )

            guard let handle, handle != INVALID_HANDLE_VALUE else {
                throw .open(Error.Error.captureLastError())
            }

            return handle
        }

        @inlinable
        package static func close(_ handle: HANDLE) {
            _ = CloseHandle(handle)
        }
    }

    extension Memory.Shared {

        public static func open(
            name: Swift.String,
            size: Windows.`32`.Kernel.File.Size,
            access: Memory.Shared.Access,
            options: Memory.Shared.Options = []
        ) throws(Memory.Shared.Error) -> Windows.`32`.Kernel.Descriptor {
            guard options.contains(.create) else {
                return try open(name: name, access: access)
            }

            var wideName = Array(name.utf16)
            wideName.append(0)

            var handle: UnsafeMutableRawPointer?
            var openError: Memory.Shared.Error?
            wideName.withUnsafeBufferPointer { buffer in
                do throws(Self.Error) {
                    handle = try create(
                        unsafeName: UnsafeRawPointer(buffer.baseAddress!).assumingMemoryBound(
                            to: WCHAR.self
                        ),
                        size: UInt64(size.underlying),
                        protection: access.protection
                    )
                } catch {
                    openError = error
                }
            }

            if let handle {
                let error = Error.Error.captureLastError()
                if options.contains(.exclusive), GetLastError() == DWORD(ERROR_ALREADY_EXISTS) {
                    _ = CloseHandle(handle)
                    throw .open(error)
                }
                return Windows.`32`.Kernel.Descriptor(_rawValue: UInt(bitPattern: handle))
            }
            if let openError {
                throw openError
            }
            preconditionFailure("withUnsafeBufferPointer must set handle or openError")
        }

        public static func open(
            name: Swift.String,
            access: Memory.Shared.Access
        ) throws(Memory.Shared.Error) -> Windows.`32`.Kernel.Descriptor {
            var wideName = Array(name.utf16)
            wideName.append(0)

            var handle: UnsafeMutableRawPointer?
            var openError: Memory.Shared.Error?
            wideName.withUnsafeBufferPointer { buffer in
                do throws(Self.Error) {
                    handle = try open(
                        unsafeName: UnsafeRawPointer(buffer.baseAddress!).assumingMemoryBound(
                            to: WCHAR.self
                        ),
                        access: DWORD(access.rawValue)
                    )
                } catch {
                    openError = error
                }
            }

            if let handle {
                return Windows.`32`.Kernel.Descriptor(_rawValue: UInt(bitPattern: handle))
            }
            if let openError {
                throw openError
            }
            preconditionFailure("withUnsafeBufferPointer must set handle or openError")
        }
    }

    extension Memory.Shared {

        public static func map(
            _ handle: HANDLE,

            access: DWORD = 0xF001F,
            offset: UInt64 = 0,
            size: Int = 0
        ) throws(Memory.Shared.Error) -> UnsafeMutableRawPointer {
            let offsetHigh = DWORD(offset >> 32)
            let offsetLow = DWORD(offset & 0xFFFF_FFFF)

            guard
                let ptr = MapViewOfFile(
                    handle,
                    access,
                    offsetHigh,
                    offsetLow,
                    SIZE_T(size)
                )
            else {
                throw .open(Error.Error.captureLastError())
            }

            return ptr
        }

        @inlinable
        @discardableResult
        public static func unmap(_ address: UnsafeMutableRawPointer) -> Bool {
            UnmapViewOfFile(address)
        }
    }

    extension Memory.Shared {

        public struct Access: OptionSet, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Memory.Shared.Access {

        @inlinable
        public var read: Bool {
            contains(.read)
        }

        @inlinable
        public var write: Bool {
            contains(.write)
        }

        @inlinable
        public init(read: Bool, write: Bool) {
            self.init(
                rawValue: (read ? UInt32(FILE_MAP_READ) : 0)
                    | (write ? UInt32(FILE_MAP_WRITE) : 0)
            )
        }

        @usableFromInline
        internal var protection: Memory.Map.Protection {
            contains(.write) ? .readWrite : .read
        }

        public static let read = Self(rawValue: UInt32(FILE_MAP_READ))

        public static let write = Self(rawValue: UInt32(FILE_MAP_WRITE))

        public static let readWrite: Self = [.read, .write]

        public static let all = Self(rawValue: 0xF001F)

        public static let copy = Self(rawValue: UInt32(FILE_MAP_COPY))

        public static let execute = Self(rawValue: UInt32(FILE_MAP_EXECUTE))
    }

#endif
