#if os(Windows)

    public import Error

    extension Windows.`32`.Kernel.Thread {

        public enum Error: Swift.Error, Sendable, Equatable, Hashable {

            case create(Error::Error)
        }
    }

    extension Windows.`32`.Kernel.Thread.Error: CustomStringConvertible {
        public var description: Swift.String {
            switch self {
            case .create(let error):
                return "thread create failed: \(error)"
            }
        }
    }

#endif
