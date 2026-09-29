#if os(Windows)
    internal import WinSDK
#endif

extension Windows.`32`.Kernel {

    public enum Close: Sendable {}
}

extension Windows.`32`.Kernel.Close {

    public static func close(_ descriptor: consuming Windows.`32`.Kernel.Descriptor) throws(Error) {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        let raw = descriptor._raw

        descriptor._raw = ~0

        #if os(Windows)
            guard let pointer = UnsafeMutableRawPointer(bitPattern: raw) else {
                throw .handle(.invalid)
            }
            guard unsafe CloseHandle(pointer) else {
                throw .platform(Error::Error(code: .win32(GetLastError())))
            }
        #endif
    }
}
