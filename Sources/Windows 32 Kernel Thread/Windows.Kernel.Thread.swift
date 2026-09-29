#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel {

        public enum Thread: Sendable {}
    }

    extension Windows.`32`.Kernel.Thread {

        @inlinable
        public static func create(
            _ body: @escaping @Sendable () -> Void
        ) throws(Windows.`32`.Kernel.Thread.Error) -> Windows.`32`.Kernel.Thread.Handle {
            let context = UnsafeMutablePointer<(@Sendable () -> Void)>.allocate(capacity: 1)
            context.initialize(to: body)

            let threadProc: LPTHREAD_START_ROUTINE = { ctx in
                guard let ctx else { return 0 }
                let bodyPtr = ctx.assumingMemoryBound(to: (@Sendable () -> Void).self)
                let work = bodyPtr.move()
                bodyPtr.deallocate()
                work()
                return 0
            }

            let handle = CreateThread(
                nil,
                0,
                threadProc,
                context,
                0,
                nil
            )

            guard let handle else {

                let lastError = Error::Error.captureLastError()
                context.deinitialize(count: 1)
                context.deallocate()
                throw .create(Error::Error(code: lastError))
            }

            return Windows.`32`.Kernel.Thread.Handle(_handle: handle)
        }

        @inlinable
        public static func join(
            _ handle: Windows.`32`.Kernel.Thread.Handle,
            timeout: DWORD = INFINITE
        ) -> Bool {
            let result = WaitForSingleObject(handle._handle, timeout)
            return result == WAIT_OBJECT_0
        }

        @inlinable
        public static func close(_ handle: Windows.`32`.Kernel.Thread.Handle) {
            _ = CloseHandle(handle._handle)
        }
    }

    extension Windows.`32`.Kernel.Thread {

        @inlinable
        public static func yield() {
            _ = SwitchToThread()
        }
    }

    extension Windows.`32`.Kernel.Thread {

        @inlinable
        public static func current() -> Windows.`32`.Kernel.Thread.Handle {
            Windows.`32`.Kernel.Thread.Handle(_handle: GetCurrentThread())
        }

        @available(
            *,
            deprecated,
            message:
                "Use Windows.`32`.Kernel.Thread.ID.current for portable, typed thread identity."
        )
        @inlinable
        public static func currentID() -> DWORD {
            GetCurrentThreadId()
        }
    }

    extension Windows.`32`.Kernel.Thread.Handle {

        @inlinable
        package init(_handle: HANDLE) {
            self = Self(rawValue: UInt(bitPattern: _handle))
        }

        @inlinable
        package var _handle: HANDLE {
            HANDLE(bitPattern: Int(rawValue))!
        }
    }

    extension Windows.`32`.Kernel.Thread.Handle {

        public var isCurrent: Bool {
            GetThreadId(_handle) == GetCurrentThreadId()
        }

        public consuming func join() {
            _ = WaitForSingleObject(_handle, INFINITE)
            _ = CloseHandle(_handle)
        }

        public consuming func detach() {
            _ = CloseHandle(_handle)
        }
    }

#endif
