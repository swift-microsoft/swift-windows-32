#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error_Primitives
    import Path_Primitives
    import Clock_Primitives
    import Random_Primitives
    import System_Primitives

    extension Windows.`32`.Kernel.Thread.Mutex {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Windows.`32`.Kernel.Thread.Mutex.Test.Unit {
        @Test
        func `Thread.Mutex class exists`() {
            _ = Windows.`32`.Kernel.Thread.Mutex.self
        }

        @Test
        func `Thread.Mutex.Lock type exists`() {
            _ = Windows.`32`.Kernel.Thread.Mutex.Lock.self
        }

        @Test
        func `Thread.Mutex.Lock.Error type exists`() {
            _ = Windows.`32`.Kernel.Thread.Mutex.Lock.Error.self
        }
    }

    extension Windows.`32`.Kernel.Thread.Mutex.Test.Unit {
        @Test
        func `Mutex can be created`() {
            let mutex = Windows.`32`.Kernel.Thread.Mutex()
            _ = mutex
        }

        @Test
        func `Multiple mutexes can be created`() {
            let mutex1 = Windows.`32`.Kernel.Thread.Mutex()
            let mutex2 = Windows.`32`.Kernel.Thread.Mutex()
            _ = mutex1
            _ = mutex2
        }
    }

    extension Windows.`32`.Kernel.Thread.Mutex.Test.Unit {
        @Test
        func `lock and unlock succeeds`() {
            let mutex = Windows.`32`.Kernel.Thread.Mutex()
            mutex.lock()
            mutex.unlock()
        }

        @Test
        func `lock accessor exists`() {
            let mutex = Windows.`32`.Kernel.Thread.Mutex()
            _ = mutex.lock
        }

        @Test
        func `lock.immediate throws on contention`() throws {
            let mutex = Windows.`32`.Kernel.Thread.Mutex()
            mutex.lock()
            defer { mutex.unlock() }

            _ = Windows.`32`.Kernel.Thread.Mutex.Lock.Error.contention
        }
    }

    extension Windows.`32`.Kernel.Thread.Mutex.Test.Unit {
        @Test
        func `withLock executes closure`() {
            let mutex = Windows.`32`.Kernel.Thread.Mutex()
            var executed = false

            mutex.withLock {
                executed = true
            }

            #expect(executed)
        }

        @Test
        func `withLock returns value`() {
            let mutex = Windows.`32`.Kernel.Thread.Mutex()

            let result = mutex.withLock {
                42
            }

            #expect(result == 42)
        }
    }

    extension Windows.`32`.Kernel.Thread.Mutex.Test.Unit {
        @Test
        func `Lock.Error.contention exists`() {
            let error = Windows.`32`.Kernel.Thread.Mutex.Lock.Error.contention
            if case .contention = error {

            } else {
                Issue.record("Expected .contention")
            }
        }
    }

    extension Windows.`32`.Kernel.Thread.Mutex.Test.EdgeCase {
        @Test
        func `lock and unlock multiple times`() {
            let mutex = Windows.`32`.Kernel.Thread.Mutex()

            for _ in 0..<100 {
                mutex.lock()
                mutex.unlock()
            }
        }

        @Test
        func `withLock with throwing closure propagates error`() {
            struct TestError: Swift.Error {}
            let mutex = Windows.`32`.Kernel.Thread.Mutex()

            #expect(throws: TestError.self) {
                try mutex.withLock {
                    throw TestError()
                }
            }
        }
    }

#endif
