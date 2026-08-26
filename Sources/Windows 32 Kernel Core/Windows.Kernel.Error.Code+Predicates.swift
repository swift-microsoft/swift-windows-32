#if os(Windows)

    extension Error.Error.Code {

        @inlinable
        public var isNotFound: Bool {
            self == .Windows.ERROR_FILE_NOT_FOUND
                || self == .Windows.ERROR_PATH_NOT_FOUND
        }

        @inlinable
        public var isPermissionDenied: Bool {
            self == .Windows.ERROR_ACCESS_DENIED
        }

        @inlinable
        public var isAccessDenied: Bool {
            isPermissionDenied
        }

        @inlinable
        public var isReadOnly: Bool {
            self == .Windows.ERROR_WRITE_PROTECT
        }

        @inlinable
        public var isNoSpace: Bool {
            self == .Windows.ERROR_DISK_FULL
        }

        @inlinable
        public var isNotDirectory: Bool {
            self == .Windows.ERROR_DIRECTORY
        }

        @inlinable
        public var isInvalidPath: Bool {
            self == .Windows.ERROR_INVALID_NAME
                || self == .Windows.ERROR_BAD_PATHNAME
                || self == .Windows.ERROR_INVALID_DRIVE
        }

        @inlinable
        public var isNetworkNotFound: Bool {
            self == .Windows.ERROR_BAD_NETPATH
                || self == .Windows.ERROR_BAD_NET_NAME
        }
    }

#endif
