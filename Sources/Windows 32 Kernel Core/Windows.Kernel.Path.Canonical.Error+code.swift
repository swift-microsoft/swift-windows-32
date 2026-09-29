#if os(Windows)

    public import Path

    extension Path.Canonical.Error {

        @usableFromInline
        internal init(code: Error::Error.Code) {
            if let e = Path.Resolution.Error(code: code) {
                self = .path(e)
                return
            }

            self = .platform(Error::Error(code: code))
        }
    }
#endif
