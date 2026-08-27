#if os(Windows)
    public import Loader_Vocabulary
    public import WinSDK
    internal import String

    @usableFromInline
    internal func captureLastErrorMessage() -> Loader.Message {
        let errorCode = GetLastError()

        var buffer: LPWSTR?
        let length = withUnsafeMutablePointer(to: &buffer) { bufferSlot in
            unsafe FormatMessageW(
                DWORD(
                    FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM
                        | FORMAT_MESSAGE_IGNORE_INSERTS
                ),
                nil,
                errorCode,
                0,
                unsafe unsafeBitCast(bufferSlot, to: LPWSTR.self),
                0,
                nil
            )
        }

        defer {
            if let buffer {
                unsafe LocalFree(buffer)
            }
        }

        guard length > 0, let buffer else {
            return Loader.Message(ascii: "Win32 loader error (no message text available)")
        }

        var count = Int(length)
        while count > 0, unsafe (buffer[count - 1] == 0x000D || buffer[count - 1] == 0x000A) {
            count -= 1
        }
        let view = unsafe String.String.Borrowed(UnsafePointer(buffer), count: count)
        return unsafe Loader.Message(copying: view)
    }

    extension Windows.Loader {

        public enum ErrorCode {}
    }

    extension Windows.Loader.ErrorCode {

        package static let moduleNotFound: DWORD = DWORD(ERROR_MOD_NOT_FOUND)

        package static let procNotFound: DWORD = DWORD(ERROR_PROC_NOT_FOUND)

        package static let badExeFormat: DWORD = DWORD(ERROR_BAD_EXE_FORMAT)

        package static let badPathname: DWORD = DWORD(ERROR_BAD_PATHNAME)

        package static let accessDenied: DWORD = DWORD(ERROR_ACCESS_DENIED)

        package static let fileNotFound: DWORD = DWORD(ERROR_FILE_NOT_FOUND)

        package static let pathNotFound: DWORD = DWORD(ERROR_PATH_NOT_FOUND)
    }

#endif
