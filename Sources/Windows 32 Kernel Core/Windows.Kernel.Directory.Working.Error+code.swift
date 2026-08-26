#if os(Windows)

    extension Windows.`32`.Kernel.Directory.Working.Error {

        package init(code: Error.Error.Code) {
            if let e = Path.Resolution.Error(code: code) {
                self = .path(e)
                return
            }
            self = .platform(Error.Error(code: code))
        }
    }
#endif
