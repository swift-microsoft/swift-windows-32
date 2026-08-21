#if os(Windows)
    internal import CRT
    public import WinSDK

    extension Windows.`32`.Kernel.Process {

        public enum Exit {}
    }

    extension Windows.`32`.Kernel.Process.Exit {

        public static func now(_ exitCode: UInt32) -> Never {
            ExitProcess(exitCode)
        }

        public static func normal(_ status: Int32) -> Never {
            CRT.exit(status)
        }
    }

#endif
