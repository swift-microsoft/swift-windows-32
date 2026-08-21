#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error_Primitives

    extension Kernel.IO.Completion.Port.Entry {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Kernel.IO.Completion.Port.Entry.Test.Unit {
        @Test
        func `Entry type exists`() {
            _ = Kernel.IO.Completion.Port.Entry.self
        }

        @Test
        func `Entry can be zero-initialized`() {
            let entry = Kernel.IO.Completion.Port.Entry()
            _ = entry
        }

        @Test
        func `Entry.Bytes type exists`() {
            _ = Kernel.IO.Completion.Port.Entry.Bytes.self
        }

        @Test
        func `Entry has bytes accessor`() {
            let entry = Kernel.IO.Completion.Port.Entry()
            _ = entry.bytes
        }

        @Test
        func `Entry has key accessor`() {
            let entry = Kernel.IO.Completion.Port.Entry()
            _ = entry.key
        }
    }

#endif
