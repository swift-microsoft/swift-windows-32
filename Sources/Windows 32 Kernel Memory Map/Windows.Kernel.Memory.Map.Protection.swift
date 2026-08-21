#if os(Windows)
    public import Error_Primitives
    public import Memory_Primitives
    public import WinSDK

    extension Memory.Map.Protection {

        public static let read = Self(rawValue: 1)

        public static let write = Self(rawValue: 2)

        public static let execute = Self(rawValue: 4)

        public static let readWrite: Self = read | write

        public static let readExecute: Self = read | execute
    }

    extension Memory.Map.Protection {

        @usableFromInline
        internal var windowsVirtualProtect: DWORD {
            let hasRead = contains(.read)
            let hasWrite = contains(.write)
            let hasExecute = contains(.execute)

            if hasExecute && hasWrite {
                return DWORD(PAGE_EXECUTE_READWRITE)
            } else if hasExecute && hasRead {
                return DWORD(PAGE_EXECUTE_READ)
            } else if hasExecute {
                return DWORD(PAGE_EXECUTE)
            } else if hasWrite {
                return DWORD(PAGE_READWRITE)
            } else if hasRead {
                return DWORD(PAGE_READONLY)
            } else {
                return DWORD(PAGE_NOACCESS)
            }
        }

        @usableFromInline
        internal var windowsFileMapProtect: DWORD {
            let hasRead = contains(.read)
            let hasWrite = contains(.write)
            let hasExecute = contains(.execute)

            if hasExecute && hasWrite {
                return DWORD(PAGE_EXECUTE_READWRITE)
            } else if hasExecute && hasRead {
                return DWORD(PAGE_EXECUTE_READ)
            } else if hasWrite {
                return DWORD(PAGE_READWRITE)
            } else {
                return DWORD(PAGE_READONLY)
            }
        }

        @usableFromInline
        internal var windowsMapViewAccess: DWORD {
            let hasRead = contains(.read)
            let hasWrite = contains(.write)
            let hasExecute = contains(.execute)

            var access: DWORD = 0
            if hasWrite {
                access = DWORD(FILE_MAP_WRITE)
            } else if hasRead {
                access = DWORD(FILE_MAP_READ)
            }
            if hasExecute {
                access |= DWORD(FILE_MAP_EXECUTE)
            }
            return access
        }

        @usableFromInline
        internal var windowsFileMapProtectCopyOnWrite: DWORD {
            contains(.execute) ? DWORD(PAGE_EXECUTE_WRITECOPY) : DWORD(PAGE_WRITECOPY)
        }

        @usableFromInline
        internal var windowsMapViewAccessCopyOnWrite: DWORD {
            var access = DWORD(FILE_MAP_COPY)
            if contains(.execute) {
                access |= DWORD(FILE_MAP_EXECUTE)
            }
            return access
        }
    }

#endif
