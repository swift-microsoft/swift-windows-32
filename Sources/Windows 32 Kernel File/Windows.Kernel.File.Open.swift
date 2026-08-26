#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.File.Open {

        @inlinable
        public static func open(
            path: borrowing Path,
            mode: Windows.`32`.Kernel.File.Open.Mode,
            options: Windows.`32`.Kernel.File.Open.Options,
            permissions: Windows.`32`.Kernel.File.Permissions = .standard
        ) throws(Windows.`32`.Kernel.File.Open.Error) -> Windows.`32`.Kernel.Descriptor {
            try unsafe path.view.withUnsafePointer {
                ptr throws(Windows.`32`.Kernel.File.Open.Error) in
                try open(
                    unsafePath: ptr,
                    mode: mode,
                    options: options,
                    permissions: permissions
                )
            }
        }

        public static func open(
            unsafePath: UnsafePointer<Path.Char>,
            mode: Windows.`32`.Kernel.File.Open.Mode,
            options: Windows.`32`.Kernel.File.Open.Options,
            permissions: Windows.`32`.Kernel.File.Permissions = .standard
        ) throws(Windows.`32`.Kernel.File.Open.Error) -> Windows.`32`.Kernel.Descriptor {
            var desiredAccess = mode.windowsDesiredAccess

            if options.contains(.append) && mode.write {
                desiredAccess &= ~DWORD(GENERIC_WRITE)
                desiredAccess |=
                    DWORD(FILE_APPEND_DATA) | DWORD(FILE_WRITE_ATTRIBUTES) | DWORD(SYNCHRONIZE)
            }
            let shareMode: DWORD = DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE)
            let creationDisposition = options.windowsCreationDisposition
            var flagsAndAttributes = options.windowsFlagsAndAttributesFull

            if (permissions & .ownerWrite) == .none && !mode.write {
                flagsAndAttributes |= DWORD(FILE_ATTRIBUTE_READONLY)
            }

            let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)

            let handle = CreateFileW(
                wpath,
                desiredAccess,
                shareMode,
                nil,
                creationDisposition,
                flagsAndAttributes,
                nil
            )

            guard handle != INVALID_HANDLE_VALUE else {
                throw .current()
            }

            return Windows.`32`.Kernel.Descriptor(_raw: UInt(bitPattern: handle))
        }
    }

    extension Windows.`32`.Kernel.File.Open.Error {

        @usableFromInline
        internal static func current() -> Self {
            Self(code: Error.Error.captureLastError())
        }
    }

#endif
