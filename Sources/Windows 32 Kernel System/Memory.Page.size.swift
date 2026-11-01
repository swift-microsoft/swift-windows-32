public import Memory

#if os(Windows)
    internal import WinSDK

    extension Memory.Page {

        /// The page size, `GetSystemInfo`'s `dwPageSize`.
        public static var size: Size {
            var info = SYSTEM_INFO()
            GetSystemInfo(&info)
            guard let size = UInt(exactly: info.dwPageSize), size > 0 else {
                preconditionFailure("GetSystemInfo reported no page size")
            }
            return Size(_unchecked: Cardinal(size))
        }
    }

#endif
