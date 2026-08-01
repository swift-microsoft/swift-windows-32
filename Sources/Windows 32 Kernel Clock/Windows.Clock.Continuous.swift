// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-32 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-windows-32 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)

    // MARK: - Clock.Continuous Windows Implementation

    extension Clock.Continuous: _Concurrency.Clock {
        /// The current instant according to the continuous clock.
        ///
        /// Delegates directly to `Clock.Continuous.now`, which
        /// wraps `QueryPerformanceCounter` on Windows.
        public var now: Instant { Clock.Continuous.now }

        /// Suspends until the given deadline, checking for cancellation.
        nonisolated(nonsending)
            public func sleep(until deadline: Instant, tolerance: Duration? = nil) async throws(CancellationError)
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

    // MARK: - Clock.Suspending Windows Implementation

    extension Clock.Suspending: _Concurrency.Clock {
        /// The current instant according to the suspending clock.
        ///
        /// Delegates directly to `Clock.Suspending.now`, which
        /// wraps `QueryUnbiasedInterruptTime` on Windows.
        public var now: Instant { Clock.Suspending.now }

        /// Suspends until the given deadline, checking for cancellation.
        nonisolated(nonsending)
            public func sleep(until deadline: Instant, tolerance: Duration? = nil) async throws(CancellationError)
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
