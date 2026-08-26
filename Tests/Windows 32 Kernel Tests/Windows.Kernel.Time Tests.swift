#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error
    import Path
    import Clock
    import Random
    import System

    extension Windows.`32`.Kernel.Time {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Windows.`32`.Kernel.Time.Test.Unit {
        @Test
        func `Time namespace exists`() {
            _ = Windows.`32`.Kernel.Time.self
        }
    }

    extension Windows.`32`.Kernel.Time.Test.Unit {
        @Test
        func `systemTime returns valid FILETIME`() {
            let ft = Windows.`32`.Kernel.Time.systemTime()

            #expect(ft.dwHighDateTime > 0 || ft.dwLowDateTime > 0)
        }

        @Test
        func `realtime returns reasonable value`() {
            let now = Windows.`32`.Kernel.Time.realtime()

            #expect(now.secondsSinceUnixEpoch > 1_577_836_800)
            #expect(now.nanosecondFraction >= 0)
            #expect(now.nanosecondFraction < 1_000_000_000)
        }

        @Test
        func `realtime nanosecond fraction aligned to 100-ns boundary`() {

            let now = Windows.`32`.Kernel.Time.realtime()
            #expect(now.nanosecondFraction % 100 == 0)
        }
    }

#endif
