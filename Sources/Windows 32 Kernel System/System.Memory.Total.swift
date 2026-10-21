public import Cardinal
public import System_Primitives

#if os(Windows)
    internal import WinSDK

    extension System {

        public static var memoryCapacity: Cardinal {
            var status = MEMORYSTATUSEX()
            status.dwLength = DWORD(MemoryLayout<MEMORYSTATUSEX>.size)
            guard GlobalMemoryStatusEx(&status) else { return Cardinal(UInt(0)) }
            guard let bytes = UInt(exactly: status.ullTotalPhys) else {
                preconditionFailure("Memory capacity is not representable as UInt")
            }
            return Cardinal(bytes)
        }
    }

#endif
