#if os(Windows)
    internal import WinSDK

    extension Windows.`32`.Kernel.Socket.Error {

        public enum Disposition: Sendable, Equatable {

            case wouldBlock

            case pending

            case connectionReset
        }

        public var disposition: Disposition? {
            switch code {
            case .win32(DWORD(WSAEWOULDBLOCK)):
                return .wouldBlock

            case .win32(DWORD(WSAEINPROGRESS)), .win32(DWORD(WSAEALREADY)):
                return .pending

            case .win32(DWORD(WSAECONNRESET)):
                return .connectionReset

            default:
                return nil
            }
        }
    }
#endif
