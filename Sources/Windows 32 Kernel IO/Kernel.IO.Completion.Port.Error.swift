#if os(Windows)
    public import Error
    public import WinSDK

    extension Windows.`32`.Kernel.IO.Completion.Port {

        public enum Error: Swift.Error, Sendable, Equatable, Hashable {

            case create(Error::Error.Code)

            case associate(Error::Error.Code)

            case dequeue(Error::Error.Code)

            case post(Error::Error.Code)

            case read(Error::Error.Code)

            case write(Error::Error.Code)

            case result(Error::Error.Code)

            case timeout
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Error: CustomStringConvertible {
        public var description: Swift.String {
            switch self {
            case .create(let code):
                return "CreateIoCompletionPort failed (\(code))"

            case .associate(let code):
                return "associate failed (\(code))"

            case .dequeue(let code):
                return "GetQueuedCompletionStatus failed (\(code))"

            case .post(let code):
                return "PostQueuedCompletionStatus failed (\(code))"

            case .read(let code):
                return "ReadFile failed (\(code))"

            case .write(let code):
                return "WriteFile failed (\(code))"

            case .result(let code):
                return "GetOverlappedResult failed (\(code))"

            case .timeout:
                return "operation timed out"
            }
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Error {

        @inlinable
        public static func last() -> UInt32 {
            GetLastError()
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Error {

        public enum Code {}
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Error.Code {

        public enum IO {}

        public enum Operation {}

        public enum Lookup {}

        public enum Wait {}
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Error.Code.IO {

        public static let pending: UInt32 = UInt32(ERROR_IO_PENDING)
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Error.Code.Operation {

        public static let aborted: UInt32 = UInt32(ERROR_OPERATION_ABORTED)
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Error.Code.Lookup {

        public static let notFound: UInt32 = UInt32(ERROR_NOT_FOUND)
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Error.Code.Wait {

        public static let timeout: UInt32 = UInt32(bitPattern: WAIT_TIMEOUT)

        public static let infinite: UInt32 = INFINITE
    }

#endif
