#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.IO.Completion.Port {

        @unsafe
        @inlinable
        public static func wakeup(
            _ port: borrowing Windows.`32`.Kernel.Descriptor
        ) -> @Sendable () -> Void {
            let rawPort = port._rawValue
            return {
                _ = unsafe PostQueuedCompletionStatus(
                    UnsafeMutableRawPointer(bitPattern: rawPort)!,
                    0,
                    0,
                    nil
                )

            }
        }
    }

#endif
