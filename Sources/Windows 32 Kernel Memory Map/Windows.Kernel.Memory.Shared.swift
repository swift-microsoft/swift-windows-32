// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-32 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-windows-32 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
    public import Error_Primitives
    public import Memory_Primitives
    public import WinSDK

    // MARK: - Create/Open Shared Memory

    extension Memory.Shared {
        /// Creates or opens a named shared memory object.
        ///
        /// This creates a file mapping backed by the system paging file,
        /// equivalent to POSIX `shm_open` + `ftruncate` + `mmap`.
        ///
        /// - Parameters:
        ///   - name: The name of the shared memory object (e.g., "Local\\MySharedMem").
        ///   - size: The size of the shared memory region in bytes.
        ///   - protection: Memory protection flags.
        /// - Returns: Handle to the file mapping object.
        /// - Throws: `Memory.Shared.Error` on failure.
        package static func create(
            unsafeName: UnsafePointer<WCHAR>,
            size: UInt64,
            protection: Memory.Map.Protection
        ) throws(Memory.Shared.Error) -> HANDLE {
            let sizeHigh = DWORD(size >> 32)
            let sizeLow = DWORD(size & 0xFFFF_FFFF)

            let handle = CreateFileMappingW(
                INVALID_HANDLE_VALUE,  // Use paging file
                nil,  // Default security
                protection.windowsFileMapProtect,
                sizeHigh,
                sizeLow,
                unsafeName
            )

            guard let handle, handle != INVALID_HANDLE_VALUE else {
                throw .open(Error_Primitives.Error.captureLastError())
            }

            return handle
        }

        /// Opens an existing named shared memory object.
        ///
        /// - Parameters:
        ///   - name: The name of the shared memory object.
        ///   - access: Desired access (FILE_MAP_READ, FILE_MAP_WRITE, FILE_MAP_ALL_ACCESS).
        /// - Returns: Handle to the file mapping object.
        /// - Throws: `Memory.Shared.Error` on failure.
        package static func open(
            unsafeName: UnsafePointer<WCHAR>,
            access: DWORD
        ) throws(Memory.Shared.Error) -> HANDLE {
            let handle = OpenFileMappingW(
                access,
                false,  // Don't inherit handle
                unsafeName
            )

            guard let handle, handle != INVALID_HANDLE_VALUE else {
                throw .open(Error_Primitives.Error.captureLastError())
            }

            return handle
        }

        /// Closes a shared memory handle.
        ///
        /// - Parameter handle: The file mapping handle.
        @inlinable
        package static func close(_ handle: HANDLE) {
            _ = CloseHandle(handle)
        }
    }

    extension Memory.Shared {
        /// Creates or opens a named shared memory object through the typed
        /// platform contract.
        ///
        /// Creation options are meaningful only when `.create` is present.
        /// Windows does not truncate an existing page-file mapping; `.truncate`
        /// is therefore accepted as a portable no-op.
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
                        unsafeName: UnsafeRawPointer(buffer.baseAddress!).assumingMemoryBound(to: WCHAR.self),
                        size: UInt64(size.underlying),
                        protection: access.protection
                    )
                } catch {
                    openError = error
                }
            }

            if let handle {
                let error = Error_Primitives.Error.captureLastError()
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

        /// Opens an existing named shared memory object through the typed
        /// platform contract.
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
                        unsafeName: UnsafeRawPointer(buffer.baseAddress!).assumingMemoryBound(to: WCHAR.self),
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

    // MARK: - Map/Unmap Shared Memory

    extension Memory.Shared {
        /// Maps a view of the shared memory into the process address space.
        ///
        /// - Parameters:
        ///   - handle: The file mapping handle.
        ///   - access: Desired access (FILE_MAP_READ, FILE_MAP_WRITE, FILE_MAP_ALL_ACCESS).
        ///   - offset: Offset into the shared memory to start the view.
        ///   - size: Size of the view (0 for entire mapping from offset).
        /// - Returns: Pointer to the mapped view.
        /// - Throws: `Memory.Shared.Error` on failure.
        public static func map(
            _ handle: HANDLE,
            // FILE_MAP_ALL_ACCESS is a compound macro not importable by Swift; value = SECTION_ALL_ACCESS = 0xF001F
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
                throw .open(Error_Primitives.Error.captureLastError())
            }

            return ptr
        }

        /// Unmaps a view of shared memory.
        ///
        /// - Parameter address: The base address of the mapped view.
        /// - Returns: True on success, false on failure.
        @inlinable
        @discardableResult
        public static func unmap(_ address: UnsafeMutableRawPointer) -> Bool {
            UnmapViewOfFile(address)
        }
    }

    // MARK: - Access Flags

    extension Memory.Shared {
        /// Shared memory access flags.
        public struct Access: OptionSet, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Memory.Shared.Access {
        /// Whether this mode permits reading.
        @inlinable
        public var read: Bool {
            contains(.read)
        }

        /// Whether this mode permits writing.
        @inlinable
        public var write: Bool {
            contains(.write)
        }

        /// Creates an access mode with explicit read/write permissions.
        @inlinable
        public init(read: Bool, write: Bool) {
            self.init(
                rawValue:
                    (read ? UInt32(FILE_MAP_READ) : 0)
                    | (write ? UInt32(FILE_MAP_WRITE) : 0)
            )
        }

        @usableFromInline
        internal var protection: Memory.Map.Protection {
            contains(.write) ? .readWrite : .read
        }

        /// Read access.
        public static let read = Self(rawValue: UInt32(FILE_MAP_READ))

        /// Write access.
        public static let write = Self(rawValue: UInt32(FILE_MAP_WRITE))

        /// Read and write access.
        public static let readWrite: Self = [.read, .write]

        // FILE_MAP_ALL_ACCESS is a compound macro not importable by Swift; value = SECTION_ALL_ACCESS = 0xF001F
        /// All access (read, write, copy).
        public static let all = Self(rawValue: 0xF001F)

        /// Copy-on-write access.
        public static let copy = Self(rawValue: UInt32(FILE_MAP_COPY))

        /// Execute access (requires PAGE_EXECUTE_* protection).
        public static let execute = Self(rawValue: UInt32(FILE_MAP_EXECUTE))
    }

#endif
