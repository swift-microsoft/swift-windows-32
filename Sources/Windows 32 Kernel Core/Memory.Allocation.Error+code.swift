#if os(Windows)

    public import Error_Primitives
    public import Memory_Allocation_Primitives

    extension Memory.Allocation.Error {

        @inlinable
        public init?(code: Error_Primitives.Error.Code) {
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
