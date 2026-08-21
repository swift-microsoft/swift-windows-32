#if os(Windows)
    public import Pair_Primitives
    internal import WinSDK

    extension Windows.`32`.Kernel.File {

        public enum Find: Sendable {}
    }

    extension Windows.`32`.Kernel.File.Find {

        public struct Handle: ~Copyable, @unchecked Sendable {
            package var _raw: UnsafeMutableRawPointer

            package init(_raw: UnsafeMutableRawPointer) {
                self._raw = _raw
            }

            deinit {
                _ = unsafe FindClose(_raw)
            }
        }
    }

    extension Windows.`32`.Kernel.File.Find {

        public struct Entry: Sendable {

            public let name: Swift.String

            internal let attributes: DWORD
        }
    }

    extension Windows.`32`.Kernel.File.Find.Entry {

        public var isDirectory: Bool {
            (attributes & DWORD(FILE_ATTRIBUTE_DIRECTORY)) != 0
        }

        public var isReparsePoint: Bool {
            (attributes & DWORD(FILE_ATTRIBUTE_REPARSE_POINT)) != 0
        }
    }

    extension Windows.`32`.Kernel.File.Find {

        public enum Error: Swift.Error, Sendable, Hashable {

            case accessDenied

            case notFound

            case notDirectory

            case tooManyOpenFiles

            case nameTooLong

            case io

            internal init(lastError: DWORD) {
                switch lastError {
                case DWORD(ERROR_ACCESS_DENIED), DWORD(ERROR_SHARING_VIOLATION):
                    self = .accessDenied

                case DWORD(ERROR_FILE_NOT_FOUND), DWORD(ERROR_PATH_NOT_FOUND),
                    DWORD(ERROR_INVALID_NAME):
                    self = .notFound

                case DWORD(ERROR_DIRECTORY):
                    self = .notDirectory

                case DWORD(ERROR_TOO_MANY_OPEN_FILES):
                    self = .tooManyOpenFiles

                case DWORD(ERROR_FILENAME_EXCED_RANGE):
                    self = .nameTooLong

                default:
                    self = .io
                }
            }
        }
    }

    extension Windows.`32`.Kernel.File.Find {

        public typealias First = Pair<Handle, Entry>
    }

    extension Windows.`32`.Kernel.File.Find {

        public static func first(path: Swift.String) throws(Error) -> First {
            var findData = WIN32_FIND_DATAW()
            let handle = unsafe withWideString(path) { wpath in
                unsafe FindFirstFileW(wpath, &findData)
            }
            guard let raw = handle, raw != INVALID_HANDLE_VALUE else {
                throw Error(lastError: GetLastError())
            }
            let entry = Entry(
                name: extractFileName(from: &findData),
                attributes: findData.dwFileAttributes
            )
            return First(Handle(_raw: raw), entry)
        }
    }

    extension Windows.`32`.Kernel.File.Find.Handle {

        public mutating func next() -> Windows.`32`.Kernel.File.Find.Entry? {
            var findData = WIN32_FIND_DATAW()
            guard unsafe FindNextFileW(_raw, &findData) else {
                return nil
            }
            return .init(
                name: extractFileName(from: &findData),
                attributes: findData.dwFileAttributes
            )
        }
    }

    extension Windows.`32`.Kernel.File {

        public static func pathExists(_ path: Swift.String) -> Bool {
            unsafe withWideString(path) { wpath in
                unsafe GetFileAttributesW(wpath) != INVALID_FILE_ATTRIBUTES
            }
        }
    }

    private func withWideString<R>(
        _ string: Swift.String,
        _ body: (UnsafePointer<WCHAR>) -> R
    ) -> R {
        var utf16 = Array(string.utf16)
        utf16.append(0)
        return unsafe utf16.withUnsafeBufferPointer { buffer in
            unsafe buffer.baseAddress!.withMemoryRebound(
                to: WCHAR.self,
                capacity: buffer.count
            ) { wcharPtr in
                body(wcharPtr)
            }
        }
    }

    private func extractFileName(from findData: inout WIN32_FIND_DATAW) -> Swift.String {
        unsafe withUnsafePointer(to: &findData.cFileName) { ptr in
            unsafe ptr.withMemoryRebound(to: WCHAR.self, capacity: 260) { wcharPtr in
                var length = 0
                while length < 260, unsafe wcharPtr[length] != 0 {
                    length += 1
                }
                let buffer = unsafe UnsafeBufferPointer(start: wcharPtr, count: length)
                return unsafe Swift.String(decoding: buffer, as: UTF16.self)
            }
        }
    }

#endif
