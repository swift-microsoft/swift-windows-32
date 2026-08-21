#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.File.Flush {

        package static func flush(_ handle: UInt) throws(Windows.`32`.Kernel.File.Flush.Error) {
            guard FlushFileBuffers(UnsafeMutableRawPointer(bitPattern: handle)!) else {
                throw .current()
            }
        }
    }

    extension Windows.`32`.Kernel.File.Flush {

        public static func flush(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor
        ) throws(Windows.`32`.Kernel.File.Flush.Error) {
            guard descriptor.isValid else {
                throw .handle(.invalid)
            }
            try flush(descriptor._rawValue)
        }

        public static func flushData(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor
        ) throws(Windows.`32`.Kernel.File.Flush.Error) {
            try flush(descriptor)
        }
    }

    extension Windows.`32`.Kernel.File.Flush.Error {

        @usableFromInline
        internal static func current() -> Self {
            let code = Error_Primitives.Error.captureLastError()
            if let e = Windows.`32`.Kernel.Descriptor.Validity.Error(code: code) {
                return .handle(e)
            }
            return .platform(Error_Primitives.Error(code: code))
        }
    }

#endif
