#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error
    import Path
    import Clock
    import Random
    import System

    extension System {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension System.Test.Unit {
        @Test
        func `System namespace exists`() {
            _ = System.self
        }
    }

    extension System.Test.Unit {
        @Test
        func `pathMax returns MAX_PATH`() {
            let pathMax = System.pathMax
            #expect(pathMax.underlying == 260)
        }
    }

    extension System.Test.Unit {
        @Test
        func `pageSize returns positive value`() {
            let pageSize = System.pageSize
            #expect(pageSize.underlying > 0)
        }

        @Test
        func `pageSize is typically 4096`() {
            let pageSize = System.pageSize

            #expect(pageSize.underlying >= 4096)
            #expect(pageSize.underlying <= 65536)
        }

        @Test
        func `pageSize is power of 2`() {
            let pageSize = System.pageSize
            let value = pageSize.underlying.rawValue
            #expect(value > 0 && (value & (value - 1)) == 0)
        }
    }

    extension System.Test.Unit {
        @Test
        func `processorCount returns positive value`() {
            let count = System.processorCount
            #expect(count.underlying > 0)
        }

        @Test
        func `processorCount is reasonable`() {
            let count = System.processorCount

            #expect(count.underlying >= 1)
            #expect(count.underlying <= 1024)
        }

        @Test
        func `processorCount matches GetSystemInfo`() {
            var sysInfo = SYSTEM_INFO()
            GetSystemInfo(&sysInfo)

            let count = System.processorCount
            #expect(count.underlying.rawValue == UInt(sysInfo.dwNumberOfProcessors))
        }
    }

    extension System.Test.Unit {
        @Test
        func `sleep completes`() {
            let start = GetTickCount64()
            System.sleep(.milliseconds(10))
            let elapsed = GetTickCount64() - start

            #expect(elapsed >= 9)
        }

        @Test
        func `sleep zero completes immediately`() {
            let start = GetTickCount64()
            System.sleep(.zero)
            let elapsed = GetTickCount64() - start

            #expect(elapsed < 100)
        }
    }

    extension System.Test.EdgeCase {
        @Test
        func `pageSize is consistent`() {
            let size1 = System.pageSize
            let size2 = System.pageSize
            #expect(size1.underlying == size2.underlying)
        }

        @Test
        func `processorCount is consistent`() {
            let count1 = System.processorCount
            let count2 = System.processorCount
            #expect(count1.underlying == count2.underlying)
        }
    }

#endif
