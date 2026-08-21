#if os(Windows)
    public import Loader_Primitives
    public import WinSDK

    extension Windows.Loader.Library {

        @unsafe
        public static func open(path: String) throws(Loader.Error) -> Loader.Library.Handle {
            let handle = path.withCString(encodedAs: UTF16.self) { pathPtr in
                LoadLibraryW(pathPtr)
            }

            guard let handle else {
                throw .open(captureLastErrorMessage())
            }

            return unsafe Loader.Library.Handle(rawValue: handle)
        }

        @unsafe
        package static func open(
            path: String,
            flags: DWORD
        ) throws(Loader.Error) -> Loader.Library.Handle {
            let handle = path.withCString(encodedAs: UTF16.self) { pathPtr in
                LoadLibraryExW(pathPtr, nil, flags)
            }

            guard let handle else {
                throw .open(captureLastErrorMessage())
            }

            return unsafe Loader.Library.Handle(rawValue: handle)
        }

        @unsafe
        public static func close(_ handle: Loader.Library.Handle) throws(Loader.Error) {
            let success = unsafe FreeLibrary(
                handle.rawValue.assumingMemoryBound(to: HINSTANCE__.self)
            )
            guard success else {
                throw .close(captureLastErrorMessage())
            }
        }

        @unsafe
        public static func getHandle(moduleName: String?) -> Loader.Library.Handle? {
            let handle: HMODULE?

            if let moduleName {
                handle = moduleName.withCString(encodedAs: UTF16.self) { namePtr in
                    GetModuleHandleW(namePtr)
                }
            } else {
                handle = GetModuleHandleW(nil)
            }

            guard let handle else {
                return nil
            }

            return unsafe Loader.Library.Handle(rawValue: handle)
        }
    }

    extension Windows.Loader.Library {

        public struct Flags: OptionSet, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Windows.Loader.Library.Flags {

        public static let dontResolveDllReferences = Self(
            rawValue: UInt32(DONT_RESOLVE_DLL_REFERENCES)
        )

        public static let loadIgnoreCodeAuthzLevel = Self(
            rawValue: UInt32(LOAD_IGNORE_CODE_AUTHZ_LEVEL)
        )

        public static let loadLibraryAsDatafile = Self(rawValue: UInt32(LOAD_LIBRARY_AS_DATAFILE))

        public static let loadLibraryAsDatafileExclusive = Self(
            rawValue: UInt32(LOAD_LIBRARY_AS_DATAFILE_EXCLUSIVE)
        )

        public static let loadLibraryAsImageResource = Self(
            rawValue: UInt32(LOAD_LIBRARY_AS_IMAGE_RESOURCE)
        )

        public static let loadWithAlteredSearchPath = Self(
            rawValue: UInt32(LOAD_WITH_ALTERED_SEARCH_PATH)
        )
    }

#endif
