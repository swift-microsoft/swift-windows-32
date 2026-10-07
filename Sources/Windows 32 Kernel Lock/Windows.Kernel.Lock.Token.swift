public import Clock

#if os(Windows)
    internal import WinSDK
    internal import Windows_32_Kernel_Clock
#endif

extension Windows.`32`.Kernel.Lock {

    public struct Token: ~Copyable, Sendable {

        @usableFromInline internal let descriptor: Windows.`32`.Kernel.Descriptor
        @usableFromInline internal let range: Windows.`32`.Kernel.Lock.Range
        @usableFromInline internal var isReleased: Bool

        public init(
            descriptor: consuming Windows.`32`.Kernel.Descriptor,
            range: Windows.`32`.Kernel.Lock.Range = .file,
            kind: Windows.`32`.Kernel.Lock.Kind,
            acquire: Windows.`32`.Kernel.Lock.Acquire = .wait
        ) throws(Windows.`32`.Kernel.Lock.Error) {

            try Self.acquireLock(
                descriptor: descriptor,
                range: range,
                kind: kind,
                acquire: acquire
            )

            self.descriptor = descriptor
            self.range = range
            self.isReleased = false
        }

        deinit {

            guard !isReleased else { return }
            do throws(Windows.`32`.Kernel.Lock.Error) {
                try Windows.`32`.Kernel.Lock.unlock(descriptor, range: range)
            } catch {

            }
        }
    }
}

extension Windows.`32`.Kernel.Lock.Token {

    public mutating func release() throws(Windows.`32`.Kernel.Lock.Error) {
        guard !isReleased else { return }
        try Windows.`32`.Kernel.Lock.unlock(descriptor, range: range)
        isReleased = true
    }
}

extension Windows.`32`.Kernel.Lock.Token {

    private static func acquireLock(
        descriptor: borrowing Windows.`32`.Kernel.Descriptor,
        range: Windows.`32`.Kernel.Lock.Range,
        kind: Windows.`32`.Kernel.Lock.Kind,
        acquire: Windows.`32`.Kernel.Lock.Acquire
    ) throws(Windows.`32`.Kernel.Lock.Error) {
        switch acquire {
        case .try:
            try Windows.`32`.Kernel.Lock.Immediate.lock(descriptor, range: range, kind: kind)

        case .wait:
            try Windows.`32`.Kernel.Lock.lock(descriptor, range: range, kind: kind)

        case .deadline(let deadline):
            try acquireWithDeadline(
                descriptor: descriptor,
                range: range,
                kind: kind,
                deadline: deadline
            )
        }
    }

    private static func acquireWithDeadline(
        descriptor: borrowing Windows.`32`.Kernel.Descriptor,
        range: Windows.`32`.Kernel.Lock.Range,
        kind: Windows.`32`.Kernel.Lock.Kind,
        deadline: Clock.Continuous.Instant
    ) throws(Windows.`32`.Kernel.Lock.Error) {
        #if os(Windows)
            var backoff: Duration = .milliseconds(1)
            let maxBackoff: Duration = .milliseconds(100)

            while true {

                let now = Clock.Continuous.now
                if now >= deadline {
                    throw .timedOut
                }

                do throws(Windows.`32`.Kernel.Lock.Error) {
                    try Windows.`32`.Kernel.Lock.Immediate.lock(
                        descriptor,
                        range: range,
                        kind: kind
                    )

                    if Clock.Continuous.now >= deadline {

                        try Windows.`32`.Kernel.Lock.unlock(descriptor, range: range)
                        throw Windows.`32`.Kernel.Lock.Error.timedOut
                    }
                    return
                } catch {
                    switch error {
                    case .contention:
                        break

                    default:
                        throw error
                    }
                }

                let remaining = deadline.offset - Clock.Continuous.now.offset
                if remaining <= .zero {
                    throw .timedOut
                }

                let sleepDuration = min(backoff, remaining)
                sleep(sleepDuration)

                backoff = min(backoff * 2, maxBackoff)
            }
        #else
            throw .timedOut
        #endif
    }

    private static func sleep(_ duration: Duration) {
        #if os(Windows)
            let (seconds, attoseconds) = duration.components
            let milliseconds = UInt64(seconds) * 1000 + UInt64(attoseconds) / 1_000_000_000_000_000
            unsafe Sleep(DWORD(milliseconds))
        #endif
    }
}
