public import CPU

#if os(Windows)
    internal import WinSDK

    extension CPU.Core {

        /// The physical cores, one `RelationProcessorCore` record each from
        /// `GetLogicalProcessorInformationEx`. A failed call reports one core.
        public static var count: Count {
            var length: DWORD = 0
            _ = unsafe GetLogicalProcessorInformationEx(RelationProcessorCore, nil, &length)
            guard length > 0 else {
                return Count(_unchecked: Cardinal(1 as UInt))
            }

            var buffer = [UInt8](repeating: 0, count: Int(length))
            let cores: UInt = unsafe buffer.withUnsafeMutableBytes { bytes in
                guard let base = unsafe bytes.baseAddress else { return 0 }
                let information = unsafe base.assumingMemoryBound(
                    to: SYSTEM_LOGICAL_PROCESSOR_INFORMATION_EX.self
                )
                guard unsafe GetLogicalProcessorInformationEx(RelationProcessorCore, information, &length) else {
                    return 0
                }

                var cores: UInt = 0
                var offset = 0
                while offset < Int(length) {
                    let record = unsafe (base + offset).assumingMemoryBound(
                        to: SYSTEM_LOGICAL_PROCESSOR_INFORMATION_EX.self
                    )
                    let size = Int(unsafe record.pointee.Size)
                    guard size > 0 else { break }
                    if unsafe record.pointee.Relationship == RelationProcessorCore {
                        cores += 1
                    }
                    offset += size
                }
                return cores
            }

            guard cores > 0 else {
                return Count(_unchecked: Cardinal(1 as UInt))
            }
            return Count(_unchecked: Cardinal(cores))
        }
    }

#endif
