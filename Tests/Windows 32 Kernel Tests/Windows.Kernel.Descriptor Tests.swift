#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error

    extension Windows.`32`.Kernel.Descriptor {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Windows.`32`.Kernel.Descriptor.Test.Unit {
        @Test
        func `owning(handle:) exists and constructs a descriptor from a raw HANDLE`() {

            let descriptor = Windows.`32`.Kernel.Descriptor.owning(handle: INVALID_HANDLE_VALUE)
            let isValid = descriptor.isValid
            #expect(!isValid)
        }

        @Test
        func `owning(handle:) round-trips the same raw HANDLE bit pattern`() {
            let invalid = Kernel.Descriptor.invalid
            let originalHandle = invalid.handle

            let descriptor = Windows.`32`.Kernel.Descriptor.owning(handle: originalHandle)
            let actualHandle = descriptor.handle
            let actualRawValue = descriptor._rawValue
            let expectedRawValue = invalid._rawValue
            #expect(actualHandle == originalHandle)
            #expect(actualRawValue == expectedRawValue)
        }
    }

#endif
