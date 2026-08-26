#if os(Windows)
    import WinSDK
    import Testing
    import Standard_Library_Extensions

    @testable import Windows_32_Kernel
    import Error
    import Path
    import Clock
    import Random
    import System

    extension Windows.`32`.Kernel.Random {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Windows.`32`.Kernel.Random.Test.Unit {
        @Test
        func `Random namespace exists`() {
            _ = Windows.`32`.Kernel.Random.self
        }
    }

    extension Windows.`32`.Kernel.Random.Test.Unit {
        @Test
        func `bCryptGenRandom fills buffer without throwing`() throws(Random.Error) {
            var buffer: (UInt64, UInt64, UInt64, UInt64) = (0, 0, 0, 0)
            try withUnsafeMutableBytes(of: &buffer) { raw throws(Random.Error) in
                try Windows.`32`.Kernel.Random.bCryptGenRandom(raw)
            }
        }

        @Test
        func `bCryptGenRandom produces non-zero bytes`() throws(Random.Error) {
            var buffer: (UInt64, UInt64, UInt64, UInt64) = (0, 0, 0, 0)
            try withUnsafeMutableBytes(of: &buffer) { raw throws(Random.Error) in
                try Windows.`32`.Kernel.Random.bCryptGenRandom(raw)
            }

            #expect(buffer != (0, 0, 0, 0))
        }

        @Test
        func `bCryptGenRandom with empty buffer is a no-op`() throws(Random.Error) {
            let buffer = UnsafeMutableRawBufferPointer(start: nil, count: 0)
            try Windows.`32`.Kernel.Random.bCryptGenRandom(buffer)
        }
    }

    extension Windows.`32`.Kernel.Random.Test.Unit {
        @Test
        func `uint64 returns value`() {
            let value = Windows.`32`.Kernel.Random.uint64()
            #expect(value != nil)
        }

        @Test
        func `uint32 returns value`() {
            let value = Windows.`32`.Kernel.Random.uint32()
            #expect(value != nil)
        }

        @Test
        func `uint64 produces different values`() {
            var values: Set<UInt64> = []
            for _ in 0..<10 {
                if let v = Windows.`32`.Kernel.Random.uint64() {
                    values.insert(v)
                }
            }

            #expect(values.count >= 9)
        }

        @Test
        func `uint32 produces different values`() {
            var values: Set<UInt32> = []
            for _ in 0..<10 {
                if let v = Windows.`32`.Kernel.Random.uint32() {
                    values.insert(v)
                }
            }
            #expect(values.count >= 9)
        }
    }

    extension Windows.`32`.Kernel.Random.Test.EdgeCase {
        @Test
        func `bCryptGenRandom fills a one-megabyte buffer`() throws(Random.Error) {
            let buffer = UnsafeMutableRawBufferPointer.allocate(
                byteCount: 1024 * 1024,
                alignment: 1
            )
            defer { buffer.deallocate() }
            buffer.initializeMemory(as: UInt8.self, repeating: 0)
            try Windows.`32`.Kernel.Random.bCryptGenRandom(buffer)
        }

        @Test
        func `successive bCryptGenRandom calls produce different bytes`() throws(Random.Error) {
            var first: (UInt64, UInt64, UInt64, UInt64) = (0, 0, 0, 0)
            var second: (UInt64, UInt64, UInt64, UInt64) = (0, 0, 0, 0)

            try withUnsafeMutableBytes(of: &first) { raw throws(Random.Error) in
                try Windows.`32`.Kernel.Random.bCryptGenRandom(raw)
            }
            try withUnsafeMutableBytes(of: &second) { raw throws(Random.Error) in
                try Windows.`32`.Kernel.Random.bCryptGenRandom(raw)
            }

            #expect(first != second)
        }
    }

#endif
