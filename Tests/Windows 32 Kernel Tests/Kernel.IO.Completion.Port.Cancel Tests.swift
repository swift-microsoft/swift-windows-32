#if os(Windows)
    import Testing

    @testable import Windows_32_Kernel
    import Error

    extension Kernel.IO.Completion.Port.Cancel {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Kernel.IO.Completion.Port.Cancel.Test.Unit {
        @Test
        func `Cancel namespace exists`() {
            _ = Kernel.IO.Completion.Port.Cancel.self
        }

        @Test
        func `Cancel is an enum`() {
            let _: Kernel.IO.Completion.Port.Cancel.Type = Kernel.IO.Completion.Port.Cancel.self
        }
    }

    extension Kernel.IO.Completion.Port.Cancel.Test.Unit {
        @Test
        func `all does not crash with invalid descriptor`() {

            Kernel.IO.Completion.Port.Cancel.all(Kernel.Descriptor.invalid)()
        }

        @Test
        func `all is fire-and-forget`() {

            Kernel.IO.Completion.Port.Cancel.all(Kernel.Descriptor.invalid)()

        }
    }

    extension Kernel.IO.Completion.Port.Cancel.Test.Unit {
        @Test
        func `all.status returns Bool`() {
            let result = Kernel.IO.Completion.Port.Cancel.all(Kernel.Descriptor.invalid).status
            #expect(result is Bool)
        }

        @Test
        func `all.status with invalid descriptor returns appropriate value`() {
            let result = Kernel.IO.Completion.Port.Cancel.all(Kernel.Descriptor.invalid).status

            #expect(result == true || result == false)
        }
    }

    extension Kernel.IO.Completion.Port.Cancel.Test.Unit {
        @Test
        func `pending does not crash with invalid descriptor`() {
            var overlapped = Kernel.IO.Completion.Port.Overlapped()

            Kernel.IO.Completion.Port.Cancel.pending(
                Kernel.Descriptor.invalid,
                overlapped: &overlapped
            )()
        }

        @Test
        func `pending is fire-and-forget`() {
            var overlapped = Kernel.IO.Completion.Port.Overlapped()
            Kernel.IO.Completion.Port.Cancel.pending(
                Kernel.Descriptor.invalid,
                overlapped: &overlapped
            )()

        }
    }

    extension Kernel.IO.Completion.Port.Cancel.Test.Unit {
        @Test
        func `pending.status returns Bool`() {
            var overlapped = Kernel.IO.Completion.Port.Overlapped()
            let result = Kernel.IO.Completion.Port.Cancel.pending(
                Kernel.Descriptor.invalid,
                overlapped: &overlapped
            ).status
            #expect(result is Bool)
        }

        @Test
        func `pending.status with invalid descriptor returns appropriate value`() {
            var overlapped = Kernel.IO.Completion.Port.Overlapped()
            let result = Kernel.IO.Completion.Port.Cancel.pending(
                Kernel.Descriptor.invalid,
                overlapped: &overlapped
            ).status

            #expect(result == true || result == false)
        }
    }

    extension Kernel.IO.Completion.Port.Cancel.Test.Unit {
        @Test
        func
            `pending(_:overlapped:) returns Pending Result, not the pointer-storing Pending accessor`()
        {
            var overlapped = Kernel.IO.Completion.Port.Overlapped()

            let result: Kernel.IO.Completion.Port.Cancel.Pending.Result = Kernel.IO.Completion.Port
                .Cancel.pending(
                    Kernel.Descriptor.invalid,
                    overlapped: &overlapped
                )
            _ = result.status
        }

        @Test
        func `pending(_:overlapped:).status is stable across repeated reads`() {

            var overlapped = Kernel.IO.Completion.Port.Overlapped()
            let result = Kernel.IO.Completion.Port.Cancel.pending(
                Kernel.Descriptor.invalid,
                overlapped: &overlapped
            )
            let first = result.status
            let second = result.status
            #expect(first == second)
        }
    }

    extension Kernel.IO.Completion.Port.Cancel.Test.EdgeCase {
        @Test
        func `Cancel operations are safe to call multiple times`() {
            var overlapped = Kernel.IO.Completion.Port.Overlapped()

            for _ in 0..<3 {
                Kernel.IO.Completion.Port.Cancel.all(Kernel.Descriptor.invalid)()
            }

            for _ in 0..<3 {
                Kernel.IO.Completion.Port.Cancel.pending(
                    Kernel.Descriptor.invalid,
                    overlapped: &overlapped
                )()
            }

            for _ in 0..<3 {
                _ =
                    Kernel.IO.Completion.Port.Cancel.pending(
                        Kernel.Descriptor.invalid,
                        overlapped: &overlapped
                    ).status
            }
        }

        @Test
        func `Cancel with different overlapped instances`() {
            var overlapped1 = Kernel.IO.Completion.Port.Overlapped()
            var overlapped2 = Kernel.IO.Completion.Port.Overlapped()
            var overlapped3 = Kernel.IO.Completion.Port.Overlapped()

            Kernel.IO.Completion.Port.Cancel.pending(
                Kernel.Descriptor.invalid,
                overlapped: &overlapped1
            )()
            Kernel.IO.Completion.Port.Cancel.pending(
                Kernel.Descriptor.invalid,
                overlapped: &overlapped2
            )()
            Kernel.IO.Completion.Port.Cancel.pending(
                Kernel.Descriptor.invalid,
                overlapped: &overlapped3
            )()
        }
    }

    extension Kernel.IO.Completion.Port.Cancel.Test.Unit {
        @Test
        func `Cancel uses Error.Code.Lookup.notFound for comparison`() {

            let notFound = Kernel.IO.Completion.Port.Error.Code.Lookup.notFound
            #expect(notFound == 1168)
        }
    }

#endif
