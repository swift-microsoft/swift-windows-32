#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error
    import Memory

    extension Memory.Allocation {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Memory.Allocation.Test.Unit {
        @Test
        func `Memory.Allocation namespace exists`() {
            _ = Memory.Allocation.self
        }

        @Test
        func `Memory.Allocation.Error type exists`() {
            _ = Memory.Allocation.Error.self
        }
    }

    extension Memory.Allocation.Test.Unit {
        @Test
        func `systemPageSize returns non-zero`() {
            let pageSize = Memory.Allocation.systemPageSize()
            #expect(pageSize > 0)
        }

        @Test
        func `systemPageSize is typically 4096`() {
            let pageSize = Memory.Allocation.systemPageSize()

            #expect(pageSize >= 4096)
            #expect(pageSize <= 65536)
        }

        @Test
        func `system granularity exists`() {
            let granularity = Memory.Allocation.system
            #expect(granularity.underlying >= .byte)
        }
    }

    extension Memory.Allocation.Test.Unit {
        @Test
        func `allocate with zero size throws invalid length`() {
            #expect(throws: Memory.Map.Error.self) {
                _ = try Memory.Allocation.allocate(
                    size: 0,
                    protection: .readWrite
                )
            }
        }

        @Test
        func `allocate with valid size succeeds`() throws {
            let pageSize = Int(Memory.Allocation.systemPageSize())
            let addr = try Memory.Allocation.allocate(
                size: pageSize,
                protection: .readWrite
            )

            try Memory.Allocation.free(addr: addr)
        }

        @Test
        func `allocate and free round-trip`() throws {
            let pageSize = Int(Memory.Allocation.systemPageSize())

            for _ in 0..<10 {
                let addr = try Memory.Allocation.allocate(
                    size: pageSize,
                    protection: .readWrite
                )
                try Memory.Allocation.free(addr: addr)
            }
        }
    }

    extension Memory.Allocation.Test.Unit {
        @Test
        func `Error.exhausted exists`() {
            let error = Memory.Allocation.Error.exhausted
            #expect(error == .exhausted)
        }
    }

    extension Memory.Allocation.Test.EdgeCase {
        @Test
        func `allocate large size`() throws {

            let size = 1024 * 1024
            let addr = try Memory.Allocation.allocate(
                size: size,
                protection: .readWrite
            )

            try Memory.Allocation.free(addr: addr)
        }
    }

    extension Memory.Allocation.Test.Integration {
        @Test
        func `allocateAligned above the allocation granularity succeeds and is aligned`() throws {
            var info = SYSTEM_INFO()
            GetSystemInfo(&info)
            let alignment = Int(info.dwAllocationGranularity) * 2
            let size = Int(info.dwPageSize)

            for _ in 0..<32 {
                let address = try Memory.Allocation.allocateAligned(
                    size: size,
                    alignment: alignment,
                    protection: .readWrite
                )
                #expect(Int(bitPattern: address.pointer) % alignment == 0)
                try Memory.Allocation.free(addr: address)
            }
        }

        @Test
        func `allocateAligned rejects an alignment that is not a power of two`() {
            #expect(throws: Memory.Map.Error.self) {
                _ = try Memory.Allocation.allocateAligned(
                    size: 4096,
                    alignment: 3 * 65536,
                    protection: .readWrite
                )
            }
        }
    }

#endif
