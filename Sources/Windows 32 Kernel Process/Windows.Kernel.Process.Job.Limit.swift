#if os(Windows)
    internal import WinSDK

    extension Windows.`32`.Kernel.Process.Job {
        public struct Limit: OptionSet, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Windows.`32`.Kernel.Process.Job.Limit {
        public static var killOnClose: Self {
            Self(rawValue: UInt32(JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE))
        }
    }
#endif
