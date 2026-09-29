#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error
    import Path
    import Clock
    import Random
    import System

    extension Windows.`32`.Kernel.Directory.Remove {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Windows.`32`.Kernel.Directory.Remove.Test.Unit {
        @Test
        func `Rmdir namespace exists`() {
            _ = Windows.`32`.Kernel.Directory.Remove.self
        }
    }

    extension Windows.`32`.Kernel.Directory.Remove.Test.Unit {
        @Test
        func `Error.notFound maps from FILE_NOT_FOUND`() {
            let error = Kernel.Directory.Remove.Error.current(
                from: Error::Error.Code.File.notFound
            )
            if case .notFound = error {

            } else {
                Issue.record("Expected .notFound, got \(error)")
            }
        }

        @Test
        func `Error.notFound maps from PATH_NOT_FOUND`() {
            let error = Kernel.Directory.Remove.Error.current(
                from: Error::Error.Code.File.pathNotFound
            )
            if case .notFound = error {

            } else {
                Issue.record("Expected .notFound, got \(error)")
            }
        }

        @Test
        func `Error.permission maps from ACCESS_DENIED`() {
            let error = Kernel.Directory.Remove.Error.current(
                from: Error::Error.Code.Access.denied
            )
            if case .permission = error {

            } else {
                Issue.record("Expected .permission, got \(error)")
            }
        }

        @Test
        func `Error.notEmpty maps from DIR_NOT_EMPTY`() {
            let error = Kernel.Directory.Remove.Error.current(
                from: Error::Error.Code.Directory.notEmpty
            )
            if case .notEmpty = error {

            } else {
                Issue.record("Expected .notEmpty, got \(error)")
            }
        }

        @Test
        func `Error.busy maps from SHARING_VIOLATION`() {
            let error = Kernel.Directory.Remove.Error.current(
                from: Error::Error.Code.Access.sharingViolation
            )
            if case .busy = error {

            } else {
                Issue.record("Expected .busy, got \(error)")
            }
        }
    }

    extension Windows.`32`.Kernel.Directory.Remove.Test.EdgeCase {
        @Test
        func `rmdir on nonexistent path throws notFound`() {
            let fakePath = "C:\\nonexistent_dir_12345_\(GetCurrentProcessId())"
            var utf16Path = Array(fakePath.utf16) + [0]

            #expect(throws: Kernel.Directory.Remove.Error.self) {
                try utf16Path.withUnsafeBufferPointer { pathPtr in
                    let ptr = UnsafeRawPointer(pathPtr.baseAddress!).assumingMemoryBound(
                        to: UInt16.self
                    )
                    try Windows.`32`.Kernel.Directory.Remove.remove(unsafePath: ptr)
                }
            }
        }
    }

#endif
