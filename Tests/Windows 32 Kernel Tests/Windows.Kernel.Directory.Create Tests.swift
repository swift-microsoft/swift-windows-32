#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error
    import Path
    import Clock
    import Random
    import System

    extension Windows.`32`.Kernel.Directory.Create {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Windows.`32`.Kernel.Directory.Create.Test.Unit {
        @Test
        func `Mkdir namespace exists`() {
            _ = Windows.`32`.Kernel.Directory.Create.self
        }
    }

    extension Windows.`32`.Kernel.Directory.Create.Test.Unit {
        @Test
        func `Error.notFound maps from PATH_NOT_FOUND`() {
            let error = Kernel.Directory.Create.Error.current(
                from: Error.Error.Code.File.pathNotFound
            )
            if case .notFound = error {

            } else {
                Issue.record("Expected .notFound, got \(error)")
            }
        }

        @Test
        func `Error.permission maps from ACCESS_DENIED`() {
            let error = Kernel.Directory.Create.Error.current(
                from: Error.Error.Code.Access.denied
            )
            if case .permission = error {

            } else {
                Issue.record("Expected .permission, got \(error)")
            }
        }

        @Test
        func `Error.exists maps from FILE_EXISTS`() {
            let error = Kernel.Directory.Create.Error.current(
                from: Error.Error.Code.File.exists
            )
            if case .exists = error {

            } else {
                Issue.record("Expected .exists, got \(error)")
            }
        }

        @Test
        func `Error.exists maps from ALREADY_EXISTS`() {
            let error = Kernel.Directory.Create.Error.current(
                from: Error.Error.Code.File.alreadyExists
            )
            if case .exists = error {

            } else {
                Issue.record("Expected .exists, got \(error)")
            }
        }

        @Test
        func `Error.noSpace maps from DISK_FULL`() {
            let error = Kernel.Directory.Create.Error.current(
                from: Error.Error.Code.Storage.diskFull
            )
            if case .noSpace = error {

            } else {
                Issue.record("Expected .noSpace, got \(error)")
            }
        }
    }

    extension Windows.`32`.Kernel.Directory.Create.Test.EdgeCase {
        @Test
        func `Permissions.standardDirectory exists`() {
            let perms = Kernel.File.Permissions.standardDirectory
            #expect((perms & .ownerRead) == .ownerRead)
            #expect((perms & .ownerWrite) == .ownerWrite)
            #expect((perms & .ownerExecute) == .ownerExecute)
        }
    }

#endif
