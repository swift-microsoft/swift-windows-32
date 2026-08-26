#if os(Windows)

    public import Error
    public import Memory_Allocation

    extension Memory.Allocation.Error {

        @inlinable
        public init?(code: Error.Error.Code) {
            switch code {
            case .Windows.ERROR_NOT_ENOUGH_MEMORY,
                .win32(14):
                self = .exhausted

            default:
                return nil
            }
        }
    }

#endif
