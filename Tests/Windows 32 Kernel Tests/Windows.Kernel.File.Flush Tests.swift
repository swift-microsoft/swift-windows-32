#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error_Primitives
    import Path_Primitives

    extension Windows.`32`.Kernel.File.Flush {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Windows.`32`.Kernel.File.Flush.Test.Unit {
        @Test
        func `Sync namespace exists`() {
            _ = Windows.`32`.Kernel.File.Flush.self
        }
    }

    extension Windows.`32`.Kernel.File.Flush.Test.Unit {
        @Test
        func `sync with invalid descriptor throws`() {
            let invalid = Kernel.Descriptor.invalid

            #expect(throws: Kernel.File.Flush.Error.self) {
                try Windows.`32`.Kernel.File.Flush.flush(invalid)
            }
        }

        @Test
        func `datasync with invalid descriptor throws`() {
            let invalid = Kernel.Descriptor.invalid

            #expect(throws: Kernel.File.Flush.Error.self) {
                try Windows.`32`.Kernel.File.Flush.flushData(invalid)
            }
        }
    }

    extension Windows.`32`.Kernel.File.Flush.Test.EdgeCase {
        @Test
        func `flushData is alias for flush on Windows`() {

            let invalid = Kernel.Descriptor.invalid
            #expect(throws: Kernel.File.Flush.Error.self) {
                try Windows.`32`.Kernel.File.Flush.flush(invalid)
            }
            let invalid2 = Kernel.Descriptor.invalid
            #expect(throws: Kernel.File.Flush.Error.self) {
                try Windows.`32`.Kernel.File.Flush.flushData(invalid2)
            }
        }
    }

#endif
