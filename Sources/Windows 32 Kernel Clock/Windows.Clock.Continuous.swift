#if os(Windows)

    extension Clock.Continuous: _Concurrency.Clock {

        public var now: Instant { Clock.Continuous.now }

        nonisolated(nonsending)
            public func sleep(
                until deadline: Instant,
                tolerance: Duration? = nil
            ) async throws(CancellationError)
        {
            while Clock.Continuous.now < deadline {
                guard !Task.isCancelled else { throw CancellationError() }
                do {
                    try await Task.sleep(for: .nanoseconds(1_000_000))
                } catch {
                    throw CancellationError()
                }
            }
        }
    }

    extension Clock.Suspending: _Concurrency.Clock {

        public var now: Instant { Clock.Suspending.now }

        nonisolated(nonsending)
            public func sleep(
                until deadline: Instant,
                tolerance: Duration? = nil
            ) async throws(CancellationError)
        {
            while Clock.Suspending.now < deadline {
                guard !Task.isCancelled else { throw CancellationError() }
                do {
                    try await Task.sleep(for: .nanoseconds(1_000_000))
                } catch {
                    throw CancellationError()
                }
            }
        }
    }

#endif
