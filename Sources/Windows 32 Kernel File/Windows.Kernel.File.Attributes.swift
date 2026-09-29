#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.File {

        public struct Attributes: OptionSet, Sendable {
            public let rawValue: DWORD

            public init(rawValue: DWORD) {
                self.rawValue = rawValue
            }
        }
    }

    extension Windows.`32`.Kernel.File.Attributes {

        public static let readOnly = Self(rawValue: DWORD(FILE_ATTRIBUTE_READONLY))

        public static let hidden = Self(rawValue: DWORD(FILE_ATTRIBUTE_HIDDEN))

        public static let system = Self(rawValue: DWORD(FILE_ATTRIBUTE_SYSTEM))

        public static let directory = Self(rawValue: DWORD(FILE_ATTRIBUTE_DIRECTORY))

        public static let archive = Self(rawValue: DWORD(FILE_ATTRIBUTE_ARCHIVE))

        public static let device = Self(rawValue: DWORD(FILE_ATTRIBUTE_DEVICE))

        public static let normal = Self(rawValue: DWORD(FILE_ATTRIBUTE_NORMAL))

        public static let temporary = Self(rawValue: DWORD(FILE_ATTRIBUTE_TEMPORARY))

        public static let sparseFile = Self(rawValue: DWORD(FILE_ATTRIBUTE_SPARSE_FILE))

        public static let reparsePoint = Self(rawValue: DWORD(FILE_ATTRIBUTE_REPARSE_POINT))

        public static let compressed = Self(rawValue: DWORD(FILE_ATTRIBUTE_COMPRESSED))

        public static let offline = Self(rawValue: DWORD(FILE_ATTRIBUTE_OFFLINE))

        public static let notContentIndexed = Self(
            rawValue: DWORD(FILE_ATTRIBUTE_NOT_CONTENT_INDEXED)
        )

        public static let encrypted = Self(rawValue: DWORD(FILE_ATTRIBUTE_ENCRYPTED))
    }

    extension Windows.`32`.Kernel.File {

        @inlinable
        @discardableResult
        public static func setAttributes(
            path: UnsafePointer<WCHAR>,
            attributes: Attributes
        ) -> Bool {
            SetFileAttributesW(path, attributes.rawValue)
        }

        public static func setAttributes(
            path: UnsafePointer<WCHAR>,
            to attributes: Attributes
        ) throws(Windows.`32`.Kernel.File.Attributes.Error) {
            guard SetFileAttributesW(path, attributes.rawValue) else {
                throw .platform(
                    Error::Error(code: Error::Error.captureLastError())
                )
            }
        }

        public static func setReadOnly(
            path: UnsafePointer<WCHAR>,
            _ readOnly: Bool
        ) -> Bool {
            let current = GetFileAttributesW(path)
            guard current != INVALID_FILE_ATTRIBUTES else {
                return false
            }

            var newAttributes = current
            if readOnly {
                newAttributes |= DWORD(FILE_ATTRIBUTE_READONLY)
            } else {
                newAttributes &= ~DWORD(FILE_ATTRIBUTE_READONLY)
            }

            return SetFileAttributesW(path, newAttributes)
        }

        public static func setHidden(
            path: UnsafePointer<WCHAR>,
            _ hidden: Bool
        ) -> Bool {
            let current = GetFileAttributesW(path)
            guard current != INVALID_FILE_ATTRIBUTES else {
                return false
            }

            var newAttributes = current
            if hidden {
                newAttributes |= DWORD(FILE_ATTRIBUTE_HIDDEN)
            } else {
                newAttributes &= ~DWORD(FILE_ATTRIBUTE_HIDDEN)
            }

            return SetFileAttributesW(path, newAttributes)
        }
    }

    extension Windows.`32`.Kernel.File {

        public static func getAttributes(
            path: UnsafePointer<WCHAR>
        ) -> Attributes? {
            let result = GetFileAttributesW(path)
            guard result != INVALID_FILE_ATTRIBUTES else {
                return nil
            }
            return Attributes(rawValue: result)
        }
    }

    extension Windows.`32`.Kernel.File.Attributes {

        public enum Error: Swift.Error, Sendable, Equatable {

            case path(Path)

            case permission(Permission)

            case io(IO)

            case platform(Error::Error)
        }
    }

    extension Windows.`32`.Kernel.File.Attributes.Error {

        public enum Path: Swift.Error, Sendable, Equatable {
            case notFound
            case tooLong
            case loop
        }

        public enum Permission: Swift.Error, Sendable, Equatable {
            case denied
            case notPermitted
            case readOnlyFilesystem
        }

        public enum IO: Swift.Error, Sendable, Equatable {
            case hardware
        }
    }

    extension Windows.`32`.Kernel.File.Attributes.Error: CustomStringConvertible {
        public var description: Swift.String {
            switch self {
            case .path(let pathError):
                return "file attributes path error: \(pathError)"

            case .permission(let permError):
                return "file attributes permission error: \(permError)"

            case .io(let ioError):
                return "file attributes I/O error: \(ioError)"

            case .platform(let e):
                return "file attributes error: \(e)"
            }
        }
    }

#endif
