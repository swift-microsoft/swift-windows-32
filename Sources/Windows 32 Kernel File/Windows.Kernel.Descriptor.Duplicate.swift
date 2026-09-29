#if os(Windows)
    @_spi(Syscall) import Windows_32_Kernel_Core
    public import WinSDK

    extension Windows.`32`.Kernel.Descriptor.Duplicate {

        package static func duplicate(_ handle: UInt) throws(Error) -> UInt {
            let currentProcess = GetCurrentProcess()
            var newHandle: HANDLE? = nil

            let success = DuplicateHandle(
                currentProcess,
                UnsafeMutableRawPointer(bitPattern: handle)!,
                currentProcess,
                &newHandle,
                0,
                false,
                DWORD(DUPLICATE_SAME_ACCESS)
            )

            guard success, let newHandle else {
                throw .current()
            }

            return UInt(bitPattern: newHandle)
        }
    }

    extension Windows.`32`.Kernel.Descriptor.Duplicate {

        public static func duplicate(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor
        ) throws(Error) -> Windows.`32`.Kernel.Descriptor {
            guard descriptor.isValid else {
                throw .handle(.invalid)
            }
            let newHandle = try duplicate(descriptor._rawValue)
            return Windows.`32`.Kernel.Descriptor(_rawValue: newHandle)
        }
    }

    extension Windows.`32`.Kernel.Descriptor.Duplicate.Error {

        @usableFromInline
        internal static func current() -> Self {
            let code = Error::Error.captureLastError()
            if let e = Windows.`32`.Kernel.Descriptor.Validity.Error(code: code) {
                return .handle(e)
            }
            return .platform(Error::Error(code: code))
        }
    }

#endif
