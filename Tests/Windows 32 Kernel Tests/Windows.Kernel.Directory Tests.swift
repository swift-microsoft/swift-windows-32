#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error
    import Path
    import Clock
    import Random
    import System

    extension Windows.`32`.Kernel.Directory {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Windows.`32`.Kernel.Directory.Test.Unit {
        @Test
        func `Directory namespace exists`() {
            _ = Windows.`32`.Kernel.Directory.self
        }

        @Test
        func `Directory.Iterator type exists`() {
            _ = Windows.`32`.Kernel.Directory.Iterator.self
        }
    }

    extension Windows.`32`.Kernel.Directory.Test.Unit {
        @Test
        func `Iterator type exists`() {

            _ = Windows.`32`.Kernel.Directory.Iterator.self
        }
    }

    extension Windows.`32`.Kernel.Directory.Test.Unit {
        @Test
        func `Error.notFound maps from FILE_NOT_FOUND`() {
            let error = Kernel.Directory.Error(
                _windowsError: Error.Error.Code.File.notFound
            )
            if case .notFound = error {

            } else {
                Issue.record("Expected .notFound, got \(error)")
            }
        }

        @Test
        func `Error.notFound maps from PATH_NOT_FOUND`() {
            let error = Kernel.Directory.Error(
                _windowsError: Error.Error.Code.File.pathNotFound
            )
            if case .notFound = error {

            } else {
                Issue.record("Expected .notFound, got \(error)")
            }
        }

        @Test
        func `Error.permission maps from ACCESS_DENIED`() {
            let error = Kernel.Directory.Error(
                _windowsError: Error.Error.Code.Access.denied
            )
            if case .permission = error {

            } else {
                Issue.record("Expected .permission, got \(error)")
            }
        }
    }

    extension Windows.`32`.Kernel.Directory.Test.EdgeCase {
        @Test
        func `Entry.withName borrows UTF-16 name without its terminator`() throws {
            let entry = Kernel.Directory.Entry(
                rawName: [0x006E, 0x0061, 0x006D, 0x0065, 0x0000],
                inode: nil,
                type: .regular
            )

            let count = try entry.withName { name in
                #expect(name.count == 4)
                return try unsafe name.withUnsafePointer { pointer in
                    #expect(pointer[0] == 0x006E)
                    #expect(pointer[3] == 0x0065)
                    return name.count
                }
            }

            #expect(count == 4)
        }

        @Test
        func `Stream.next after close throws closed`() throws {
            var currentDirectory = try Kernel.Directory.Working.get()
            currentDirectory.append(0)

            try currentDirectory.withUnsafeBufferPointer { buffer in
                let path = unsafe Path.Borrowed(buffer.baseAddress!, count: buffer.count - 1)
                let stream = try Kernel.Directory.open(at: path)
                stream.close()

                do {
                    _ = try stream.next()
                    Issue.record("Expected .closed")
                } catch {
                    if case Windows.`32`.Kernel.Directory.Error.closed = error {

                    } else {
                        Issue.record("Expected .closed, got \(error)")
                    }
                }
            }
        }

        @Test
        func `Entry type has name, inode, type`() {

            let nameChars: [UInt16] = [0x74, 0x65, 0x73, 0x74, 0x0000]
            let entry = Kernel.Directory.Entry(rawName: nameChars, inode: nil, type: .regular)
            #expect(entry.type == .regular)
        }

        @Test
        func `Entry.isDotOrDotDot detects dot entries`() {

            let dotName: [UInt16] = [0x2E, 0x0000]
            let dotEntry = Kernel.Directory.Entry(rawName: dotName, inode: nil, type: .directory)
            #expect(dotEntry.isDotOrDotDot)

            let dotDotName: [UInt16] = [0x2E, 0x2E, 0x0000]
            let dotDotEntry = Kernel.Directory.Entry(
                rawName: dotDotName,
                inode: nil,
                type: .directory
            )
            #expect(dotDotEntry.isDotOrDotDot)

            let normalName: [UInt16] = [0x74, 0x65, 0x73, 0x74, 0x0000]
            let normalEntry = Kernel.Directory.Entry(
                rawName: normalName,
                inode: nil,
                type: .regular
            )
            #expect(!normalEntry.isDotOrDotDot)
        }
    }

#endif
