#if os(Windows)
    public import Error
    public import WinSDK

    extension Error::Error {

        @inlinable
        public static func captureLastError() -> Error::Error.Code {
            .win32(GetLastError())
        }
    }

    extension Error::Error.Code {

        public enum File {}

        public enum Access {}

        public enum Handle {}

        public enum Storage {}

        public enum IO {}

        public enum Directory {}

        public enum General {}
    }

    extension Error::Error.Code.File {

        public static let notFound: UInt32 = UInt32(ERROR_FILE_NOT_FOUND)

        public static let pathNotFound: UInt32 = UInt32(ERROR_PATH_NOT_FOUND)

        public static let exists: UInt32 = UInt32(ERROR_FILE_EXISTS)

        public static let alreadyExists: UInt32 = UInt32(ERROR_ALREADY_EXISTS)
    }

    extension Error::Error.Code.Access {

        public static let denied: UInt32 = UInt32(ERROR_ACCESS_DENIED)

        public static let sharingViolation: UInt32 = UInt32(ERROR_SHARING_VIOLATION)

        public static let lockViolation: UInt32 = UInt32(ERROR_LOCK_VIOLATION)
    }

    extension Error::Error.Code.Handle {

        public static let invalid: UInt32 = UInt32(ERROR_INVALID_HANDLE)
    }

    extension Error::Error.Code.Storage {

        public static let diskFull: UInt32 = UInt32(ERROR_DISK_FULL)

        public static let handleDiskFull: UInt32 = UInt32(ERROR_HANDLE_DISK_FULL)
    }

    extension Error::Error.Code.IO {

        public static let pending: UInt32 = UInt32(ERROR_IO_PENDING)

        public static let handleEOF: UInt32 = UInt32(ERROR_HANDLE_EOF)

        public static let brokenPipe: UInt32 = UInt32(ERROR_BROKEN_PIPE)

        public static let noData: UInt32 = UInt32(ERROR_NO_DATA)
    }

    extension Error::Error.Code.Directory {

        public static let notEmpty: UInt32 = UInt32(ERROR_DIR_NOT_EMPTY)

        public static let invalidName: UInt32 = UInt32(ERROR_DIRECTORY)
    }

    extension Error::Error.Code.General {

        public static let invalidParameter: UInt32 = UInt32(ERROR_INVALID_PARAMETER)

        public static let notEnoughMemory: UInt32 = UInt32(ERROR_NOT_ENOUGH_MEMORY)

        public static let success: UInt32 = UInt32(ERROR_SUCCESS)
    }

#endif
