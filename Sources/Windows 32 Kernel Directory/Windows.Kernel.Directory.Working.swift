#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.Directory.Working {

        public static func get(
            into buffer: UnsafeMutableBufferPointer<UInt16>
        ) throws(Windows.`32`.Kernel.Directory.Working.Error) -> Int {
            let wbuffer = UnsafeMutableRawPointer(buffer.baseAddress!).assumingMemoryBound(
                to: WCHAR.self
            )
            let result = GetCurrentDirectoryW(DWORD(buffer.count), wbuffer)

            guard result != 0 else {
                throw .current()
            }

            if result > buffer.count {
                throw .platform(
                    Error.Error(code: .win32(DWORD(ERROR_INSUFFICIENT_BUFFER)))
                )
            }

            return Int(result)
        }

        public static func get() throws(Windows.`32`.Kernel.Directory.Working.Error) -> [UInt16] {

            let requiredSize = GetCurrentDirectoryW(0, nil)
            guard requiredSize > 0 else {
                throw .current()
            }

            var buffer = [UInt16](repeating: 0, count: Int(requiredSize))

            let written = GetCurrentDirectoryW(requiredSize, &buffer)
            guard written > 0, written < requiredSize else {
                throw .current()
            }

            return Array(buffer.prefix(Int(written)))
        }

        public static func set(
            path: borrowing Path
        ) throws(Windows.`32`.Kernel.Directory.Working.Error) {
            try unsafe path.view.withUnsafePointer {
                ptr throws(Windows.`32`.Kernel.Directory.Working.Error) in
                try set(unsafePath: ptr)
            }
        }

        public static func set(
            unsafePath: UnsafePointer<Path.Char>
        ) throws(Windows.`32`.Kernel.Directory.Working.Error) {
            let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)
            guard SetCurrentDirectoryW(wpath) else {
                throw .current()
            }
        }
    }

    extension Windows.`32`.Kernel.Directory.Working.Error {

        @usableFromInline
        internal static func current() -> Self {
            Self(code: Error.Error.captureLastError())
        }
    }

#endif
