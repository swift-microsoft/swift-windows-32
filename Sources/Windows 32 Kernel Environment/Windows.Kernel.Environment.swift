#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.Environment {

        public static func get(
            name: UnsafePointer<WCHAR>,
            into buffer: UnsafeMutableBufferPointer<UInt16>
        ) throws(Windows.`32`.Kernel.Environment.Error) -> Int {
            let wbuffer = UnsafeMutableRawPointer(buffer.baseAddress!).assumingMemoryBound(
                to: WCHAR.self
            )
            let result = GetEnvironmentVariableW(name, wbuffer, DWORD(buffer.count))

            if result == 0 {
                throw .current()
            }

            if result > buffer.count {
                throw .platform(
                    Error::Error(code: .win32(DWORD(ERROR_INSUFFICIENT_BUFFER)))
                )
            }

            return Int(result)
        }

        public static func get(
            name: UnsafePointer<WCHAR>
        ) -> [UInt16]? {

            let requiredSize = GetEnvironmentVariableW(name, nil, 0)
            if requiredSize == 0 {
                return nil
            }

            var buffer = [UInt16](repeating: 0, count: Int(requiredSize))
            let result = buffer.withUnsafeMutableBufferPointer { bufferPtr in
                let wbuffer = UnsafeMutableRawPointer(bufferPtr.baseAddress!).assumingMemoryBound(
                    to: WCHAR.self
                )
                return GetEnvironmentVariableW(name, wbuffer, DWORD(bufferPtr.count))
            }

            if result == 0 {
                return nil
            }

            return Array(buffer.prefix(Int(result)))
        }

        public static func set(
            name: UnsafePointer<WCHAR>,
            value: UnsafePointer<WCHAR>
        ) throws(Windows.`32`.Kernel.Environment.Error) {
            guard SetEnvironmentVariableW(name, value) else {
                throw .current()
            }
        }

        public static func unset(
            name: UnsafePointer<WCHAR>
        ) throws(Windows.`32`.Kernel.Environment.Error) {
            guard SetEnvironmentVariableW(name, nil) else {
                let error = GetLastError()
                if error == DWORD(ERROR_ENVVAR_NOT_FOUND) {
                    return
                }
                throw .current()
            }
        }
    }

    extension Windows.`32`.Kernel.Environment.Error {

        @usableFromInline
        internal static func current() -> Self {
            Self(code: Error::Error.captureLastError())
        }
    }

#endif
