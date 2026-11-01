public import CPU

#if os(Windows)
    internal import WinSDK

    extension CPU.Logical {

        /// The active logical processors in every processor group,
        /// `GetActiveProcessorCount(ALL_PROCESSOR_GROUPS)`. A failed call reports one processor.
        public static var count: Count {
            let value = GetActiveProcessorCount(WORD(ALL_PROCESSOR_GROUPS))
            guard value > 0, let count = UInt(exactly: value) else {
                return Count(_unchecked: Cardinal(1 as UInt))
            }
            return Count(_unchecked: Cardinal(count))
        }
    }

#endif
