#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error

    extension Windows.`32`.Kernel.Socket.Error {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
        }
    }

    extension Windows.`32`.Kernel.Socket.Error.Test.Unit {
        @Test
        func `Error type exists`() {
            let _: Windows.`32`.Kernel.Socket.Error.Type = Windows.`32`.Kernel.Socket.Error.self
        }

        @Test
        func `platform case exists`() {
            let platformError = Error.Error(code: .win32(999))
            let error = Windows.`32`.Kernel.Socket.Error.platform(platformError)
            if case .platform(let e) = error {
                #expect(e == platformError)
            } else {
                Issue.record("Expected .platform case")
            }
        }
    }

    extension Windows.`32`.Kernel.Socket.Error.Test.Unit {
        @Test
        func `Error conforms to Swift.Error`() {
            let error: any Swift.Error = Windows.`32`.Kernel.Socket.Error.platform(
                Error.Error(code: .win32(1))
            )
            #expect(error is Windows.`32`.Kernel.Socket.Error)
        }

        @Test
        func `Error is Sendable`() {
            let value: any Sendable = Windows.`32`.Kernel.Socket.Error.platform(
                Error.Error(code: .win32(1))
            )
            #expect(value is Windows.`32`.Kernel.Socket.Error)
        }

        @Test
        func `Error is Equatable`() {
            let a = Windows.`32`.Kernel.Socket.Error.platform(
                Error.Error(code: .win32(1))
            )
            let b = Windows.`32`.Kernel.Socket.Error.platform(
                Error.Error(code: .win32(1))
            )
            let c = Windows.`32`.Kernel.Socket.Error.platform(
                Error.Error(code: .win32(2))
            )
            #expect(a == b)
            #expect(a != c)
        }
    }

    extension Windows.`32`.Kernel.Socket.Error.Test.Unit {
        @Test
        func `platform error description is non-empty`() {
            let error = Windows.`32`.Kernel.Socket.Error.platform(
                Error.Error(code: .win32(42))
            )
            #expect(!error.description.isEmpty)
        }
    }

    extension Windows.`32`.Kernel.Socket.Error.Test.EdgeCase {
        @Test
        func `Same code platform errors are equal`() {
            let code = Error::Error.Code.win32(42)
            #expect(
                Windows.`32`.Kernel.Socket.Error.platform(Error.Error(code: code))
                    == Windows.`32`.Kernel.Socket.Error.platform(Error.Error(code: code))
            )
        }

        @Test
        func `Different code platform errors are not equal`() {
            #expect(
                Windows.`32`.Kernel.Socket.Error.platform(Error.Error(code: .win32(1)))
                    != Windows.`32`.Kernel.Socket.Error.platform(
                        Error.Error(code: .win32(2))
                    )
            )
        }
    }

#endif
