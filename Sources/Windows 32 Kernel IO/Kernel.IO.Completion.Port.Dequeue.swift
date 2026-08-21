#if os(Windows)
    public import Error_Primitives
    public import WinSDK

    extension Windows.`32`.Kernel.IO.Completion.Port {

        public enum Dequeue {

        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Dequeue {

        @frozen
        public enum Status: Sendable, Equatable {

            case ok

            case platform(Error_Primitives.Error)
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Dequeue {

        @safe
        @frozen
        public struct Item: @unchecked Sendable {

            public let bytes: UInt32

            public let key: Windows.`32`.Kernel.IO.Completion.Port.Key

            public let overlapped:
                UnsafeMutablePointer<Windows.`32`.Kernel.IO.Completion.Port.Overlapped>?

            public let status: Status

            @unsafe
            @inlinable
            public init(
                bytes: UInt32,
                key: Windows.`32`.Kernel.IO.Completion.Port.Key,
                overlapped: UnsafeMutablePointer<
                    Windows.`32`.Kernel.IO.Completion.Port.Overlapped
                >?,
                status: Status
            ) {
                self.bytes = bytes
                self.key = key
                self.overlapped = unsafe overlapped
                self.status = status
            }
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Dequeue {

        @inlinable
        package static func single(
            _ port: UInt,
            timeout: UInt32
        ) throws(Windows.`32`.Kernel.IO.Completion.Port.Error) -> Item {
            var bytes: DWORD = 0
            var key: ULONG_PTR = 0
            var overlapped: LPOVERLAPPED? = nil

            let ok = unsafe GetQueuedCompletionStatus(
                UnsafeMutableRawPointer(bitPattern: port)!,
                &bytes,
                &key,
                &overlapped,
                DWORD(timeout)
            )

            @unsafe
            func toOverlapped(
                _ raw: LPOVERLAPPED?
            ) -> UnsafeMutablePointer<Windows.`32`.Kernel.IO.Completion.Port.Overlapped>? {
                guard let raw = unsafe raw else { return nil }
                return unsafe UnsafeMutableRawPointer(raw)
                    .assumingMemoryBound(to: Windows.`32`.Kernel.IO.Completion.Port.Overlapped.self)
            }

            if ok {
                return unsafe Item(
                    bytes: UInt32(bytes),
                    key: Windows.`32`.Kernel.IO.Completion.Port.Key(rawValue: key),
                    overlapped: toOverlapped(overlapped),
                    status: .ok
                )
            }

            let error = GetLastError()

            if error == WAIT_TIMEOUT {
                throw .timeout
            }

            let overlappedPtr = unsafe overlapped
            if overlappedPtr != nil {

                return unsafe Item(
                    bytes: UInt32(bytes),
                    key: Windows.`32`.Kernel.IO.Completion.Port.Key(rawValue: key),
                    overlapped: toOverlapped(overlapped),
                    status: .platform(Error_Primitives.Error(code: .win32(error)))
                )
            }

            throw .dequeue(.win32(error))
        }

        @unsafe
        @inlinable
        package static func batch(
            _ port: UInt,
            entries: UnsafeMutableBufferPointer<Windows.`32`.Kernel.IO.Completion.Port.Entry>,
            timeout: UInt32
        ) throws(Windows.`32`.Kernel.IO.Completion.Port.Error) -> Int {
            guard let base = unsafe entries.baseAddress else { return 0 }

            let rawBase = unsafe UnsafeMutableRawPointer(base)
                .assumingMemoryBound(to: OVERLAPPED_ENTRY.self)

            var removed: ULONG = 0
            let result = unsafe GetQueuedCompletionStatusEx(
                UnsafeMutableRawPointer(bitPattern: port)!,
                rawBase,
                ULONG(entries.count),
                &removed,
                DWORD(timeout),
                false
            )

            if !result {
                let error = GetLastError()
                if error == WAIT_TIMEOUT {
                    return 0
                }
                throw .dequeue(.win32(UInt32(error)))
            }

            return Int(removed)
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Dequeue {

        @inlinable
        public static func single(
            _ port: borrowing Windows.`32`.Kernel.Descriptor,
            timeout: UInt32
        ) throws(Windows.`32`.Kernel.IO.Completion.Port.Error) -> Item {
            try single(port._rawValue, timeout: timeout)
        }

        @unsafe
        @inlinable
        public static func batch(
            _ port: borrowing Windows.`32`.Kernel.Descriptor,
            entries: UnsafeMutableBufferPointer<Windows.`32`.Kernel.IO.Completion.Port.Entry>,
            timeout: UInt32
        ) throws(Windows.`32`.Kernel.IO.Completion.Port.Error) -> Int {
            try unsafe batch(port._rawValue, entries: entries, timeout: timeout)
        }
    }

#endif
