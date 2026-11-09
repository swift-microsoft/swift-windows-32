#if os(Windows)
    public import Error
    public import Memory
    public import WinSDK

    extension Memory.Allocation {

        public static func allocate(
            addr: Memory.Address? = nil,
            size: Int,
            protection: Memory.Map.Protection
        ) throws(Memory.Map.Error) -> Memory.Address {
            guard size > 0 else {
                throw .invalid(.length)
            }

            let result = unsafe VirtualAlloc(
                addr?.mutablePointer,
                SIZE_T(size),
                DWORD(MEM_COMMIT | MEM_RESERVE),
                protection.windowsVirtualProtect
            )

            guard let result else {
                throw .map(Error::Error.captureLastError())
            }

            return unsafe Memory.Address(result)
        }

        public static func free(
            addr: Memory.Address
        ) throws(Memory.Map.Error) {
            guard unsafe VirtualFree(addr.mutablePointer, 0, DWORD(MEM_RELEASE)) else {
                throw .unmap(Error::Error.captureLastError())
            }
        }

        public static func allocateAligned(
            size: Int,
            alignment: Int,
            protection: Memory.Map.Protection
        ) throws(Memory.Map.Error) -> Memory.Address {

            guard size > 0 else {
                throw .invalid(.length)
            }
            guard alignment > 0, alignment & (alignment - 1) == 0 else {
                throw .invalid(.alignment)
            }

            var info = SYSTEM_INFO()
            GetSystemInfo(&info)

            if alignment <= Int(info.dwAllocationGranularity) {
                return try allocate(size: size, protection: protection)
            }

            let (span, overflow) = size.addingReportingOverflow(alignment)
            guard !overflow else {
                throw .invalid(.length)
            }

            let mask = UInt(alignment) - 1
            for _ in 0..<16 {
                let reservation = unsafe VirtualAlloc(
                    nil,
                    SIZE_T(span),
                    DWORD(MEM_RESERVE),
                    DWORD(PAGE_NOACCESS)
                )
                guard let reservation else {
                    throw .map(Error::Error.captureLastError())
                }

                let aligned = (unsafe UInt(bitPattern: reservation) + mask) & ~mask
                _ = unsafe VirtualFree(reservation, 0, DWORD(MEM_RELEASE))

                let result = unsafe VirtualAlloc(
                    UnsafeMutableRawPointer(bitPattern: aligned),
                    SIZE_T(size),
                    DWORD(MEM_COMMIT | MEM_RESERVE),
                    protection.windowsVirtualProtect
                )
                if let result {
                    return unsafe Memory.Address(result)
                }
            }

            throw .map(Error::Error.captureLastError())
        }

        public static func systemPageSize() -> UInt {
            var sysInfo = SYSTEM_INFO()
            GetSystemInfo(&sysInfo)
            return UInt(sysInfo.dwPageSize)
        }

        public static var system: Memory.Allocation.Granularity {
            var sysInfo = SYSTEM_INFO()
            GetSystemInfo(&sysInfo)
            let granularity = Int(sysInfo.dwAllocationGranularity)

            do {
                return Memory.Allocation.Granularity(try Memory.Alignment(granularity))
            } catch {
                preconditionFailure("System allocation granularity is not a valid alignment")
            }
        }
    }

#endif
