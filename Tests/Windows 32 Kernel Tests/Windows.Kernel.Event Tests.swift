#if os(Windows)
    import Testing
    import Windows_32_Kernel

    extension Windows.`32`.Kernel.Event {
        @Suite struct Test {
            @Suite struct Unit {}
        }
    }

    extension Windows.`32`.Kernel.Event.Test.Unit {
        @Test
        func `a fresh event times out and a signaled event stays signaled`() throws(Windows.`32`
            .Kernel
            .Event.Error)
        {
            let event = try Windows.`32`.Kernel.Event()
            let waiting = try event.wait(timeout: 0)
            #expect(!waiting)
            try event.signal()
            let signaled = try event.wait(timeout: 0)
            let retained = try event.wait(timeout: 0)
            #expect(signaled)
            #expect(retained)
        }

        @Test
        func `signaling one event leaves another event waiting`() throws(Windows.`32`.Kernel.Event
            .Error)
        {
            let first = try Windows.`32`.Kernel.Event()
            let second = try Windows.`32`.Kernel.Event()
            try first.signal()
            let signaled = try first.wait(timeout: 0)
            let unrelated = try second.wait(timeout: 0)
            #expect(signaled)
            #expect(!unrelated)
        }
    }
#endif
