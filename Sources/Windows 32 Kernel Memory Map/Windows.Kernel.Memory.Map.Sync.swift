#if os(Windows)
    public import Error
    public import Memory
    public import WinSDK

    extension Memory.Map {

        public static func sync(
            _ address: Memory.Address,
            size: Int
        ) throws(Memory.Map.Error) {
            guard unsafe FlushViewOfFile(address.pointer, SIZE_T(size)) else {
                throw .sync(Error::Error.captureLastError())
            }
        }

        public static func sync(
            _ buffer: UnsafeRawBufferPointer
        ) throws(Memory.Map.Error) {
            guard let baseAddress = buffer.baseAddress else { return }
            guard unsafe FlushViewOfFile(baseAddress, SIZE_T(buffer.count)) else {
                throw .sync(Error::Error.captureLastError())
            }
        }

        public static func sync(
            _ buffer: UnsafeMutableRawBufferPointer
        ) throws(Memory.Map.Error) {
            guard let baseAddress = buffer.baseAddress else { return }
            guard unsafe FlushViewOfFile(baseAddress, SIZE_T(buffer.count)) else {
                throw .sync(Error::Error.captureLastError())
            }
        }
    }

#endif
