#if os(Windows)
    public import Error
    public import Memory
    public import Space
    public import WinSDK

    extension Memory.Map {

        package static func map(
            fd handle: UInt,
            length: Memory.Address.Count,
            protection: Protection,
            flags: Options,
            offset: Windows.`32`.Kernel.File.Offset = .zero
        ) throws(Memory.Map.Error) -> Memory.Address {
            guard length.underlying.rawValue > 0 else {
                throw .invalid(.length)
            }

            let isPrivate = flags.isPrivate

            let fileMappingProtect =
                isPrivate
                ? protection.windowsFileMapProtectCopyOnWrite
                : protection.windowsFileMapProtect
            let mappingHandle = CreateFileMappingW(
                UnsafeMutableRawPointer(bitPattern: handle)!,
                nil,
                fileMappingProtect,
                DWORD((offset.underlying + Int64(length.underlying.rawValue)) >> 32),
                DWORD((offset.underlying + Int64(length.underlying.rawValue)) & 0xFFFF_FFFF),
                nil
            )

            guard let mappingHandle, mappingHandle != INVALID_HANDLE_VALUE else {
                throw .map(Error::Error.captureLastError())
            }

            let desiredAccess =
                isPrivate
                ? protection.windowsMapViewAccessCopyOnWrite
                : protection.windowsMapViewAccess
            let baseAddress = MapViewOfFile(
                mappingHandle,
                desiredAccess,
                DWORD(offset.underlying >> 32),
                DWORD(offset.underlying & 0xFFFF_FFFF),
                SIZE_T(length.underlying.rawValue)
            )

            let mapError = Error::Error.captureLastError()

            _ = CloseHandle(mappingHandle)

            guard let baseAddress else {
                throw .map(mapError)
            }

            return unsafe Memory.Address(baseAddress)
        }

        public static func map(
            fd: borrowing Windows.`32`.Kernel.Descriptor,
            length: Memory.Address.Count,
            protection: Protection,
            flags: Options,
            offset: Windows.`32`.Kernel.File.Offset = .zero
        ) throws(Memory.Map.Error) -> Memory.Address {
            try map(
                fd: fd._rawValue,
                length: length,
                protection: protection,
                flags: flags,
                offset: offset
            )
        }

        public static func mapAnonymous(
            addr: Memory.Address? = nil,
            length: Memory.Address.Count,
            protection: Protection
        ) throws(Memory.Map.Error) -> Memory.Address {
            guard length.underlying.rawValue > 0 else {
                throw .invalid(.length)
            }

            let allocationType = DWORD(MEM_COMMIT | MEM_RESERVE)
            let result = unsafe VirtualAlloc(
                addr?.mutablePointer,
                SIZE_T(length.underlying.rawValue),
                allocationType,
                protection.windowsVirtualProtect
            )

            guard let result else {
                throw .map(Error::Error.captureLastError())
            }

            return unsafe Memory.Address(result)
        }

        public static func unmap(
            addr: Memory.Address,
            length: Memory.Address.Count,
            isAnonymous: Bool = false
        ) throws(Memory.Map.Error) {
            let success: Bool
            if isAnonymous {
                success = unsafe VirtualFree(addr.mutablePointer, 0, DWORD(MEM_RELEASE))
            } else {
                success = unsafe UnmapViewOfFile(addr.pointer)
            }

            guard success else {
                throw .unmap(Error::Error.captureLastError())
            }
        }

        public static func sync(
            addr: Memory.Address,
            length: Memory.Address.Count
        ) throws(Memory.Map.Error) {
            guard unsafe FlushViewOfFile(addr.pointer, SIZE_T(length.underlying.rawValue)) else {
                throw .sync(Error::Error.captureLastError())
            }
        }

        public static func protect(
            addr: Memory.Address,
            length: Memory.Address.Count,
            protection: Protection
        ) throws(Memory.Map.Error) {
            var oldProtect: DWORD = 0
            guard
                unsafe VirtualProtect(
                    addr.mutablePointer,
                    SIZE_T(length.underlying.rawValue),
                    protection.windowsVirtualProtect,
                    &oldProtect
                )
            else {
                throw .protect(Error::Error.captureLastError())
            }
        }
    }

#endif
