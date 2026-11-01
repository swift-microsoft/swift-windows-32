#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import CPU
    import Memory

    extension Windows.`32`.Kernel.Name {
        enum Test {
            @Suite struct Unit {}
        }
    }

    extension Windows.`32`.Kernel.Name.Test.Unit {
        @Test
        func `current reports Windows with a release and machine`() throws {
            let name = try #require(Windows.`32`.Kernel.Name.current)
            #expect(name.system == "Windows")
            #expect(!name.release.isEmpty)
            #expect(name.machine != "unknown")
        }
    }

    @Suite
    struct `Windows system queries` {
        @Test
        func `capacity reports the installed physical memory`() {
            #expect(Int(Memory.Physical.capacity) > 0)
        }

        @Test
        func `page size is a power of two between 4 KiB and 64 KiB`() {
            let size = Int(Memory.Page.size)
            #expect(size >= 4096)
            #expect(size <= 65536)
            #expect(size & (size - 1) == 0)
        }

        @Test
        func `logical count is between one and the processor group limit`() {
            let count = Int(CPU.Logical.count)
            #expect(count >= 1)
            #expect(count <= 2048)
        }

        @Test
        func `core count is at least one and at most the logical count`() {
            let cores = Int(CPU.Core.count)
            #expect(cores >= 1)
            #expect(cores <= Int(CPU.Logical.count))
        }

        @Test
        func `NUMA nodes each hold processors`() {
            if case .nonUniform(let nodes) = CPU.NUMA.state {
                for node in nodes {
                    #expect(!node.processors.isEmpty)
                }
            }
        }

        @Test
        func `sleep completes`() {
            let start = GetTickCount64()
            Windows.`32`.Kernel.Thread.sleep(.milliseconds(10))
            #expect(GetTickCount64() - start >= 9)
        }

        @Test
        func `sleep zero completes immediately`() {
            let start = GetTickCount64()
            Windows.`32`.Kernel.Thread.sleep(.zero)
            #expect(GetTickCount64() - start < 100)
        }
    }

#endif
