#if os(Windows)

    extension Error_Primitives.Error.Code {

        public enum Windows {}
    }

    extension Error_Primitives.Error.Code.Windows {

        @inlinable
        public static var ERROR_FILE_NOT_FOUND: Error_Primitives.Error.Code { .win32(2) }

        @inlinable
        public static var ERROR_PATH_NOT_FOUND: Error_Primitives.Error.Code { .win32(3) }

        @inlinable
        public static var ERROR_ACCESS_DENIED: Error_Primitives.Error.Code { .win32(5) }

        @inlinable
        public static var ERROR_SECTOR_NOT_FOUND: Error_Primitives.Error.Code { .win32(27) }

        @inlinable
        public static var ERROR_FILE_EXISTS: Error_Primitives.Error.Code { .win32(80) }

        @inlinable
        public static var ERROR_ALREADY_EXISTS: Error_Primitives.Error.Code { .win32(183) }

        @inlinable
        public static var ERROR_FILENAME_EXCED_RANGE: Error_Primitives.Error.Code { .win32(206) }

        @inlinable
        public static var ERROR_CANT_RESOLVE_FILENAME: Error_Primitives.Error.Code { .win32(1921) }
    }

    extension Error_Primitives.Error.Code.Windows {

        @inlinable
        public static var ERROR_NOT_SAME_DEVICE: Error_Primitives.Error.Code { .win32(17) }

        @inlinable
        public static var ERROR_DIR_NOT_EMPTY: Error_Primitives.Error.Code { .win32(145) }

        @inlinable
        public static var ERROR_DIRECTORY: Error_Primitives.Error.Code { .win32(267) }
    }

    extension Error_Primitives.Error.Code.Windows {

        @inlinable
        public static var ERROR_WRITE_PROTECT: Error_Primitives.Error.Code { .win32(19) }

        @inlinable
        public static var ERROR_SHARING_VIOLATION: Error_Primitives.Error.Code { .win32(32) }

        @inlinable
        public static var ERROR_LOCK_VIOLATION: Error_Primitives.Error.Code { .win32(33) }
    }

    extension Error_Primitives.Error.Code.Windows {

        @inlinable
        public static var ERROR_INVALID_DRIVE: Error_Primitives.Error.Code { .win32(15) }

        @inlinable
        public static var ERROR_INVALID_NAME: Error_Primitives.Error.Code { .win32(123) }

        @inlinable
        public static var ERROR_BAD_PATHNAME: Error_Primitives.Error.Code { .win32(161) }
    }

    extension Error_Primitives.Error.Code.Windows {

        @inlinable
        public static var ERROR_BAD_NETPATH: Error_Primitives.Error.Code { .win32(53) }

        @inlinable
        public static var ERROR_BAD_NET_NAME: Error_Primitives.Error.Code { .win32(67) }
    }

    extension Error_Primitives.Error.Code.Windows {

        @inlinable
        public static var ERROR_NOT_ENOUGH_MEMORY: Error_Primitives.Error.Code { .win32(8) }

        @inlinable
        public static var ERROR_DISK_FULL: Error_Primitives.Error.Code { .win32(112) }

        @inlinable
        public static var ERROR_TOO_MANY_OPEN_FILES: Error_Primitives.Error.Code { .win32(4) }
    }

    extension Error_Primitives.Error.Code.Windows {

        @inlinable
        public static var ERROR_INVALID_HANDLE: Error_Primitives.Error.Code { .win32(6) }
    }

    extension Error_Primitives.Error.Code.Windows {

        @inlinable
        public static var ERROR_HANDLE_EOF: Error_Primitives.Error.Code { .win32(38) }

        @inlinable
        public static var ERROR_BROKEN_PIPE: Error_Primitives.Error.Code { .win32(109) }

        @inlinable
        public static var ERROR_MORE_DATA: Error_Primitives.Error.Code { .win32(234) }

        @inlinable
        public static var ERROR_NO_DATA: Error_Primitives.Error.Code { .win32(232) }
    }

    extension Error_Primitives.Error.Code.Windows {

        @inlinable
        public static var ERROR_INVALID_PARAMETER: Error_Primitives.Error.Code { .win32(87) }

        @inlinable
        public static var ERROR_CALL_NOT_IMPLEMENTED: Error_Primitives.Error.Code { .win32(120) }

        @inlinable
        public static var ERROR_NOT_SUPPORTED: Error_Primitives.Error.Code { .win32(50) }
    }
#endif
