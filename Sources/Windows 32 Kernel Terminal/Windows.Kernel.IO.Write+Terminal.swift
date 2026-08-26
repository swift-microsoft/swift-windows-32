#if os(Windows)
    public import Terminal
    public import WinSDK

    extension Windows.`32`.Kernel.IO.Write {

        public static func write(
            _ stream: Terminal.Stream,
            from buffer: UnsafeRawBufferPointer
        ) throws(Error) -> Int {
            guard buffer.baseAddress != nil else {
                return 0
            }
            let stdHandleId: DWORD
            switch stream {
            case .stdin: stdHandleId = STD_INPUT_HANDLE
            case .stdout: stdHandleId = STD_OUTPUT_HANDLE
            case .stderr: stdHandleId = STD_ERROR_HANDLE
            }
            guard let stdHandle = GetStdHandle(stdHandleId),
                stdHandle != INVALID_HANDLE_VALUE
            else {
                throw .handle(.invalid)
            }
            return try Self.write(UInt(bitPattern: stdHandle), from: buffer)
        }
    }

#endif
