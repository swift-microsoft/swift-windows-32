#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error
    import Path
    import Clock
    import Random
    import CPU
    import Memory

    extension Windows.`32`.Kernel.Link.Symbolic {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Windows.`32`.Kernel.Link.Symbolic.Test.Unit {
        @Test
        func `Symlink namespace exists`() {
            _ = Windows.`32`.Kernel.Link.Symbolic.self
        }
    }

    extension Windows.`32`.Kernel.Link.Symbolic.Test.Unit {
        @Test
        func `Error.notFound maps from FILE_NOT_FOUND`() {
            let error = Kernel.Link.Symbolic.Error.current(
                from: Error::Error.Code.File.notFound
            )
            if case .notFound = error {

            } else {
                Issue.record("Expected .notFound, got \(error)")
            }
        }

        @Test
        func `Error.permission maps from ACCESS_DENIED`() {
            let error = Kernel.Link.Symbolic.Error.current(
                from: Error::Error.Code.Access.denied
            )
            if case .permission = error {

            } else {
                Issue.record("Expected .permission, got \(error)")
            }
        }

        @Test
        func `Error.exists maps from FILE_EXISTS`() {
            let error = Kernel.Link.Symbolic.Error.current(
                from: Error::Error.Code.File.exists
            )
            if case .exists = error {

            } else {
                Issue.record("Expected .exists, got \(error)")
            }
        }

        @Test
        func `Error.noSpace maps from DISK_FULL`() {
            let error = Kernel.Link.Symbolic.Error.current(
                from: Error::Error.Code.Storage.diskFull
            )
            if case .noSpace = error {

            } else {
                Issue.record("Expected .noSpace, got \(error)")
            }
        }

        @Test
        func `Error.bufferTooSmall exists`() {
            let error = Kernel.Link.Symbolic.Error.bufferTooSmall
            if case .bufferTooSmall = error {

            } else {
                Issue.record("Expected .bufferTooSmall, got \(error)")
            }
        }
    }

    extension Windows.`32`.Kernel.Link.Symbolic.Test.EdgeCase {
        @Test
        func `symlink creation succeeds or throws a Symbolic error`() throws {

            let targetPath = "C:\\target_\(GetCurrentProcessId())"
            let linkPath = "C:\\symlink_\(GetCurrentProcessId())"

            var target = Array(targetPath.utf16) + [0]
            var link = Array(linkPath.utf16) + [0]

            do {
                try target.withUnsafeBufferPointer { targetPtr in
                    try link.withUnsafeBufferPointer { linkPtr in
                        let wtarget = UnsafeRawPointer(targetPtr.baseAddress!).assumingMemoryBound(
                            to: UInt16.self
                        )
                        let wlink = UnsafeRawPointer(linkPtr.baseAddress!).assumingMemoryBound(
                            to: UInt16.self
                        )
                        try Windows.`32`.Kernel.Link.Symbolic.create(
                            target: wtarget,
                            linkPath: wlink
                        )
                    }
                }

                link.withUnsafeBufferPointer { linkPtr in
                    let wlink = UnsafeRawPointer(linkPtr.baseAddress!).assumingMemoryBound(
                        to: Path.Char.self
                    )
                    try? Windows.`32`.Kernel.File.Delete.delete(unsafePath: wlink)
                }
            } catch is Kernel.Link.Symbolic.Error {

            }
        }
    }

    extension Windows.`32`.Kernel.Link.Symbolic.Test.Integration {

        @Test
        func `readTarget returns the link's own target, not the end of the chain`() throws {
            let token = "\(GetCurrentProcessId())-\(GetTickCount64())"
            let targetName = "swift-windows-32-readtarget-target-\(token).tmp"
            let middleName = "swift-windows-32-readtarget-middle-\(token).tmp"
            let outerName = "swift-windows-32-readtarget-outer-\(token).tmp"
            let target = Array(targetName.utf16) + [0]
            let middle = Array(middleName.utf16) + [0]
            let outer = Array(outerName.utf16) + [0]

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
            defer { _ = target.withUnsafeBufferPointer { DeleteFileW($0.baseAddress) } }

            try middle.withUnsafeBufferPointer { linkPointer in
                try target.withUnsafeBufferPointer { targetPointer in
                    try Windows.`32`.Kernel.Link.Symbolic.create(
                        target: targetPointer.baseAddress!,
                        linkPath: linkPointer.baseAddress!
                    )
                }
            }
            defer { _ = middle.withUnsafeBufferPointer { DeleteFileW($0.baseAddress) } }

            try outer.withUnsafeBufferPointer { linkPointer in
                try middle.withUnsafeBufferPointer { targetPointer in
                    try Windows.`32`.Kernel.Link.Symbolic.create(
                        target: targetPointer.baseAddress!,
                        linkPath: linkPointer.baseAddress!
                    )
                }
            }
            defer { _ = outer.withUnsafeBufferPointer { DeleteFileW($0.baseAddress) } }

            var buffer = [UInt16](repeating: 0, count: 1024)
            let count = try outer.withUnsafeBufferPointer { linkPointer in
                try buffer.withUnsafeMutableBufferPointer { bufferPointer in
                    try Windows.`32`.Kernel.Link.Symbolic.readTarget(
                        unsafePath: linkPointer.baseAddress!,
                        into: bufferPointer
                    )
                }
            }

            #expect(Swift.String(decoding: buffer[..<count], as: UTF16.self) == middleName)
        }

        @Test
        func `readTarget of a regular file throws notSymbolicLink`() throws {
            let token = "\(GetCurrentProcessId())-\(GetTickCount64())"
            let name = Array("swift-windows-32-readtarget-regular-\(token).tmp".utf16) + [0]

            let handle = name.withUnsafeBufferPointer { namePointer in
                CreateFileW(
                    namePointer.baseAddress,
                    DWORD(GENERIC_READ) | DWORD(GENERIC_WRITE),
                    DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
                    nil,
                    DWORD(CREATE_NEW),
                    DWORD(FILE_ATTRIBUTE_NORMAL),
                    nil
                )
            }
            guard let handle, handle != INVALID_HANDLE_VALUE else {
                Issue.record("Could not create file: \(GetLastError())")
                return
            }
            _ = CloseHandle(handle)
            defer { _ = name.withUnsafeBufferPointer { DeleteFileW($0.baseAddress) } }

            var buffer = [UInt16](repeating: 0, count: 1024)
            #expect(throws: Windows.`32`.Kernel.Link.Symbolic.Error.notSymbolicLink) {
                try name.withUnsafeBufferPointer { namePointer in
                    try buffer.withUnsafeMutableBufferPointer { bufferPointer in
                        try Windows.`32`.Kernel.Link.Symbolic.readTarget(
                            unsafePath: namePointer.baseAddress!,
                            into: bufferPointer
                        )
                    }
                }
            }
        }

        @Test
        func `create detects a directory target and makes a directory link`() throws {
            let token = "\(GetCurrentProcessId())-\(GetTickCount64())"
            let directory = Array("swift-windows-32-dirlink-target-\(token)".utf16) + [0]
            let link = Array("swift-windows-32-dirlink-link-\(token)".utf16) + [0]

            let made = directory.withUnsafeBufferPointer { CreateDirectoryW($0.baseAddress, nil) }
            guard made else {
                Issue.record("Could not create directory: \(GetLastError())")
                return
            }
            defer { _ = directory.withUnsafeBufferPointer { RemoveDirectoryW($0.baseAddress) } }

            try directory.withUnsafeBufferPointer { targetPointer in
                try link.withUnsafeBufferPointer { linkPointer in
                    let target = unsafe Path.Borrowed(
                        targetPointer.baseAddress!,
                        count: targetPointer.indices.dropLast().count
                    )
                    let at = unsafe Path.Borrowed(
                        linkPointer.baseAddress!,
                        count: linkPointer.indices.dropLast().count
                    )
                    try Windows.`32`.Kernel.Link.Symbolic.create(target: target, at: at)
                }
            }
            defer { _ = link.withUnsafeBufferPointer { RemoveDirectoryW($0.baseAddress) } }

            let attributes = link.withUnsafeBufferPointer { GetFileAttributesW($0.baseAddress) }
            #expect(attributes != INVALID_FILE_ATTRIBUTES)
            #expect((attributes & DWORD(FILE_ATTRIBUTE_DIRECTORY)) != 0)
            #expect((attributes & DWORD(FILE_ATTRIBUTE_REPARSE_POINT)) != 0)
        }
    }

#endif
