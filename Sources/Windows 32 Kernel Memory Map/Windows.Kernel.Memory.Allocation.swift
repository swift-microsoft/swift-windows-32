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

            let pageSize = Int(systemPageSize())

            if alignment <= pageSize {
                return try allocate(size: size, protection: protection)
            }

            let extraSize = size + alignment - pageSize
            let baseAddr = try allocate(size: extraSize, protection: protection)

            let baseValue = Int(bitPattern: baseAddr.pointer)
            let alignedValue = (baseValue + alignment - 1) & ~(alignment - 1)

            if baseValue == alignedValue {
                return baseAddr
            }

            do throws(Memory.Map.Error) {
                try free(addr: baseAddr)
            } catch {

            }
            throw .invalid(.alignment)
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

            return Memory.Allocation.Granularity(try! Memory.Alignment(granularity))
        }
    }

#endif
