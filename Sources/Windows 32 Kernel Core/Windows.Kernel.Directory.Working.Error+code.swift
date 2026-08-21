#if os(Windows)

    extension Windows.`32`.Kernel.Directory.Working.Error {

        package init(code: Error_Primitives.Error.Code) {
            if let e = Path.Resolution.Error(code: code) {
                self = .path(e)
                return
            }
            self = .platform(Error_Primitives.Error(code: code))
        }
    }
#endif
