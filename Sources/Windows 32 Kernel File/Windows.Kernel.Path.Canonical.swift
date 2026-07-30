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
    internal import WinSDK
    public import String_Primitives

    // MARK: - Windows GetFullPathNameW syscall

    extension Path.Canonical {
        /// Resolves a path to its lexically normalized absolute form.
        ///
        /// This operation uses `GetFullPathNameW`. It does not access the file
        /// system, require the path to exist, or resolve symbolic links and
        /// other reparse points. Use ``canonicalize(_:)`` when physical
        /// canonicalization is required.
        ///
        /// - Parameters:
        ///   - path: The path to resolve.
        ///   - buffer: Buffer to receive the canonical path (UTF-16).
        /// - Returns: The count of UTF-16 code units written (excluding the null terminator).
        /// - Throws: `Path.Canonical.Error` on failure.
        public static func resolve(
            path: borrowing Path,
            into buffer: UnsafeMutableBufferPointer<UInt16>
        ) throws(Path.Canonical.Error) -> Cardinal {
            try unsafe path.view.withUnsafePointer { ptr throws(Path.Canonical.Error) in
                try resolve(unsafePath: ptr, into: buffer)
            }
        }

        /// Resolves a path to its lexically normalized absolute form using an
        /// unsafe wide string.
        ///
        /// This operation does not access the file system or resolve reparse
        /// points.
        ///
        /// - Parameters:
        ///   - unsafePath: The path as a null-terminated wide string.
        ///   - buffer: Buffer to receive the canonical path (UTF-16).
        /// - Returns: The count of UTF-16 code units written (excluding the null terminator).
        /// - Throws: `Path.Canonical.Error` on failure.
        public static func resolve(
            unsafePath: UnsafePointer<Path.Char>,
            into buffer: UnsafeMutableBufferPointer<UInt16>
        ) throws(Path.Canonical.Error) -> Cardinal {
            let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)
            let wbuffer = UnsafeMutableRawPointer(buffer.baseAddress!).assumingMemoryBound(to: WCHAR.self)

            let result = GetFullPathNameW(wpath, DWORD(buffer.count), wbuffer, nil)

            guard result > 0 else {
                throw .current()
            }

            // If result > buffer.count, the buffer was too small
            if result > buffer.count {
                throw .platform(Error_Primitives.Error(code: .win32(DWORD(ERROR_INSUFFICIENT_BUFFER))))
            }

            return Cardinal(result)
        }

        /// Resolves a path to its lexically normalized absolute form, returning
        /// an array.
        ///
        /// This operation does not access the file system or resolve reparse
        /// points.
        ///
        /// - Parameter path: The path to resolve.
        /// - Returns: The canonical path as UTF-16 code units.
        /// - Throws: `Path.Canonical.Error` on failure.
        public static func resolve(
            path: borrowing Path
        ) throws(Path.Canonical.Error) -> [UInt16] {
            try unsafe path.view.withUnsafePointer { ptr throws(Path.Canonical.Error) in
                try resolve(unsafePath: ptr)
            }
        }

        /// Resolves a path to its lexically normalized absolute form using an
        /// unsafe wide string.
        ///
        /// This operation does not access the file system or resolve reparse
        /// points.
        ///
        /// - Parameter unsafePath: The path as a null-terminated wide string.
        /// - Returns: The canonical path as UTF-16 code units.
        /// - Throws: `Path.Canonical.Error` on failure.
        public static func resolve(
            unsafePath: UnsafePointer<Path.Char>
        ) throws(Path.Canonical.Error) -> [UInt16] {
            let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)

            // First call to get required size
            let requiredSize = GetFullPathNameW(wpath, 0, nil, nil)
            guard requiredSize > 0 else {
                throw .current()
            }

            var buffer = [UInt16](repeating: 0, count: Int(requiredSize))
            // Call GetFullPathNameW directly: routing through resolve(unsafePath:into:)
            // inside withUnsafeMutableBufferPointer erases the typed throw to any Error.
            let written = GetFullPathNameW(wpath, requiredSize, &buffer, nil)
            guard written > 0, written < requiredSize else {
                throw .current()
            }

            // Trim to actual length (excluding null terminator)
            return Array(buffer.prefix(Int(written)))
        }
    }

    // MARK: - Windows GetFinalPathNameByHandleW syscall

    extension Path.Canonical {
        /// Canonical primitive: scoped access to a physical path's UTF-16 code
        /// units.
        ///
        /// The path must identify an existing file-system object. This
        /// operation follows symbolic links and other reparse points, removes
        /// lexical `.` and `..` components, and returns the normalized absolute
        /// path reported for the opened object by
        /// `GetFinalPathNameByHandleW`.
        ///
        /// The returned span preserves Windows' extended DOS namespace prefix:
        /// local paths begin with `\\?\` and UNC paths begin with
        /// `\\?\UNC\`. Preserving that prefix keeps long paths round-trippable
        /// and avoids corrupting UNC paths through indiscriminate prefix
        /// stripping.
        ///
        /// - Parameters:
        ///   - path: The existing path to canonicalize.
        ///   - body: A non-throwing closure that receives the canonical UTF-16
        ///     code units without the null terminator.
        /// - Returns: The result of `body`.
        /// - Throws: ``Path.Canonical.Error`` when the object cannot be opened
        ///   or its final path cannot be read.
        public static func withCanonicalBytes<R: ~Copyable>(
            _ path: borrowing Path.Borrowed,
            _ body: (Swift.Span<Path.Char>) -> R
        ) throws(Path.Canonical.Error) -> R {
            try unsafe path.withUnsafePointer { unsafePath throws(Path.Canonical.Error) in
                try withFinalPath(unsafePath: unsafePath) { pointer, count in
                    let span = unsafe Swift.Span(_unsafeStart: pointer, count: count)
                    return body(span)
                }
            }
        }

        /// Provides scoped access to a physical canonical path as a
        /// null-terminated string view.
        ///
        /// The returned view preserves the `\\?\` or `\\?\UNC\` prefix
        /// produced by `GetFinalPathNameByHandleW`.
        ///
        /// - Parameters:
        ///   - path: The existing path to canonicalize.
        ///   - body: A non-throwing closure that receives the canonical path.
        /// - Returns: The result of `body`.
        /// - Throws: ``Path.Canonical.Error`` when physical canonicalization
        ///   fails.
        public static func withCanonical<R: ~Copyable>(
            _ path: borrowing Path.Borrowed,
            _ body: (borrowing String_Primitives.String.Borrowed) -> R
        ) throws(Path.Canonical.Error) -> R {
            try unsafe path.withUnsafePointer { unsafePath throws(Path.Canonical.Error) in
                try withFinalPath(unsafePath: unsafePath) { pointer, count in
                    let view = unsafe String_Primitives.String.Borrowed(pointer, count: count)
                    return body(view)
                }
            }
        }

        /// Resolves an existing path to its physical canonical absolute form.
        ///
        /// Unlike ``resolve(path:)``, this operation accesses the file system
        /// and follows symbolic links and other reparse points. The returned
        /// string preserves the extended DOS namespace prefix emitted by
        /// `GetFinalPathNameByHandleW`.
        ///
        /// - Parameter path: The existing path to canonicalize.
        /// - Returns: The physical canonical path.
        /// - Throws: ``Path.Canonical.Error`` when physical canonicalization
        ///   fails.
        public static func canonicalize(
            _ path: borrowing Path.Borrowed
        ) throws(Path.Canonical.Error) -> String_Primitives.String {
            try withCanonical(path) { view in
                String_Primitives.String(copying: view)
            }
        }

        /// Opens an existing object while following reparse points and provides
        /// scoped access to the final path returned for the opened handle.
        private static func withFinalPath<R: ~Copyable>(
            unsafePath: UnsafePointer<Path.Char>,
            _ body: (UnsafePointer<Path.Char>, Int) -> R
        ) throws(Path.Canonical.Error) -> R {
            let wpath = unsafe UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)
            let handle = CreateFileW(
                wpath,
                0,
                DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
                nil,
                DWORD(OPEN_EXISTING),
                DWORD(FILE_FLAG_BACKUP_SEMANTICS),
                nil
            )

            guard handle != INVALID_HANDLE_VALUE else {
                throw .current()
            }
            defer { _ = CloseHandle(handle) }

            // VOLUME_NAME_DOS is the zero-valued default. Pairing it with
            // FILE_NAME_NORMALIZED therefore has this exact flag value.
            let flags = DWORD(FILE_NAME_NORMALIZED)
            let requiredSize = GetFinalPathNameByHandleW(handle, nil, 0, flags)
            guard requiredSize > 0 else {
                throw .current()
            }

            var capacity = Int(requiredSize)
            while true {
                let buffer = UnsafeMutablePointer<Path.Char>.allocate(capacity: capacity)
                let wbuffer = unsafe UnsafeMutableRawPointer(buffer)
                    .assumingMemoryBound(to: WCHAR.self)
                let written = GetFinalPathNameByHandleW(
                    handle,
                    wbuffer,
                    DWORD(capacity),
                    flags
                )

                guard written > 0 else {
                    unsafe buffer.deallocate()
                    throw .current()
                }

                if Int(written) < capacity {
                    let result = body(unsafe UnsafePointer(buffer), Int(written))
                    unsafe buffer.deallocate()
                    return result
                }

                unsafe buffer.deallocate()
                capacity = Int(written)
            }
        }
    }

    // MARK: - Error Construction

    extension Path.Canonical.Error {
        /// Creates an error from the current Win32 last error.
        @usableFromInline
        internal static func current() -> Self {
            let code = Error_Primitives.Error.captureLastError()
            if let e = Path.Resolution.Error(code: code) {
                return .path(e)
            }
            return .platform(Error_Primitives.Error(code: code))
        }
    }

#endif
