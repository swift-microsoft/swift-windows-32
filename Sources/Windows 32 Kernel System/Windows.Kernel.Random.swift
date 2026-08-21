#if os(Windows)
    public import WinSDK
    public import Random_Primitives

    extension Windows.`32`.Kernel.Random {

        public static func bCryptGenRandom(
            _ buffer: UnsafeMutableRawBufferPointer
        ) throws(Random.Error) {
            guard let baseAddress = buffer.baseAddress, buffer.count > 0 else { return }

            let status = BCryptGenRandom(
                nil,
                baseAddress.assumingMemoryBound(to: UInt8.self),
                ULONG(buffer.count),
                ULONG(BCRYPT_USE_SYSTEM_PREFERRED_RNG)
            )

            if status != 0 {
                throw .systemError(status)
            }
        }

        @inlinable
        public static func bCryptGenRandom(
            _ span: inout MutableSpan<UInt8>
        ) throws(Random.Error) {
            try span.withUnsafeMutableBytes { buffer throws(Random.Error) in
                try bCryptGenRandom(buffer)
            }
        }

        public static func uint64() -> UInt64? {
            var value: UInt64 = 0
            do {
                try withUnsafeMutableBytes(of: &value) { buffer throws(Random.Error) in
                    try bCryptGenRandom(buffer)
                }
                return value
            } catch {
                return nil
            }
        }

        public static func uint32() -> UInt32? {
            var value: UInt32 = 0
            do {
                try withUnsafeMutableBytes(of: &value) { buffer throws(Random.Error) in
                    try bCryptGenRandom(buffer)
                }
                return value
            } catch {
                return nil
            }
        }
    }
#endif
