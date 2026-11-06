import Memory

#if os(Windows)
    internal import WinSDK

    extension Memory.Physical {

        /// The installed memory in bytes, `GlobalMemoryStatusEx`'s `ullTotalPhys`.
        /// A failed call reports zero.
        public static var capacity: Memory.Capacity {
            var status = MEMORYSTATUSEX()
            status.dwLength = DWORD(MemoryLayout<MEMORYSTATUSEX>.size)
            guard GlobalMemoryStatusEx(&status) else {
                return Memory.Capacity(_unchecked: Cardinal(0 as UInt))
            }
            guard let bytes = UInt(exactly: status.ullTotalPhys) else {
                preconditionFailure("Memory capacity is not representable as UInt")
            }
            return Memory.Capacity(_unchecked: Cardinal(bytes))
        }
    }

#endif
