#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Path

    extension Windows.`32`.Kernel.File.Stats {
        enum Test {
            @Suite struct Integration {}
        }
    }

    extension Windows.`32`.Kernel.File.Stats.Test.Integration {

        @Test
        func `lget classifies a directory symbolic link as a symbolic link`() throws {
            let token = "\(GetCurrentProcessId())-\(GetTickCount64())"
            let directory = Array("swift-windows-32-stats-target-\(token)".utf16) + [0]
            let link = Array("swift-windows-32-stats-link-\(token)".utf16) + [0]

            let made = directory.withUnsafeBufferPointer { CreateDirectoryW($0.baseAddress, nil) }
            guard made else {
                Issue.record("Could not create directory: \(GetLastError())")
                return
            }
            defer { _ = directory.withUnsafeBufferPointer { RemoveDirectoryW($0.baseAddress) } }

            let created = link.withUnsafeBufferPointer { linkPointer in
                directory.withUnsafeBufferPointer { targetPointer in
                    CreateSymbolicLinkW(
                        linkPointer.baseAddress,
                        targetPointer.baseAddress,
                        DWORD(SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE)
                            | DWORD(SYMBOLIC_LINK_FLAG_DIRECTORY)
                    )
                }
            }
            guard created != 0 else {
                Issue.record("Could not create symbolic link: \(GetLastError())")
                return
            }
            defer { _ = link.withUnsafeBufferPointer { RemoveDirectoryW($0.baseAddress) } }

            let unfollowed = try link.withUnsafeBufferPointer { buffer in
                let path = unsafe Path.Borrowed(buffer.baseAddress!, count: buffer.indices.dropLast().count)
                return try Windows.`32`.Kernel.File.Stats.lget(path: path)
            }
            let followed = try link.withUnsafeBufferPointer { buffer in
                let path = unsafe Path.Borrowed(buffer.baseAddress!, count: buffer.indices.dropLast().count)
                return try Windows.`32`.Kernel.File.Stats.get(path: path)
            }

            #expect(unfollowed.type == Windows.`32`.Kernel.File.Stats.Kind.link(.symbolic))
            #expect(followed.type == Windows.`32`.Kernel.File.Stats.Kind.directory)
        }
    }

#endif
