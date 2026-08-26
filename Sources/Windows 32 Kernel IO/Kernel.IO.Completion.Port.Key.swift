#if os(Windows)
    public import Error
    public import WinSDK

    extension Windows.`32`.Kernel.IO.Completion.Port {

        public struct Key: RawRepresentable, Sendable, Equatable, Hashable {
            public let rawValue: ULONG_PTR

            @inlinable
            public init(rawValue: ULONG_PTR) {
                self.rawValue = rawValue
            }
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Key {

        @inlinable
        public init(_ id: ULONG_PTR) {
            self.init(rawValue: id)
        }

        @unsafe
        @inlinable
        public init(_ pointer: UnsafeRawPointer) {
            self.init(rawValue: ULONG_PTR(UInt(bitPattern: pointer)))
        }

        @unsafe
        @inlinable
        public init<T>(pointer: UnsafePointer<T>) {
            self.init(rawValue: ULONG_PTR(UInt(bitPattern: pointer)))
        }

        @unsafe
        @inlinable
        public init<T>(pointer: UnsafeMutablePointer<T>) {
            self.init(rawValue: ULONG_PTR(UInt(bitPattern: pointer)))
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Key {

        public static let zero = Self(rawValue: 0)
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Key: ExpressibleByIntegerLiteral {
        @inlinable
        public init(integerLiteral value: UInt) {
            self.init(rawValue: ULONG_PTR(value))
        }
    }

#endif
