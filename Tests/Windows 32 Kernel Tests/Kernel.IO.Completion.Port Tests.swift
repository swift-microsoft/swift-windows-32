#if os(Windows)
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error

    extension Kernel.IO.Completion.Port {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Kernel.IO.Completion.Port.Test.Unit {
        @Test
        func `Port namespace exists`() {
            _ = Kernel.IO.Completion.Port.self
        }

        @Test
        func `create returns valid descriptor`() throws {
            let port = try Kernel.IO.Completion.Port.create()

            let portIsValid = port.isValid
            #expect(portIsValid)
        }

        @Test
        func `create with concurrency parameter`() throws {

            let port = try Kernel.IO.Completion.Port.create(threads: 4)

            let portIsValid = port.isValid
            #expect(portIsValid)
        }

        @Test
        func `create multiple ports are independent`() throws {
            let port1 = try Kernel.IO.Completion.Port.create()

            let port2 = try Kernel.IO.Completion.Port.create()

            #expect(port1._rawValue != port2._rawValue)
        }

        @Test
        func `close completes without error`() throws {
            let port = try Kernel.IO.Completion.Port.create()
            Kernel.IO.Completion.Port.close(port)

        }
    }

    extension Kernel.IO.Completion.Port.Test.Unit {
        @Test
        func `post completion to port`() throws {
            let port = try Kernel.IO.Completion.Port.create()

            try Kernel.IO.Completion.Port.post(
                port,
                bytes: 42,
                key: Kernel.IO.Completion.Port.Key(123)
            )
        }

        @Test
        func `post and dequeue single completion`() throws {
            let port = try Kernel.IO.Completion.Port.create()

            let expected: DWORD = 100
            let expectedKey = Kernel.IO.Completion.Port.Key(456)

            try Kernel.IO.Completion.Port.post(
                port,
                bytes: expected,
                key: expectedKey
            )

            let result = try Kernel.IO.Completion.Port.Dequeue.single(port, timeout: 1000)

            #expect(result.bytes == expected)
            #expect(result.key == expectedKey)
            #expect(result.overlapped == nil)
        }

        @Test
        func `post multiple completions and dequeue in order`() throws {
            let port = try Kernel.IO.Completion.Port.create()

            for i: DWORD in 0..<5 {
                try Kernel.IO.Completion.Port.post(
                    port,
                    bytes: i * 10,
                    key: Kernel.IO.Completion.Port.Key(ULONG_PTR(i))
                )
            }

            for i: DWORD in 0..<5 {
                let result = try Kernel.IO.Completion.Port.Dequeue.single(port, timeout: 1000)
                #expect(result.bytes == i * 10)
                #expect(result.key.rawValue == ULONG_PTR(i))
            }
        }

        @Test
        func `dequeue times out when no completions`() throws {
            let port = try Kernel.IO.Completion.Port.create()

            #expect(throws: Kernel.IO.Completion.Port.Error.self) {
                _ = try Kernel.IO.Completion.Port.Dequeue.single(port, timeout: 10)
            }
        }

        @Test
        func `dequeue timeout throws correct error`() throws {
            let port = try Kernel.IO.Completion.Port.create()

            do {
                _ = try Kernel.IO.Completion.Port.Dequeue.single(port, timeout: 10)
                Issue.record("Expected timeout error")
            } catch {
                if case .timeout = error {

                } else {
                    Issue.record("Expected .timeout, got \(error)")
                }
            }
        }
    }

    extension Kernel.IO.Completion.Port.Test.Unit {
        @Test
        func `batch dequeue returns zero on timeout`() throws {
            let port = try Kernel.IO.Completion.Port.create()

            var entries = [Kernel.IO.Completion.Port.Entry](repeating: .init(), count: 10)
            let count = try entries.withUnsafeMutableBufferPointer { buffer in
                try Kernel.IO.Completion.Port.Dequeue.batch(port, entries: buffer, timeout: 10)
            }

            #expect(count == 0)
        }

        @Test
        func `batch dequeue retrieves multiple completions`() throws {
            let port = try Kernel.IO.Completion.Port.create()

            let postCount = 5

            for i in 0..<postCount {
                try Kernel.IO.Completion.Port.post(
                    port,
                    bytes: DWORD(i * 10),
                    key: Kernel.IO.Completion.Port.Key(ULONG_PTR(i))
                )
            }

            var entries = [Kernel.IO.Completion.Port.Entry](repeating: .init(), count: 10)
            let count = try entries.withUnsafeMutableBufferPointer { buffer in
                try Kernel.IO.Completion.Port.Dequeue.batch(port, entries: buffer, timeout: 1000)
            }

            #expect(count == postCount)

            for i in 0..<count {
                #expect(entries[i].bytes.transferred == Kernel.File.Size(i * 10))
                #expect(entries[i].key == Kernel.IO.Completion.Port.Key(ULONG_PTR(i)))
            }
        }

        @Test
        func `batch dequeue with smaller buffer than completions`() throws {
            let port = try Kernel.IO.Completion.Port.create()

            for i in 0..<10 {
                try Kernel.IO.Completion.Port.post(
                    port,
                    bytes: DWORD(i),
                    key: Kernel.IO.Completion.Port.Key(ULONG_PTR(i))
                )
            }

            var entries = [Kernel.IO.Completion.Port.Entry](repeating: .init(), count: 3)
            let count = try entries.withUnsafeMutableBufferPointer { buffer in
                try Kernel.IO.Completion.Port.Dequeue.batch(port, entries: buffer, timeout: 1000)
            }

            #expect(count <= 3)
            #expect(count >= 1)
        }
    }

    extension Kernel.IO.Completion.Port.Test.Unit {
        @Test
        func `read(_:into:overlapped:) takes a caller-owned pointer, not a closure-scoped inout`() {
            let overlapped = UnsafeMutablePointer<Kernel.IO.Completion.Port.Overlapped>.allocate(
                capacity: 1
            )
            overlapped.initialize(to: .init())
            defer {
                overlapped.deinitialize(count: 1)
                overlapped.deallocate()
            }

            var buffer = [UInt8](repeating: 0, count: 16)

            #expect(throws: Kernel.IO.Completion.Port.Error.self) {
                _ = try buffer.withUnsafeMutableBytes { raw in
                    try unsafe Kernel.IO.Completion.Port.read(
                        Kernel.Descriptor.invalid,
                        into: raw,
                        overlapped: overlapped
                    )
                }
            }
        }

        @Test
        func `write(_:from:overlapped:) takes a caller-owned pointer, not a closure-scoped inout`()
        {
            let overlapped = UnsafeMutablePointer<Kernel.IO.Completion.Port.Overlapped>.allocate(
                capacity: 1
            )
            overlapped.initialize(to: .init())
            defer {
                overlapped.deinitialize(count: 1)
                overlapped.deallocate()
            }

            let buffer: [UInt8] = [1, 2, 3, 4]
            #expect(throws: Kernel.IO.Completion.Port.Error.self) {
                _ = try buffer.withUnsafeBytes { raw in
                    try unsafe Kernel.IO.Completion.Port.write(
                        Kernel.Descriptor.invalid,
                        from: raw,
                        overlapped: overlapped
                    )
                }
            }
        }
    }

    extension Kernel.IO.Completion.Port.Test.Unit {
        @Test
        func `Error type exists`() {
            let _: Kernel.IO.Completion.Port.Error.Type = Kernel.IO.Completion.Port.Error.self
        }

        @Test
        func `Entry type exists`() {
            let _: Kernel.IO.Completion.Port.Entry.Type = Kernel.IO.Completion.Port.Entry.self
        }

        @Test
        func `Overlapped type exists`() {
            let _: Kernel.IO.Completion.Port.Overlapped.Type = Kernel.IO.Completion.Port.Overlapped
                .self
        }

        @Test
        func `Dequeue type exists`() {
            let _: Kernel.IO.Completion.Port.Dequeue.Type = Kernel.IO.Completion.Port.Dequeue.self
        }

        @Test
        func `Cancel type exists`() {
            let _: Kernel.IO.Completion.Port.Cancel.Type = Kernel.IO.Completion.Port.Cancel.self
        }

        @Test
        func `Key type exists`() {
            let _: Kernel.IO.Completion.Port.Key.Type = Kernel.IO.Completion.Port.Key.self
        }

        @Test
        func `Read.Result type exists`() {
            let _: Kernel.IO.Completion.Port.Read.Result.Type = Kernel.IO.Completion.Port.Read
                .Result.self
        }

        @Test
        func `Write.Result type exists`() {
            let _: Kernel.IO.Completion.Port.Write.Result.Type = Kernel.IO.Completion.Port.Write
                .Result.self
        }
    }

    extension Kernel.IO.Completion.Port.Test.EdgeCase {
        @Test
        func `post with zero bytes`() throws {
            let port = try Kernel.IO.Completion.Port.create()

            try Kernel.IO.Completion.Port.post(port, bytes: 0)

            let result = try Kernel.IO.Completion.Port.Dequeue.single(port, timeout: 1000)
            #expect(result.bytes == 0)
        }

        @Test
        func `post with maximum key value`() throws {
            let port = try Kernel.IO.Completion.Port.create()

            let maxKey = Kernel.IO.Completion.Port.Key(rawValue: ULONG_PTR.max)
            try Kernel.IO.Completion.Port.post(port, key: maxKey)

            let result = try Kernel.IO.Completion.Port.Dequeue.single(port, timeout: 1000)
            #expect(result.key == maxKey)
        }

        @Test
        func `create and immediately close`() throws {
            for _ in 0..<100 {
                let port = try Kernel.IO.Completion.Port.create()
                Kernel.IO.Completion.Port.close(port)
            }
        }
    }

#endif
