#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.File.Open.Options {

        public static let create = Self(rawValue: 1 << 0)

        public static let truncate = Self(rawValue: 1 << 1)

        public static let append = Self(rawValue: 1 << 2)

        public static let exclusive = Self(rawValue: 1 << 3)

        public static let execClose = Self(rawValue: 1 << 4)

        public static let nonBlocking = Self(rawValue: 1 << 5)

        public static let noFollow = Self(rawValue: 1 << 6)

        public static let direct = Self(rawValue: 1 << 7)
    }

    extension Windows.`32`.Kernel.File.Open.Options {

        package var windowsCreationDisposition: DWORD {
            let hasCreate = contains(.create)
            let hasExclusive = contains(.exclusive)
            let hasTruncate = contains(.truncate)

            if hasCreate && hasExclusive {

                return DWORD(CREATE_NEW)
            } else if hasCreate && hasTruncate {

                return DWORD(CREATE_ALWAYS)
            } else if hasCreate {

                return DWORD(OPEN_ALWAYS)
            } else if hasTruncate {

                return DWORD(TRUNCATE_EXISTING)
            } else {

                return DWORD(OPEN_EXISTING)
            }
        }

        package var windowsFlagsAndAttributes: DWORD {
            var flags: DWORD = DWORD(FILE_ATTRIBUTE_NORMAL)

            if contains(.direct) {
                flags |= DWORD(FILE_FLAG_NO_BUFFERING)
                flags |= DWORD(FILE_FLAG_WRITE_THROUGH)
            }

            if contains(.noFollow) {
                flags |= DWORD(FILE_FLAG_OPEN_REPARSE_POINT)
            }

            return flags
        }

        @usableFromInline
        internal var windowsFlagsAndAttributesOverlapped: DWORD {
            windowsFlagsAndAttributes | DWORD(FILE_FLAG_OVERLAPPED)
        }
    }

    extension Windows.`32`.Kernel.File.Open.Options {

        public static let overlapped = Self(rawValue: 1 << 16)

        public static let backupSemantics = Self(rawValue: 1 << 17)

        public static let deleteOnClose = Self(rawValue: 1 << 18)
    }

    extension Windows.`32`.Kernel.File.Open.Options {

        package var windowsFlagsAndAttributesFull: DWORD {
            var flags = windowsFlagsAndAttributes

            if contains(.overlapped) {
                flags |= DWORD(FILE_FLAG_OVERLAPPED)
            }

            if contains(.backupSemantics) {
                flags |= DWORD(FILE_FLAG_BACKUP_SEMANTICS)
            }

            if contains(.deleteOnClose) {
                flags |= DWORD(FILE_FLAG_DELETE_ON_CLOSE)
            }

            return flags
        }
    }

#endif
