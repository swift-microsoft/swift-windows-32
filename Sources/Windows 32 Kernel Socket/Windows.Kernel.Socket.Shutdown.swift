#if os(Windows)
    public import Error
    public import WinSDK

    extension Windows.`32`.Kernel.Socket {

        public static func shutdown(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            how: Windows.`32`.Kernel.Socket.Shutdown.How
        ) throws(Windows.`32`.Kernel.Socket.Shutdown.Error) {
            try shutdown(socket._rawValue, how: how)
        }

        package static func shutdown(
            _ socket: UInt,
            how: Windows.`32`.Kernel.Socket.Shutdown.How
        ) throws(Windows.`32`.Kernel.Socket.Shutdown.Error) {
            let sdHow: Int32
            switch how {
            case .read:
                sdHow = SD_RECEIVE

            case .write:
                sdHow = SD_SEND

            case .both:
                sdHow = SD_BOTH
            }

            let result = WinSDK.shutdown(SOCKET(socket), sdHow)
            guard result == 0 else {
                throw .platform(Error::Error(code: captureLastSocketError()))
            }
        }
    }

    extension Windows.`32`.Kernel.Socket.Shutdown.How {

        public static var sdReceive: Int32 { SD_RECEIVE }

        public static var sdSend: Int32 { SD_SEND }

        public static var sdBoth: Int32 { SD_BOTH }
    }

#endif
