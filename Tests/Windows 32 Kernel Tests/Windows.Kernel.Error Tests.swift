#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error
    import Path
    import Clock
    import Random
    import System

    extension Error.Error {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Error.Error.Test.Unit {
        @Test
        func `Error.Error namespace exists`() {
            _ = Error.Error.self
        }

        @Test
        func `Error.Error.Code type exists`() {
            _ = Error.Error.Code.self
        }
    }

    extension Error.Error.Test.Unit {
        @Test
        func `captureLastError returns Code`() {

            SetLastError(DWORD(ERROR_FILE_NOT_FOUND))

            let code = Error.Error.captureLastError()
            #expect(code.win32 == Error.Error.Code.File.notFound)
        }

        @Test
        func `captureLastError with no error returns success`() {
            SetLastError(0)

            let code = Error.Error.captureLastError()
            #expect(code.win32 == 0)
        }
    }

    extension Error.Error.Test.Unit {
        @Test
        func `Code.File.notFound exists`() {
            let code = Error.Error.Code.File.notFound
            #expect(code == DWORD(ERROR_FILE_NOT_FOUND))
        }

        @Test
        func `Code.File.pathNotFound exists`() {
            let code = Error.Error.Code.File.pathNotFound
            #expect(code == DWORD(ERROR_PATH_NOT_FOUND))
        }

        @Test
        func `Code.Access.denied exists`() {
            let code = Error.Error.Code.Access.denied
            #expect(code == DWORD(ERROR_ACCESS_DENIED))
        }

        @Test
        func `Code.Handle.invalid exists`() {
            let code = Error.Error.Code.Handle.invalid
            #expect(code == DWORD(ERROR_INVALID_HANDLE))
        }
    }

    extension Error.Error.Test.Unit {
        @Test
        func `Code.win32 creates correct code`() {
            let code = Error.Error.Code.win32(DWORD(ERROR_FILE_NOT_FOUND))
            #expect(code.win32 == DWORD(ERROR_FILE_NOT_FOUND))
        }
    }

    extension Error.Error.Test.EdgeCase {
        @Test
        func `captureLastError is non-destructive`() {
            SetLastError(DWORD(ERROR_ACCESS_DENIED))

            let code1 = Error.Error.captureLastError()
            let code2 = GetLastError()

            #expect(code1.win32 == code2)
        }
    }

#endif
