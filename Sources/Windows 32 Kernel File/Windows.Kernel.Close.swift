#if os(Windows)
    internal import WinSDK
#endif

extension Windows.`32`.Kernel.Close {

    internal static func close(_ handle: UInt) -> Bool {
        #if os(Windows)
            guard let pointer = UnsafeMutableRawPointer(bitPattern: handle) else {
                return false
            }
            return CloseHandle(pointer)
        #else
            return false
        #endif
    }
}
