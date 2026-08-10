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
    internal import CRT
    public import WinSDK

    extension Windows.`32`.Kernel.Process {
        /// Exit operations namespace.
        public enum Exit {}
    }

    extension Windows.`32`.Kernel.Process.Exit {
        /// Terminates the calling process immediately.
        ///
        /// - Parameter exitCode: Exit code for the process (`UINT`).
        ///
        /// ## Important
        ///
        /// - This function does NOT return.
        /// - Uses `ExitProcess()` — no CRT atexit handlers, no stdio flush.
        /// - Equivalent to POSIX `_exit()`.
        ///
        /// ## Exit Code Conventions
        ///
        /// - `0`: Success
        /// - `1-255`: Application-defined errors
        ///
        /// ## Usage
        ///
        /// ```swift
        /// Windows.`32`.Kernel.Process.Exit.now(0)  // success
        /// Windows.`32`.Kernel.Process.Exit.now(1)  // failure
        /// ```
        public static func now(_ exitCode: UInt32) -> Never {
            ExitProcess(exitCode)
        }

        /// Terminates the calling process normally.
        ///
        /// - Parameter status: Exit status code (`int`).
        ///
        /// ## Important
        ///
        /// - This function does NOT return.
        /// - Uses CRT `exit()`, NOT `ExitProcess()` — per the Microsoft
        ///   UCRT documentation, `exit` first calls, in LIFO order, the
        ///   functions registered by `atexit` and `_onexit`, then flushes
        ///   all stream buffers before terminating the process.
        /// - Equivalent to POSIX `exit(3)`.
        ///
        /// ## Exit Code Conventions
        ///
        /// - `0`: Success
        /// - `1-255`: Application-defined errors
        ///
        /// ## Usage
        ///
        /// ```swift
        /// Windows.`32`.Kernel.Process.Exit.normal(0)  // success
        /// Windows.`32`.Kernel.Process.Exit.normal(1)  // failure
        /// ```
        public static func normal(_ status: Int32) -> Never {
            CRT.exit(status)
        }
    }

#endif
