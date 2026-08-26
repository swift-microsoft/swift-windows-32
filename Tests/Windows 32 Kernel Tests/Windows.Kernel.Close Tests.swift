#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error
    import Path
    import Clock
    import Random
    import System

    extension Windows.`32`.Kernel.Close {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Windows.`32`.Kernel.Close.Test.Unit {
        @Test
        func `Close namespace exists`() {
            _ = Windows.`32`.Kernel.Close.self
        }
    }

    extension Windows.`32`.Kernel.Close.Test.Unit {
        @Test
        func `close with invalid descriptor throws handle error`() {
            let invalid = Kernel.Descriptor.invalid

            do {
                try Windows.`32`.Kernel.Close.close(invalid)
                Issue.record("Expected error")
            } catch is Kernel.Close.Error {

            } catch {
                Issue.record("Unexpected error type: \(error)")
            }
        }

        @Test
        func `close with invalid descriptor throws handle(.invalid)`() {
            let invalid = Kernel.Descriptor.invalid

            do {
                try Windows.`32`.Kernel.Close.close(invalid)
                Issue.record("Expected error")
            } catch let error as Kernel.Close.Error {
                if case .handle(.invalid) = error {

                } else {
                    Issue.record("Expected .handle(.invalid), got \(error)")
                }
            } catch {
                Issue.record("Unexpected error type: \(error)")
            }
        }
    }

    extension Windows.`32`.Kernel.Close.Test.EdgeCase {
        @Test
        func `Kernel.Descriptor.invalid is detected`() {
            let invalid = Kernel.Descriptor.invalid
            let invalidIsValid = invalid.isValid
            #expect(!invalidIsValid)
        }
    }

#endif
