#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel

    extension Windows.`32`.Kernel.File.Times {
        enum Test {
            @Suite struct Unit {}
        }
    }

    extension Windows.`32`.Kernel.File.Times.Test.Unit {
        @Test
        func `set modification writes the given time and keeps the others`() throws {
            let tempPath = "test_times_set_\(GetCurrentProcessId()).tmp"
            defer { _ = tempPath.withCString(encodedAs: UTF16.self) { DeleteFileW($0) } }

            let handle = tempPath.withCString(encodedAs: UTF16.self) { pathPointer in
                CreateFileW(
                    pathPointer,
                    DWORD(GENERIC_READ) | DWORD(GENERIC_WRITE),
                    0,
                    nil,
                    DWORD(CREATE_ALWAYS),
                    DWORD(FILE_ATTRIBUTE_NORMAL),
                    nil
                )
            }
            guard let handle, handle != INVALID_HANDLE_VALUE else {
                Issue.record("CreateFileW failed")
                return
            }

            let descriptor = Kernel.Descriptor(_raw: UInt(bitPattern: handle))
            let before = try #require(Kernel.File.Times.getTimes(descriptor))

            let modification = FILETIME(dwLowDateTime: 0x1234_5600, dwHighDateTime: 0x01D0_0000)
            try Kernel.File.Times.set(modification: modification, on: descriptor)

            let after = try #require(Kernel.File.Times.getTimes(descriptor))
            #expect(after.write.dwLowDateTime == modification.dwLowDateTime)
            #expect(after.write.dwHighDateTime == modification.dwHighDateTime)
            #expect(after.creation.dwLowDateTime == before.creation.dwLowDateTime)
            #expect(after.creation.dwHighDateTime == before.creation.dwHighDateTime)
        }
    }

#endif
