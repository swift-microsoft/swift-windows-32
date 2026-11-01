#if os(Windows)
    internal import WinSDK

    extension Windows.`32`.Kernel {

        /// The running system's identification: the product, its version and the native architecture.
        public struct Name: Sendable, Hashable {

            /// Always `Windows`.
            public var system: Swift.String

            /// `major.minor.build` from `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion`.
            public var release: Swift.String

            /// The native processor architecture, `GetNativeSystemInfo`.
            public var machine: Swift.String

            public init(system: Swift.String, release: Swift.String, machine: Swift.String) {
                self.system = system
                self.release = release
                self.machine = machine
            }
        }
    }

    extension Windows.`32`.Kernel.Name {

        /// The running system's name, or `nil` when the registry holds no build number.
        public static var current: Self? {
            let key = "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion"
            guard let build = registryString(key, "CurrentBuildNumber") else { return nil }
            let release: Swift.String
            if let major = registryNumber(key, "CurrentMajorVersionNumber"),
                let minor = registryNumber(key, "CurrentMinorVersionNumber")
            {
                release = "\(major).\(minor).\(build)"
            } else {
                release = build
            }
            return Self(system: "Windows", release: release, machine: machine)
        }

        private static var machine: Swift.String {
            var info = SYSTEM_INFO()
            GetNativeSystemInfo(&info)
            switch Int32(info.wProcessorArchitecture) {
            case PROCESSOR_ARCHITECTURE_AMD64: return "x86_64"
            case PROCESSOR_ARCHITECTURE_ARM64: return "arm64"
            case PROCESSOR_ARCHITECTURE_INTEL: return "i386"
            case PROCESSOR_ARCHITECTURE_ARM: return "arm"
            default: return "unknown"
            }
        }

        private static func registryString(_ key: Swift.String, _ value: Swift.String) -> Swift.String? {
            var size: DWORD = 0
            let measured = unsafe key.withCString(encodedAs: UTF16.self) { key in
                unsafe value.withCString(encodedAs: UTF16.self) { value in
                    unsafe RegGetValueW(HKEY_LOCAL_MACHINE, key, value, DWORD(RRF_RT_REG_SZ), nil, nil, &size)
                }
            }
            guard measured == 0, size > 0 else { return nil }
            var buffer = [WCHAR](repeating: 0, count: Int(size) / MemoryLayout<WCHAR>.size + 1)
            let read = unsafe key.withCString(encodedAs: UTF16.self) { key in
                unsafe value.withCString(encodedAs: UTF16.self) { value in
                    unsafe buffer.withUnsafeMutableBytes { bytes in
                        unsafe RegGetValueW(
                            HKEY_LOCAL_MACHINE,
                            key,
                            value,
                            DWORD(RRF_RT_REG_SZ),
                            nil,
                            bytes.baseAddress,
                            &size
                        )
                    }
                }
            }
            guard read == 0 else { return nil }
            return Swift.String(decoding: buffer.prefix { $0 != 0 }, as: UTF16.self)
        }

        private static func registryNumber(_ key: Swift.String, _ value: Swift.String) -> DWORD? {
            var number: DWORD = 0
            var size = DWORD(MemoryLayout<DWORD>.size)
            let read = unsafe key.withCString(encodedAs: UTF16.self) { key in
                unsafe value.withCString(encodedAs: UTF16.self) { value in
                    unsafe withUnsafeMutableBytes(of: &number) { bytes in
                        unsafe RegGetValueW(
                            HKEY_LOCAL_MACHINE,
                            key,
                            value,
                            DWORD(RRF_RT_REG_DWORD),
                            nil,
                            bytes.baseAddress,
                            &size
                        )
                    }
                }
            }
            return read == 0 ? number : nil
        }
    }

#endif
