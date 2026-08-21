#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error_Primitives
    import Path_Primitives
    import Clock_Primitives
    import Random_Primitives
    import System_Primitives

    extension Windows.`32`.Kernel.Descriptor.Duplicate {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Windows.`32`.Kernel.Descriptor.Duplicate.Test.Unit {
        @Test
        func `Dup namespace exists`() {
            _ = Windows.`32`.Kernel.Descriptor.Duplicate.self
        }
    }

    extension Windows.`32`.Kernel.Descriptor.Duplicate.Test.Unit {
        @Test
        func `dup with invalid descriptor throws handle error`() {
            let invalid = Kernel.Descriptor.invalid

            #expect(throws: Kernel.Descriptor.Duplicate.Error.self) {
                _ = try Windows.`32`.Kernel.Descriptor.Duplicate.duplicate(invalid)
            }
        }

        @Test
        func `dup with invalid descriptor throws handle(.invalid)`() {
            let invalid = Kernel.Descriptor.invalid

            do {
                _ = try Windows.`32`.Kernel.Descriptor.Duplicate.duplicate(invalid)
                Issue.record("Expected error")
            } catch let error as Kernel.Descriptor.Duplicate.Error {
                if case .handle(.invalid) = error {

                } else {
                    Issue.record("Expected .handle(.invalid), got \(error)")
                }
            } catch {
                Issue.record("Unexpected error type: \(error)")
            }
        }
    }

#endif
