#if os(Windows)
    public import Error
    public import WinSDK

    extension Windows.`32`.Kernel.Socket {

        package static func accept(
            _ socket: UInt
        ) throws(Error) -> UInt {
            let clientSocket = WinSDK.accept(SOCKET(socket), nil, nil)
            guard clientSocket != INVALID_SOCKET else {
                throw .platform(Error.Error(code: captureLastSocketError()))
            }
            return UInt(clientSocket)
        }

        package static func accept(
            _ socket: UInt,
            address: UnsafeMutablePointer<sockaddr>,
            addressLength: UnsafeMutablePointer<Int32>
        ) throws(Error) -> UInt {
            let clientSocket = WinSDK.accept(SOCKET(socket), address, addressLength)
            guard clientSocket != INVALID_SOCKET else {
                throw .platform(Error.Error(code: captureLastSocketError()))
            }
            return UInt(clientSocket)
        }

        public static func accept(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor
        ) throws(Error) -> Windows.`32`.Kernel.Socket.Descriptor {
            let raw = try accept(socket._rawValue)
            return Windows.`32`.Kernel.Socket.Descriptor(_rawValue: raw)
        }

        package static func accept(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            address: UnsafeMutablePointer<sockaddr>,
            addressLength: UnsafeMutablePointer<Int32>
        ) throws(Error) -> Windows.`32`.Kernel.Socket.Descriptor {
            let raw = try accept(socket._rawValue, address: address, addressLength: addressLength)
            return Windows.`32`.Kernel.Socket.Descriptor(_rawValue: raw)
        }
    }

#endif
