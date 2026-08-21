#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.Directory {

        @safe
        public final class Stream: @unchecked Sendable {
            private var handle: HANDLE?
            private var findData: WIN32_FIND_DATAW
            private var firstEntry: Bool

            fileprivate init(handle: HANDLE, findData: WIN32_FIND_DATAW) {
                self.handle = handle
                self.findData = findData
                self.firstEntry = true
            }

            deinit {
                if let h = handle {
                    _ = FindClose(h)
                }
            }
        }

        public static func open(
            at path: borrowing Path.Borrowed
        ) throws(Error) -> Stream {
            try unsafe path.withUnsafePointer { (ptr: UnsafePointer<Path.Char>) throws(Error) in
                var findData = WIN32_FIND_DATAW()
                let handle = Iterator._findFirst(unsafePath: ptr, findData: &findData)
                guard let handle, handle != INVALID_HANDLE_VALUE else {
                    throw Error(_windowsError: GetLastError())
                }
                return Stream(handle: handle, findData: findData)
            }
        }
    }

    extension Windows.`32`.Kernel.Directory.Stream {

        public func close() {
            if let h = handle {
                _ = FindClose(h)
                handle = nil
            }
        }

        public func next() throws(Windows.`32`.Kernel.Directory.Error) -> Windows.`32`.Kernel
            .Directory.Entry?
        {
            guard let h = handle else {
                throw .closed
            }
            if firstEntry {
                firstEntry = false
                return Windows.`32`.Kernel.Directory.Iterator._entry(from: findData)
            }
            guard FindNextFileW(h, &findData) else {
                let error = GetLastError()
                if error == DWORD(ERROR_NO_MORE_FILES) {
                    return nil
                }
                throw Windows.`32`.Kernel.Directory.Error(_windowsError: error)
            }
            return Windows.`32`.Kernel.Directory.Iterator._entry(from: findData)
        }
    }

#endif
