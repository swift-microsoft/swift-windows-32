// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-32 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows-32 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Clock_Primitives

#if os(Windows)
    internal import WinSDK
    internal import Windows_32_Kernel_Clock
#endif

// MARK: - Lock Token

extension Windows.`32`.Kernel.Lock {
    /// A move-only token representing a held file lock.
    ///
    /// `Token` ensures the lock is released when it goes out of scope.
    /// It is `~Copyable` to prevent accidental duplication of lock ownership.
    /// Mirrors `ISO_9945.Kernel.Lock.Token`'s init/`release()` shape.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let token = try Windows.`32`.Kernel.Lock.Token(
    ///     descriptor: handle,
    ///     range: .file,
    ///     kind: .exclusive
    /// )
    /// defer { token.release() }
    ///
    /// // ... use the locked file ...
    /// ```
    ///
    /// ## Lifetime
    ///
    /// - `release()` is the canonical way to release the lock
    /// - `deinit` releases the lock as a backstop (correctness should not depend on this)
    /// - Once released, the token cannot be used
    public struct Token: ~Copyable, Sendable {
        /// The descriptor whose lock this token represents.
        ///
        /// Token takes ownership via `consuming` in `init`. The caller
        /// transfers the descriptor to Token when acquiring a lock, and
        /// Token owns it until the token is destroyed — at which point
        /// the descriptor's own `deinit` closes the handle.
        @usableFromInline internal let descriptor: Windows.`32`.Kernel.Descriptor
        @usableFromInline internal let range: Windows.`32`.Kernel.Lock.Range
        @usableFromInline internal var isReleased: Bool

        /// Creates a lock token by acquiring a lock.
        ///
        /// Token takes ownership of `descriptor`. When the token is
        /// destroyed (explicitly via `release()` followed by scope exit,
        /// or implicitly via scope exit without an explicit release),
        /// the descriptor's `deinit` closes the handle.
        ///
        /// - Parameters:
        ///   - descriptor: The file handle. Ownership is transferred to the Token.
        ///   - range: The byte range to lock.
        ///   - kind: The lock kind (shared or exclusive).
        ///   - acquire: The acquisition strategy (default: `.wait`).
        /// - Throws: `Windows.\`32\`.Kernel.Lock.Error` if locking fails. On throw, the
        ///   consumed descriptor is destroyed by init cleanup (its deinit
        ///   closes the handle).
        public init(
            descriptor: consuming Windows.`32`.Kernel.Descriptor,
            range: Windows.`32`.Kernel.Lock.Range = .file,
            kind: Windows.`32`.Kernel.Lock.Kind,
            acquire: Windows.`32`.Kernel.Lock.Acquire = .wait
        ) throws(Windows.`32`.Kernel.Lock.Error) {
            // Acquire the lock first, borrowing the consuming parameter
            // without moving it. If acquireLock throws, the consuming
            // parameter is destroyed on init cleanup.
            try Self.acquireLock(
                descriptor: descriptor,
                range: range,
                kind: kind,
                acquire: acquire
            )
            // Successful acquisition — transfer ownership into Token.
            self.descriptor = descriptor
            self.range = range
            self.isReleased = false
        }

        deinit {
            // Backstop release: if the token was dropped without calling
            // release(), unlock via the owned descriptor. The descriptor's
            // own deinit runs immediately after and closes the handle.
            guard !isReleased else { return }
            try? Windows.`32`.Kernel.Lock.unlock(descriptor, range: range)
        }
    }
}

extension Windows.`32`.Kernel.Lock.Token {
    /// Releases the lock.
    ///
    /// On success, the token is marked released and subsequent calls
    /// are no-ops. On failure, the token remains valid for retry —
    /// the lock is preserved.
    ///
    /// The Token retains ownership of the descriptor after release;
    /// the handle is closed when the Token goes out of scope.
    ///
    /// - Throws: `Windows.\`32\`.Kernel.Lock.Error` if the unlock syscall fails.
    public mutating func release() throws(Windows.`32`.Kernel.Lock.Error) {
        guard !isReleased else { return }
        try Windows.`32`.Kernel.Lock.unlock(descriptor, range: range)
        isReleased = true
    }
}

// MARK: - Token Acquisition Logic

extension Windows.`32`.Kernel.Lock.Token {
    /// Acquires a lock using the specified strategy.
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

    /// Polls for a lock until the deadline expires.
    ///
    /// Uses exponential backoff starting at 1ms, capped at 100ms. Mirrors
    /// `ISO_9945.Kernel.Lock.Token.acquireWithDeadline` — Windows has no
    /// `LockFileEx` deadline parameter, so deadline acquisition polls the
    /// non-blocking form the same way the POSIX side does.
    private static func acquireWithDeadline(
        descriptor: borrowing Windows.`32`.Kernel.Descriptor,
        range: Windows.`32`.Kernel.Lock.Range,
        kind: Windows.`32`.Kernel.Lock.Kind,
        deadline: Clock.Continuous.Instant
    ) throws(Windows.`32`.Kernel.Lock.Error) {
        var backoff: Duration = .milliseconds(1)
        let maxBackoff: Duration = .milliseconds(100)

        while true {
            // Check deadline first
            let now = Clock.Continuous.now
            if now >= deadline {
                throw .timedOut
            }

            // Try to acquire
            do throws(Windows.`32`.Kernel.Lock.Error) {
                try Windows.`32`.Kernel.Lock.Immediate.lock(descriptor, range: range, kind: kind)
                // Critical: re-check deadline after acquisition
                // If deadline passed, unlock and throw to maintain invariant:
                // "success means lock was acquired before deadline"
                if Clock.Continuous.now >= deadline {
                    // If the compensating unlock fails, the lock is still
                    // held: surface that failure rather than reporting a
                    // timeout the caller would read as "never acquired".
                    try Windows.`32`.Kernel.Lock.unlock(descriptor, range: range)
                    throw Windows.`32`.Kernel.Lock.Error.timedOut
                }
                return
            } catch {
                switch error {
                case .contention:
                    break  // Lock held, continue polling
                default:
                    throw error
                }
            }

            // Calculate sleep time (don't overshoot deadline)
            let remaining = deadline - Clock.Continuous.now
            if remaining <= .zero {
                throw .timedOut
            }

            let sleepDuration = min(backoff, remaining)
            sleep(sleepDuration)

            // Exponential backoff with cap
            backoff = min(backoff * 2, maxBackoff)
        }
    }

    /// Platform-specific sleep without Foundation dependency.
    private static func sleep(_ duration: Duration) {
        #if os(Windows)
            let (seconds, attoseconds) = duration.components
            let milliseconds = UInt64(seconds) * 1000 + UInt64(attoseconds) / 1_000_000_000_000_000
            unsafe Sleep(DWORD(milliseconds))
        #endif
    }
}
