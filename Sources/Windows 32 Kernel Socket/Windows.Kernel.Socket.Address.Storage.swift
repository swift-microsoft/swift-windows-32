#if os(Windows)
    internal import WinSDK

    extension Windows.`32`.Kernel.Socket.Address {

        public struct Storage: Sendable {
            internal var value: sockaddr_storage
            internal var length: Int32

            public init() {
                self.value = sockaddr_storage()
                self.length = Int32(MemoryLayout<sockaddr_storage>.size)
            }
        }
    }

    extension Windows.`32`.Kernel.Socket.Address.Storage {

        public var family: Windows.`32`.Kernel.Socket.Family {
            Windows.`32`.Kernel.Socket.Family(rawValue: Int32(value.ss_family))
        }

        internal func withUnsafeAddress<Result, Failure: Swift.Error>(
            _ body: (UnsafePointer<sockaddr>, Int32) throws(Failure) -> Result
        ) throws(Failure) -> Result {
            try unsafe Swift.withUnsafePointer(to: value) { pointer throws(Failure) in
                try unsafe pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { address throws(Failure) in
                    try unsafe body(address, length)
                }
            }
        }

        internal mutating func withUnsafeMutableAddress<Result, Failure: Swift.Error>(
            _ body: (UnsafeMutablePointer<sockaddr>, UnsafeMutablePointer<Int32>) throws(Failure) ->
                Result
        ) throws(Failure) -> Result {
            try unsafe Swift.withUnsafeMutablePointer(to: &value) { pointer throws(Failure) in
                try unsafe pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { address throws(Failure) in
                    try unsafe body(address, &length)
                }
            }
        }
    }
#endif
