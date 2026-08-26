#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error
    import Path

    extension Windows.`32`.Kernel.File.Delete {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Windows.`32`.Kernel.File.Delete.Test.Unit {
        @Test
        func `Unlink namespace exists`() {
            _ = Windows.`32`.Kernel.File.Delete.self
        }
    }

    extension Windows.`32`.Kernel.File.Delete.Test.Unit {
        @Test
        func `Error.notFound maps from FILE_NOT_FOUND`() {
            let error = Kernel.File.Delete.Error.current(
                from: Error.Error.Code.File.notFound
            )
            if case .notFound = error {

            } else {
                Issue.record("Expected .notFound, got \(error)")
            }
        }

        @Test
        func `Error.notFound maps from PATH_NOT_FOUND`() {
            let error = Kernel.File.Delete.Error.current(
                from: Error.Error.Code.File.pathNotFound
            )
            if case .notFound = error {

            } else {
                Issue.record("Expected .notFound, got \(error)")
            }
        }

        @Test
        func `Error.permission maps from ACCESS_DENIED`() {
            let error = Kernel.File.Delete.Error.current(
                from: Error.Error.Code.Access.denied
            )
            if case .permission = error {

            } else {
                Issue.record("Expected .permission, got \(error)")
            }
        }

        @Test
        func `Error.busy maps from SHARING_VIOLATION`() {
            let error = Kernel.File.Delete.Error.current(
                from: Error.Error.Code.Access.sharingViolation
            )
            if case .busy = error {

            } else {
                Issue.record("Expected .busy, got \(error)")
            }
        }
    }

    extension Windows.`32`.Kernel.File.Delete.Test.EdgeCase {
        @Test
        func `unlink nonexistent file throws notFound`() {
            let filePath = "C:\\nonexistent_file_\(GetCurrentProcessId()).tmp"
            var path = Array(filePath.utf16) + [0]

            #expect(throws: Kernel.File.Delete.Error.self) {
                try path.withUnsafeBufferPointer { pathPtr in
                    let wpath = UnsafeRawPointer(pathPtr.baseAddress!).assumingMemoryBound(
                        to: UInt16.self
                    )
                    try Windows.`32`.Kernel.File.Delete.delete(unsafePath: wpath)
                }
            }
        }
    }

#endif
