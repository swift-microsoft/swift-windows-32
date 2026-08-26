#if os(Windows)
    public import Error
    public import WinSDK

    extension Windows.`32`.Kernel.IO.Completion.Port {

        public enum Cancel {}
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Cancel {

        @inlinable
        package static func all(_ handle: UInt) -> Bool {
            CancelIoEx(UnsafeMutableRawPointer(bitPattern: handle)!, nil)
        }

        @unsafe
        @inlinable
        package static func pending(_ handle: UInt, overlapped: LPOVERLAPPED) -> Bool {
            unsafe CancelIoEx(UnsafeMutableRawPointer(bitPattern: handle)!, overlapped)
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Cancel {

        public struct All: Sendable {
            let handle: UInt

            init(_ handle: UInt) {
                self.handle = handle
            }
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Cancel.All {

        public func callAsFunction() {
            _ = Windows.`32`.Kernel.IO.Completion.Port.Cancel.all(handle)
        }

        public var status: Bool {
            if Windows.`32`.Kernel.IO.Completion.Port.Cancel.all(handle) {
                return true
            }
            return GetLastError()
                != Windows.`32`.Kernel.IO.Completion.Port.Error.Code.Lookup.notFound
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Cancel {

        public static func all(_ descriptor: borrowing Windows.`32`.Kernel.Descriptor) -> All {
            All(descriptor._rawValue)
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Cancel {

        @safe
        public struct Pending: @unchecked Sendable {
            let handle: UInt

            let overlappedPtr:
                UnsafeMutablePointer<Windows.`32`.Kernel.IO.Completion.Port.Overlapped>

            @unsafe
            init(
                _ handle: UInt,
                overlapped: UnsafeMutablePointer<Windows.`32`.Kernel.IO.Completion.Port.Overlapped>
            ) {
                self.handle = handle
                self.overlappedPtr = unsafe overlapped
            }
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Cancel.Pending {

        public func callAsFunction() {
            let ptr = unsafe overlappedPtr
            _ = unsafe withUnsafeMutablePointer(to: &ptr.pointee.raw) { rawPtr in
                Windows.`32`.Kernel.IO.Completion.Port.Cancel.pending(handle, overlapped: rawPtr)
            }
        }

        public var status: Bool {
            let ptr = unsafe overlappedPtr
            let result = unsafe withUnsafeMutablePointer(to: &ptr.pointee.raw) { rawPtr in
                Windows.`32`.Kernel.IO.Completion.Port.Cancel.pending(handle, overlapped: rawPtr)
            }
            if result {
                return true
            }
            return GetLastError()
                != Windows.`32`.Kernel.IO.Completion.Port.Error.Code.Lookup.notFound
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Cancel.Pending {

        public struct Result: Sendable {
            let succeeded: Bool
            let lastError: DWORD
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Cancel.Pending.Result {

        public func callAsFunction() {}

        public var status: Bool {
            if succeeded {
                return true
            }
            return lastError != Windows.`32`.Kernel.IO.Completion.Port.Error.Code.Lookup.notFound
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Cancel {

        public static func pending(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
            overlapped: inout Windows.`32`.Kernel.IO.Completion.Port.Overlapped
        ) -> Pending.Result {
            let handle = descriptor._rawValue
            let succeeded = unsafe withUnsafeMutablePointer(to: &overlapped.raw) { rawPtr in
                Windows.`32`.Kernel.IO.Completion.Port.Cancel.pending(handle, overlapped: rawPtr)
            }
            let lastError = succeeded ? DWORD(0) : GetLastError()
            return Pending.Result(succeeded: succeeded, lastError: lastError)
        }

        @unsafe
        public static func pending(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
            overlapped: UnsafeMutablePointer<Windows.`32`.Kernel.IO.Completion.Port.Overlapped>
        ) -> Pending {
            unsafe Pending(descriptor._rawValue, overlapped: overlapped)
        }
    }

#endif
