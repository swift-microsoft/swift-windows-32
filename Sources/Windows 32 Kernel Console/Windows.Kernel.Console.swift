#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel {

        public enum Console {}
    }

    extension Windows.`32`.Kernel.Console {

        @inlinable
        package static func standardInput() -> HANDLE? {
            let handle = GetStdHandle(DWORD(STD_INPUT_HANDLE))
            return handle == INVALID_HANDLE_VALUE ? nil : handle
        }

        @inlinable
        package static func standardOutput() -> HANDLE? {
            let handle = GetStdHandle(DWORD(STD_OUTPUT_HANDLE))
            return handle == INVALID_HANDLE_VALUE ? nil : handle
        }

        @inlinable
        package static func standardError() -> HANDLE? {
            let handle = GetStdHandle(DWORD(STD_ERROR_HANDLE))
            return handle == INVALID_HANDLE_VALUE ? nil : handle
        }

        @inlinable
        package static func isConsole(_ handle: HANDLE) -> Bool {
            var mode: DWORD = 0
            return GetConsoleMode(handle, &mode)
        }
    }

    extension Windows.`32`.Kernel.Console {

        public struct InputMode: OptionSet, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }

        public struct OutputMode: OptionSet, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Windows.`32`.Kernel.Console.InputMode {

        public static let enableLineInput = Self(rawValue: UInt32(ENABLE_LINE_INPUT))

        public static let enableEchoInput = Self(rawValue: UInt32(ENABLE_ECHO_INPUT))

        public static let enableProcessedInput = Self(rawValue: UInt32(ENABLE_PROCESSED_INPUT))

        public static let enableWindowInput = Self(rawValue: UInt32(ENABLE_WINDOW_INPUT))

        public static let enableMouseInput = Self(rawValue: UInt32(ENABLE_MOUSE_INPUT))

        public static let enableInsertMode = Self(rawValue: UInt32(ENABLE_INSERT_MODE))

        public static let enableQuickEditMode = Self(rawValue: UInt32(ENABLE_QUICK_EDIT_MODE))

        public static let enableVirtualTerminalInput = Self(
            rawValue: UInt32(ENABLE_VIRTUAL_TERMINAL_INPUT)
        )

        public static let `default`: Self = [
            .enableLineInput, .enableEchoInput, .enableProcessedInput,
        ]

        public static let raw: Self = []
    }

    extension Windows.`32`.Kernel.Console.OutputMode {

        public static let enableProcessedOutput = Self(rawValue: UInt32(ENABLE_PROCESSED_OUTPUT))

        public static let enableWrapAtEolOutput = Self(rawValue: UInt32(ENABLE_WRAP_AT_EOL_OUTPUT))

        public static let enableVirtualTerminalProcessing = Self(
            rawValue: UInt32(ENABLE_VIRTUAL_TERMINAL_PROCESSING)
        )

        public static let disableNewlineAutoReturn = Self(
            rawValue: UInt32(DISABLE_NEWLINE_AUTO_RETURN)
        )

        public static let `default`: Self = [.enableProcessedOutput, .enableWrapAtEolOutput]

        public static let ansi: Self = [
            .enableProcessedOutput, .enableWrapAtEolOutput, .enableVirtualTerminalProcessing,
        ]
    }

    extension Windows.`32`.Kernel.Console {

        @inlinable
        package static func getInputMode(_ handle: HANDLE) -> InputMode? {
            var mode: DWORD = 0
            guard GetConsoleMode(handle, &mode) else { return nil }
            return InputMode(rawValue: UInt32(mode))
        }

        @inlinable
        @discardableResult
        package static func setInputMode(_ handle: HANDLE, mode: InputMode) -> Bool {
            SetConsoleMode(handle, DWORD(mode.rawValue))
        }

        @inlinable
        package static func getOutputMode(_ handle: HANDLE) -> OutputMode? {
            var mode: DWORD = 0
            guard GetConsoleMode(handle, &mode) else { return nil }
            return OutputMode(rawValue: UInt32(mode))
        }

        @inlinable
        @discardableResult
        package static func setOutputMode(_ handle: HANDLE, mode: OutputMode) -> Bool {
            SetConsoleMode(handle, DWORD(mode.rawValue))
        }
    }

    extension Windows.`32`.Kernel.Console {

        @inlinable
        public static func read(
            _ handle: HANDLE,
            into buffer: UnsafeMutableBufferPointer<WCHAR>
        ) -> Int? {
            var charsRead: DWORD = 0
            guard ReadConsoleW(handle, buffer.baseAddress, DWORD(buffer.count), &charsRead, nil)
            else {
                return nil
            }
            return Int(charsRead)
        }

        @inlinable
        public static func write(
            _ handle: HANDLE,
            from buffer: UnsafeBufferPointer<WCHAR>
        ) -> Int? {
            var charsWritten: DWORD = 0
            guard WriteConsoleW(handle, buffer.baseAddress, DWORD(buffer.count), &charsWritten, nil)
            else {
                return nil
            }
            return Int(charsWritten)
        }

        @inlinable
        package static func write(_ handle: HANDLE, string: String) -> Int? {
            var utf16 = Array(string.utf16)
            return utf16.withUnsafeBufferPointer { buffer in
                let wcharBuffer = UnsafeBufferPointer<WCHAR>(
                    start: UnsafeRawPointer(buffer.baseAddress)?.assumingMemoryBound(
                        to: WCHAR.self
                    ),
                    count: buffer.count
                )
                return write(handle, from: wcharBuffer)
            }
        }
    }

    extension Windows.`32`.Kernel.Console {

        public struct ScreenBufferInfo {

            public let size: (width: Int, height: Int)

            public let cursorPosition: (x: Int, y: Int)

            package let attributes: WORD

            public let window: (left: Int, top: Int, right: Int, bottom: Int)

            public let maxWindowSize: (width: Int, height: Int)

            init(_ info: CONSOLE_SCREEN_BUFFER_INFO) {
                self.size = (Int(info.dwSize.X), Int(info.dwSize.Y))
                self.cursorPosition = (Int(info.dwCursorPosition.X), Int(info.dwCursorPosition.Y))
                self.attributes = info.wAttributes
                self.window = (
                    Int(info.srWindow.Left),
                    Int(info.srWindow.Top),
                    Int(info.srWindow.Right),
                    Int(info.srWindow.Bottom)
                )
                self.maxWindowSize = (
                    Int(info.dwMaximumWindowSize.X), Int(info.dwMaximumWindowSize.Y)
                )
            }
        }

        package static func getScreenBufferInfo(_ handle: HANDLE) -> ScreenBufferInfo? {
            var info = CONSOLE_SCREEN_BUFFER_INFO()
            guard GetConsoleScreenBufferInfo(handle, &info) else { return nil }
            return ScreenBufferInfo(info)
        }

        @inlinable
        @discardableResult
        package static func setCursorPosition(_ handle: HANDLE, x: Int, y: Int) -> Bool {
            let coord = COORD(X: SHORT(x), Y: SHORT(y))
            return SetConsoleCursorPosition(handle, coord)
        }
    }

#endif
