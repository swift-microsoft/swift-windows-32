#if os(Windows)

    public import Path_Primitives

    extension Path.Canonical.Error {

        @usableFromInline
        internal init(code: Error_Primitives.Error.Code) {
            if let e = Path.Resolution.Error(code: code) {
                self = .path(e)
                return
            }

            self = .platform(Error_Primitives.Error(code: code))
        }
    }
#endif
