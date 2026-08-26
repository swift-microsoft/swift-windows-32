#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error
    import Path
    import Clock
    import Random
    import System

    extension Windows.`32`.Kernel.Directory.Working {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Windows.`32`.Kernel.Directory.Working.Test.Unit {
        @Test
        func `Directory.Working namespace exists`() {
            _ = Windows.`32`.Kernel.Directory.Working.self
        }
    }

    extension Windows.`32`.Kernel.Directory.Working.Test.Unit {
        @Test
        func `get() returns non-empty path`() throws {
            let cwd = try Windows.`32`.Kernel.Directory.Working.get()
            #expect(!cwd.isEmpty)
        }

        @Test
        func `get(into:) works with buffer`() throws {
            var buffer = [UInt16](repeating: 0, count: 260)
            let length = try buffer.withUnsafeMutableBufferPointer { bufferPtr in
                try Windows.`32`.Kernel.Directory.Working.get(into: bufferPtr)
            }
            #expect(length > 0)
        }

        @Test
        func `get() result matches GetCurrentDirectoryW`() throws {
            let cwd = try Windows.`32`.Kernel.Directory.Working.get()

            var buffer = [WCHAR](repeating: 0, count: 260)
            let length = GetCurrentDirectoryW(DWORD(buffer.count), &buffer)

            #expect(length > 0)
            #expect(cwd.count == Int(length))
        }
    }

    extension Windows.`32`.Kernel.Directory.Working.Test.EdgeCase {
        @Test
        func `get(into:) with small buffer throws`() {
            var buffer = [UInt16](repeating: 0, count: 1)

            #expect(throws: Kernel.Directory.Working.Error.self) {
                try buffer.withUnsafeMutableBufferPointer { bufferPtr in
                    _ = try Windows.`32`.Kernel.Directory.Working.get(into: bufferPtr)
                }
            }
        }
    }

#endif
