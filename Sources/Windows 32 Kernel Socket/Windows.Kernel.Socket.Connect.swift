#if os(Windows)
    public import Error
    public import WinSDK

    extension Windows.`32`.Kernel.Socket {

        public enum Connect: Sendable {}

        package static func connect(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            address: UnsafePointer<sockaddr>,
            addressLength: Int32
        ) throws(Error) {
            try connect(socket._rawValue, address: address, addressLength: addressLength)
        }

        package static func connect(
            _ socket: UInt,
            address: UnsafePointer<sockaddr>,
            addressLength: Int32
        ) throws(Error) {
            let result = WinSDK.connect(SOCKET(socket), address, addressLength)
            guard result == 0 else {
                throw .platform(Error::Error(code: captureLastSocketError()))
            }
        }
    }

    extension Windows.`32`.Kernel.Socket.Connect {

        public static func start(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            address: Windows.`32`.Kernel.Socket.Address.Storage
        ) throws(Windows.`32`.Kernel.Socket.Error) -> Start {
            do throws(Windows.`32`.Kernel.Socket.Error) {
                try address.withUnsafeAddress { pointer, length in
                    try Windows.`32`.Kernel.Socket.connect(
                        socket._rawValue,
                        address: pointer,
                        addressLength: length
                    )
                }
                return .connected
            } catch  where error.disposition == .wouldBlock || error.disposition == .pending {
                return .pending
            }
        }

        public static func finish(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor
        ) throws(Windows.`32`.Kernel.Socket.Error) {
            let error = try Windows.`32`.Kernel.Socket.getError(socket)
            guard error == 0 else {
                throw Windows.`32`.Kernel.Socket.Error(
                    code: .win32(DWORD(UInt32(bitPattern: error)))
                )
            }
        }
    }

#endif
