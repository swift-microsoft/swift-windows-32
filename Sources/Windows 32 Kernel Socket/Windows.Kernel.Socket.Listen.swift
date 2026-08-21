#if os(Windows)
    public import Error_Primitives
    public import WinSDK

    extension Windows.`32`.Kernel.Socket {

        public static func listen(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            backlog: Windows.`32`.Kernel.Socket.Backlog
        ) throws(Error) {
            try listen(socket._rawValue, backlog: backlog)
        }

        package static func listen(
            _ socket: UInt,
            backlog: Windows.`32`.Kernel.Socket.Backlog
        ) throws(Error) {
            let result = WinSDK.listen(SOCKET(socket), backlog.rawValue)
            guard result == 0 else {
                throw .platform(Error_Primitives.Error(code: captureLastSocketError()))
            }
        }
    }

    extension Windows.`32`.Kernel.Socket.Backlog {

        public static var max: Windows.`32`.Kernel.Socket.Backlog {
            Windows.`32`.Kernel.Socket.Backlog(rawValue: SOMAXCONN)
        }
    }

#endif
