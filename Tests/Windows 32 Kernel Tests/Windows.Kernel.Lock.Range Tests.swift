#if os(Windows)
    import Testing

    @testable import Windows_32_Kernel

    extension Windows.`32`.Kernel.Lock.Range {
        @Suite struct Test {
            @Suite struct Unit {}
            @Suite struct `Edge Case` {}
        }
    }

    extension Windows.`32`.Kernel.Lock.Range.Test.Unit {
        @Test
        func `mapping range rounds the end to allocation granularity`() {
            let offset = Windows.`32`.Kernel.File.Offset(65_536)
            let length = Windows.`32`.Kernel.File.Size(1)
            let granularity = Memory.Allocation.system

            let range = Windows.`32`.Kernel.Lock.Range(
                forMappingAt: offset,
                length: length,
                granularity: granularity
            )

            #expect(range == .bytes(start: offset, end: granularity.underlying.alignUp(65_537)))
        }
    }

    extension Windows.`32`.Kernel.Lock.Range.Test.`Edge Case` {
        @Test
        func `mapping range saturates an overflowing end`() {
            let offset = Windows.`32`.Kernel.File.Offset.max
            let length = Windows.`32`.Kernel.File.Size(1)

            let range = Windows.`32`.Kernel.Lock.Range(
                forMappingAt: offset,
                length: length,
                granularity: Memory.Allocation.system
            )

            #expect(range == .bytes(start: offset, end: .max))
        }
    }
#endif
