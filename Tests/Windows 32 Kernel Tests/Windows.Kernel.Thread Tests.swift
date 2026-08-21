#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error_Primitives
    import Path_Primitives
    import Clock_Primitives
    import Random_Primitives
    import System_Primitives

    extension Windows.`32`.Kernel.Thread {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Windows.`32`.Kernel.Thread.Test.Unit {
        @Test
        func `Thread namespace exists`() {
            _ = Windows.`32`.Kernel.Thread.self
        }

        @Test
        func `Thread.Handle type exists`() {
            _ = Kernel.Thread.Handle.self
        }
    }

    extension Windows.`32`.Kernel.Thread.Test.Unit {
        @Test
        func `current returns valid handle`() {
            let handle = Windows.`32`.Kernel.Thread.current()
            #expect(handle.rawValue != 0)
        }

        @Test
        func `currentID returns non-zero`() {
            let id = Windows.`32`.Kernel.Thread.currentID()
            #expect(id > 0)
        }

        @Test
        func `currentID matches GetCurrentThreadId`() {
            let id = Windows.`32`.Kernel.Thread.currentID()
            let win32Id = GetCurrentThreadId()
            #expect(id == win32Id)
        }
    }

    extension Windows.`32`.Kernel.Thread.Test.Unit {
        @Test
        func `yield completes without error`() {

            Windows.`32`.Kernel.Thread.yield()
        }

        @Test
        func `yield can be called multiple times`() {
            for _ in 0..<10 {
                Windows.`32`.Kernel.Thread.yield()
            }
        }
    }

    extension Windows.`32`.Kernel.Thread.Test.Unit {
        @Test
        func `create and join thread`() throws {
            final class Flag: @unchecked Sendable { var value = false }
            let flag = Flag()

            let handle = try Windows.`32`.Kernel.Thread.create {
                flag.value = true
            }

            let joined = Windows.`32`.Kernel.Thread.join(handle)
            Windows.`32`.Kernel.Thread.close(handle)

            #expect(joined)

        }

        @Test
        func `create multiple threads`() throws {
            var handles: [Kernel.Thread.Handle] = []

            for _ in 0..<5 {
                let handle = try Windows.`32`.Kernel.Thread.create {

                }
                handles.append(handle)
            }

            for handle in handles {
                _ = Windows.`32`.Kernel.Thread.join(handle)
                Windows.`32`.Kernel.Thread.close(handle)
            }
        }
    }

    extension Windows.`32`.Kernel.Thread.Test.EdgeCase {
        @Test
        func `currentID is consistent within same thread`() {
            let id1 = Windows.`32`.Kernel.Thread.currentID()
            let id2 = Windows.`32`.Kernel.Thread.currentID()
            #expect(id1 == id2)
        }

        @Test
        func `join with timeout returns false on timeout`() throws {

            let handle = try Windows.`32`.Kernel.Thread.create {
                Sleep(5000)
            }

            let joined = Windows.`32`.Kernel.Thread.join(handle, timeout: 1)
            #expect(!joined)

            _ = Windows.`32`.Kernel.Thread.join(handle)
            Windows.`32`.Kernel.Thread.close(handle)
        }
    }

#endif
