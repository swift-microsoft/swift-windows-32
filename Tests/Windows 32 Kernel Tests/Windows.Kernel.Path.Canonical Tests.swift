// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error_Primitives
    import Path_Primitives
    import Clock_Primitives
    import Random_Primitives
    import System_Primitives

    extension Path.Canonical {
        enum Test {
            @Suite struct Unit {}
            @Suite struct `Edge Case` {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Namespace Tests

    extension Path.Canonical.Test.Unit {
        @Test
        func `Path.Canonical namespace exists`() {
            _ = Path.Canonical.self
        }

        @Test
        func `physical resolution errors retain semantic path failures`() {
            #expect(
                Path.Resolution.Error(code: .Windows.ERROR_CANT_RESOLVE_FILENAME)
                    == .loop
            )
            #expect(
                Path.Resolution.Error(code: .Windows.ERROR_FILENAME_EXCED_RANGE)
                    == .nameTooLong
            )
        }
    }

    // MARK: - Resolve Tests

    extension Path.Canonical.Test.Unit {
        @Test
        func `lexical resolve of current directory succeeds`() throws {
            var path = Array(".".utf16) + [0]
            let result = try path.withUnsafeBufferPointer { pathPtr in
                let wpath = UnsafeRawPointer(pathPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                return try Path.Canonical.resolve(unsafePath: wpath)
            }

            #expect(!result.isEmpty)
        }

        @Test
        func `lexical resolve with buffer succeeds`() throws {
            var path = Array(".".utf16) + [0]
            var buffer = [UInt16](repeating: 0, count: 260)

            let length = try path.withUnsafeBufferPointer { pathPtr in
                try buffer.withUnsafeMutableBufferPointer { bufferPtr in
                    let wpath = UnsafeRawPointer(pathPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                    return try Path.Canonical.resolve(unsafePath: wpath, into: bufferPtr)
                }
            }

            #expect(length > 0)
        }

        @Test
        func `lexical resolve of absolute path returns same path`() throws {
            var path = Array("C:\\Windows".utf16) + [0]
            let result = try path.withUnsafeBufferPointer { pathPtr in
                let wpath = UnsafeRawPointer(pathPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                return try Path.Canonical.resolve(unsafePath: wpath)
            }

            let resultString = String(decoding: result, as: UTF16.self)
            #expect(resultString.uppercased().hasPrefix("C:\\WINDOWS"))
        }

        @Test
        func `physical canonicalization of existing directory preserves extended prefix`() throws {
            var path = Array(".".utf16) + [0]
            let result = try path.withUnsafeBufferPointer { pathPointer in
                let borrowed = unsafe Path.Borrowed(
                    pathPointer.baseAddress!,
                    count: pathPointer.indices.dropLast().count
                )
                return try Path.Canonical.canonicalize(borrowed)
            }

            let resultString = Swift.String(result.view)
            #expect(resultString.hasPrefix("\\\\?\\"))
            #expect(!resultString.hasSuffix("\\."))
        }

        @Test
        func `physical canonicalization resolves an existing file`() throws {
            let name =
                "swift-windows-32-canonical-file-\(GetCurrentProcessId())-\(GetTickCount64()).tmp"
            var path = Array(name.utf16) + [0]

            let handle = path.withUnsafeBufferPointer { pathPointer in
                CreateFileW(
                    pathPointer.baseAddress,
                    DWORD(GENERIC_READ) | DWORD(GENERIC_WRITE),
                    DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
                    nil,
                    DWORD(CREATE_NEW),
                    DWORD(FILE_ATTRIBUTE_NORMAL),
                    nil
                )
            }
            guard let handle, handle != INVALID_HANDLE_VALUE else {
                Issue.record("Could not create canonicalization test file: \(GetLastError())")
                return
            }
            _ = CloseHandle(handle)
            defer {
                _ = path.withUnsafeBufferPointer { pathPointer in
                    DeleteFileW(pathPointer.baseAddress)
                }
            }

            let result = try path.withUnsafeBufferPointer { pathPointer in
                let borrowed = unsafe Path.Borrowed(
                    pathPointer.baseAddress!,
                    count: pathPointer.indices.dropLast().count
                )
                return try Path.Canonical.canonicalize(borrowed)
            }

            let resultString = Swift.String(result.view)
            #expect(resultString.hasPrefix("\\\\?\\"))
            #expect(resultString.hasSuffix("\\\(name)"))
        }

        @Test
        func `physical canonicalization follows a symbolic link`() throws {
            let token = "\(GetCurrentProcessId())-\(GetTickCount64())"
            let targetName = "swift-windows-32-canonical-target-\(token).tmp"
            let linkName = "swift-windows-32-canonical-link-\(token).tmp"
            var target = Array(targetName.utf16) + [0]
            var link = Array(linkName.utf16) + [0]

            let targetHandle = target.withUnsafeBufferPointer { targetPointer in
                CreateFileW(
                    targetPointer.baseAddress,
                    DWORD(GENERIC_READ) | DWORD(GENERIC_WRITE),
                    DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
                    nil,
                    DWORD(CREATE_NEW),
                    DWORD(FILE_ATTRIBUTE_NORMAL),
                    nil
                )
            }
            guard let targetHandle, targetHandle != INVALID_HANDLE_VALUE else {
                Issue.record("Could not create symbolic-link target: \(GetLastError())")
                return
            }
            _ = CloseHandle(targetHandle)
            defer {
                _ = target.withUnsafeBufferPointer { targetPointer in
                    DeleteFileW(targetPointer.baseAddress)
                }
            }

            let created = link.withUnsafeBufferPointer { linkPointer in
                target.withUnsafeBufferPointer { targetPointer in
                    CreateSymbolicLinkW(
                        linkPointer.baseAddress,
                        targetPointer.baseAddress,
                        DWORD(SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE)
                    )
                }
            }
            guard created != 0 else {
                Issue.record("Could not create symbolic link: \(GetLastError())")
                return
            }
            defer {
                _ = link.withUnsafeBufferPointer { linkPointer in
                    DeleteFileW(linkPointer.baseAddress)
                }
            }

            let targetCanonical = try target.withUnsafeBufferPointer { targetPointer in
                let borrowed = unsafe Path.Borrowed(
                    targetPointer.baseAddress!,
                    count: targetPointer.indices.dropLast().count
                )
                return try Path.Canonical.canonicalize(borrowed)
            }
            let linkCanonical = try link.withUnsafeBufferPointer { linkPointer in
                let borrowed = unsafe Path.Borrowed(
                    linkPointer.baseAddress!,
                    count: linkPointer.indices.dropLast().count
                )
                return try Path.Canonical.canonicalize(borrowed)
            }

            #expect(Swift.String(linkCanonical.view) == Swift.String(targetCanonical.view))
        }

        @Test
        func `physical canonicalization supports an extended path beyond MAX_PATH`() throws {
            var currentPath = Array(".".utf16) + [0]
            let current = try currentPath.withUnsafeBufferPointer { pathPointer in
                let borrowed = unsafe Path.Borrowed(
                    pathPointer.baseAddress!,
                    count: pathPointer.indices.dropLast().count
                )
                return try Path.Canonical.canonicalize(borrowed)
            }

            let token = "\(GetCurrentProcessId())-\(GetTickCount64())"
            let suffix = "-\(token)"
            let component =
                Swift.String(repeating: "x", count: 240 - suffix.count)
                + suffix
            let extendedPath = Swift.String(current.view) + "\\" + component
            var path = Array(extendedPath.utf16) + [0]

            let created = path.withUnsafeBufferPointer { pathPointer in
                CreateDirectoryW(pathPointer.baseAddress, nil)
            }
            guard created != 0 else {
                Issue.record("Could not create extended-path test directory: \(GetLastError())")
                return
            }
            defer {
                _ = path.withUnsafeBufferPointer { pathPointer in
                    RemoveDirectoryW(pathPointer.baseAddress)
                }
            }

            let result = try path.withUnsafeBufferPointer { pathPointer in
                let borrowed = unsafe Path.Borrowed(
                    pathPointer.baseAddress!,
                    count: pathPointer.indices.dropLast().count
                )
                return try Path.Canonical.canonicalize(borrowed)
            }
            let resultString = Swift.String(result.view)

            #expect(resultString.utf16.count > Int(MAX_PATH))
            #expect(resultString == extendedPath)
        }

        @Test
        func `lexical resolve succeeds where physical canonicalization reports not found`() throws {
            let missing =
                "C:\\swift-windows-32-canonical-missing-\(GetCurrentProcessId())-\(GetTickCount64())"
            var path = Array(missing.utf16) + [0]

            let lexical = try path.withUnsafeBufferPointer { pathPointer in
                let unsafePath = unsafe UnsafeRawPointer(pathPointer.baseAddress!)
                    .assumingMemoryBound(to: UInt16.self)
                return try Path.Canonical.resolve(unsafePath: unsafePath)
            }
            #expect(!lexical.isEmpty)

            #expect(throws: Path.Canonical.Error.path(.notFound)) {
                _ = try path.withUnsafeBufferPointer { pathPointer in
                    let borrowed = unsafe Path.Borrowed(
                        pathPointer.baseAddress!,
                        count: pathPointer.indices.dropLast().count
                    )
                    return try Path.Canonical.canonicalize(borrowed)
                }
            }
        }
    }

    // MARK: - Edge Cases

    extension Path.Canonical.Test.`Edge Case` {
        @Test
        func `physical canonicalization reports a symbolic-link loop`() throws {
            let token = "\(GetCurrentProcessId())-\(GetTickCount64())"
            let firstName = "swift-windows-32-canonical-loop-first-\(token)"
            let secondName = "swift-windows-32-canonical-loop-second-\(token)"
            var first = Array(firstName.utf16) + [0]
            var second = Array(secondName.utf16) + [0]

            let createdFirst = first.withUnsafeBufferPointer { firstPointer in
                second.withUnsafeBufferPointer { secondPointer in
                    CreateSymbolicLinkW(
                        firstPointer.baseAddress,
                        secondPointer.baseAddress,
                        DWORD(SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE)
                    )
                }
            }
            guard createdFirst != 0 else {
                Issue.record("Could not create first loop link: \(GetLastError())")
                return
            }
            defer {
                _ = first.withUnsafeBufferPointer { firstPointer in
                    DeleteFileW(firstPointer.baseAddress)
                }
            }

            let createdSecond = second.withUnsafeBufferPointer { secondPointer in
                first.withUnsafeBufferPointer { firstPointer in
                    CreateSymbolicLinkW(
                        secondPointer.baseAddress,
                        firstPointer.baseAddress,
                        DWORD(SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE)
                    )
                }
            }
            guard createdSecond != 0 else {
                Issue.record("Could not create second loop link: \(GetLastError())")
                return
            }
            defer {
                _ = second.withUnsafeBufferPointer { secondPointer in
                    DeleteFileW(secondPointer.baseAddress)
                }
            }

            #expect(throws: Path.Canonical.Error.path(.loop)) {
                _ = try first.withUnsafeBufferPointer { firstPointer in
                    let borrowed = unsafe Path.Borrowed(
                        firstPointer.baseAddress!,
                        count: firstPointer.indices.dropLast().count
                    )
                    return try Path.Canonical.canonicalize(borrowed)
                }
            }
        }

        @Test
        func `lexical resolve with small buffer throws`() {
            var path = Array("C:\\Windows\\System32".utf16) + [0]
            var buffer = [UInt16](repeating: 0, count: 5)  // Too small

            #expect(throws: Path.Canonical.Error.self) {
                try path.withUnsafeBufferPointer { pathPtr in
                    try buffer.withUnsafeMutableBufferPointer { bufferPtr in
                        let wpath = UnsafeRawPointer(pathPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                        _ = try Path.Canonical.resolve(unsafePath: wpath, into: bufferPtr)
                    }
                }
            }
        }
    }

#endif
