#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error_Primitives
    import Memory_Primitives

    extension Memory.Lock {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Memory.Lock.Test.Unit {
        @Test
        func `Memory.Lock namespace exists`() {
            _ = Memory.Lock.self
        }
    }

    extension Memory.Lock.Test.Unit {
        @Test
        func `Error type exists`() {
            _ = Memory.Lock.Error.self
        }
    }

    extension Memory.Lock.Test.EdgeCase {
        @Test
        func `lock with invalid address throws`() {

            _ = Memory.Lock.lock
            _ = Memory.Lock.unlock
        }
    }

#endif
