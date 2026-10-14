#if os(Windows)
    import Testing
    import Windows_32_Kernel

    extension Windows.`32`.Kernel.Process.Job {
        @Suite struct Test {
            @Suite struct Unit {}
        }
    }

    extension Windows.`32`.Kernel.Process.Job.Test.Unit {
        @Test
        func `assigning an invalid process reports its typed error`() throws(Windows.`32`.Kernel
            .Process
            .Error)
        {
            let job = try Windows.`32`.Kernel.Process.Job()
            let invalid = Windows.`32`.Kernel.Descriptor.invalid
            do throws(Windows.`32`.Kernel.Process.Error) {
                try job.assign(invalid)
                Issue.record("expected an invalid process handle error")
            } catch {
                #expect(error == .create(.win32(6)))
            }
        }
    }
#endif
