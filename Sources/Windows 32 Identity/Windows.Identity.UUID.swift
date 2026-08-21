#if os(Windows)
    internal import WinSDK
    public import Windows_32_Core

    extension Windows_32_Core.Windows {

        public enum Identity {}
    }

    extension Windows.Identity {

        public enum UUID {}
    }

    extension Windows.Identity.UUID {

        public typealias Bytes = (
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
        )

        public static func parse(_ string: String) -> Bytes? {
            var winUUID = WinSDK.UUID()
            let status = string.withCString { cString in

                cString.withMemoryRebound(to: UInt8.self, capacity: string.utf8.count + 1) {
                    rebound in
                    UuidFromStringA(RPC_CSTR(mutating: rebound), &winUUID)
                }
            }
            guard status == RPC_S_OK else { return nil }

            return (
                UInt8(truncatingIfNeeded: winUUID.Data1 >> 24),
                UInt8(truncatingIfNeeded: winUUID.Data1 >> 16),
                UInt8(truncatingIfNeeded: winUUID.Data1 >> 8),
                UInt8(truncatingIfNeeded: winUUID.Data1),
                UInt8(truncatingIfNeeded: winUUID.Data2 >> 8),
                UInt8(truncatingIfNeeded: winUUID.Data2),
                UInt8(truncatingIfNeeded: winUUID.Data3 >> 8),
                UInt8(truncatingIfNeeded: winUUID.Data3),
                winUUID.Data4.0, winUUID.Data4.1, winUUID.Data4.2, winUUID.Data4.3,
                winUUID.Data4.4, winUUID.Data4.5, winUUID.Data4.6, winUUID.Data4.7
            )
        }

        public static func unparse(_ bytes: Bytes, uppercase: Bool = false) -> String {

            var winUUID = WinSDK.UUID(
                Data1: (UInt32(bytes.0) << 24) | (UInt32(bytes.1) << 16) | (UInt32(bytes.2) << 8)
                    | UInt32(bytes.3),
                Data2: (UInt16(bytes.4) << 8) | UInt16(bytes.5),
                Data3: (UInt16(bytes.6) << 8) | UInt16(bytes.7),
                Data4: (
                    bytes.8, bytes.9, bytes.10, bytes.11,
                    bytes.12, bytes.13, bytes.14, bytes.15
                )
            )

            var stringPtr: RPC_CSTR? = nil
            let status = UuidToStringA(&winUUID, &stringPtr)
            guard status == RPC_S_OK, let ptr = stringPtr else {

                return formatManually(bytes, uppercase: uppercase)
            }

            defer { RpcStringFreeA(&stringPtr) }

            let result = String(cString: ptr)
            return uppercase ? result.uppercased() : result.lowercased()
        }

        private static func formatManually(_ bytes: Bytes, uppercase: Bool) -> String {
            let hexChars: [Character] =
                uppercase
                ? Array("0123456789ABCDEF")
                : Array("0123456789abcdef")

            func hex(_ byte: UInt8) -> (Character, Character) {
                (hexChars[Int(byte >> 4)], hexChars[Int(byte & 0x0F)])
            }

            var result = ""
            result.reserveCapacity(36)

            for i in 0..<4 {
                let byte = withUnsafeBytes(of: bytes) { $0[i] }
                let (h, l) = hex(byte)
                result.append(h)
                result.append(l)
            }
            result.append("-")

            for i in 4..<6 {
                let byte = withUnsafeBytes(of: bytes) { $0[i] }
                let (h, l) = hex(byte)
                result.append(h)
                result.append(l)
            }
            result.append("-")

            for i in 6..<8 {
                let byte = withUnsafeBytes(of: bytes) { $0[i] }
                let (h, l) = hex(byte)
                result.append(h)
                result.append(l)
            }
            result.append("-")

            for i in 8..<10 {
                let byte = withUnsafeBytes(of: bytes) { $0[i] }
                let (h, l) = hex(byte)
                result.append(h)
                result.append(l)
            }
            result.append("-")

            for i in 10..<16 {
                let byte = withUnsafeBytes(of: bytes) { $0[i] }
                let (h, l) = hex(byte)
                result.append(h)
                result.append(l)
            }

            return result
        }
    }
#endif
