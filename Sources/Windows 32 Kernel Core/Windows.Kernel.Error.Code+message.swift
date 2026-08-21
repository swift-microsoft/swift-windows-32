#if os(Windows)
    public import Error_Primitives
    internal import WinSDK

    extension Error_Primitives.Error.Code {

        public var win32Message: Swift.String? {
            switch self {
            case .posix:
                return nil

            case .win32(let rawValue):
                let flags: DWORD =
                    DWORD(
                        FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM
                            | FORMAT_MESSAGE_IGNORE_INSERTS
                    )

                var buffer: LPWSTR? = nil

                let langNeutralSublangDefault: DWORD = 0x0400

                let length: DWORD = withUnsafeMutablePointer(to: &buffer) { bufferPtr in
                    bufferPtr.withMemoryRebound(to: WCHAR.self, capacity: 1) { widePtr in
                        FormatMessageW(
                            flags,
                            nil,
                            rawValue,
                            langNeutralSublangDefault,
                            widePtr,
                            0,
                            nil
                        )
                    }
                }

                guard length > 0, let buffer else { return nil }
                defer { _ = LocalFree(buffer) }

                let u16 = UnsafeBufferPointer(start: buffer, count: Swift.Int(length))
                var message = Swift.String(decoding: u16, as: UTF16.self)

                while let last = message.unicodeScalars.last,
                    last == "\r" || last == "\n" || last == " " || last == "\t"
                {
                    message.unicodeScalars.removeLast()
                }
                return message
            }
        }
    }
#endif
