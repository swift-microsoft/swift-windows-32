extension Windows.`32`.Kernel.File {

    public struct Permissions: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: UInt16

        @inlinable
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
    }
}

extension Windows.`32`.Kernel.File.Permissions {

    public static let ownerRead = Self(rawValue: 0o400)

    public static let ownerWrite = Self(rawValue: 0o200)

    public static let ownerExecute = Self(rawValue: 0o100)

    public static let ownerReadWrite = Self(rawValue: 0o600)

    public static let ownerAll = Self(rawValue: 0o700)

    public static let groupRead = Self(rawValue: 0o040)

    public static let groupWrite = Self(rawValue: 0o020)

    public static let groupExecute = Self(rawValue: 0o010)

    public static let groupReadWrite = Self(rawValue: 0o060)

    public static let groupAll = Self(rawValue: 0o070)

    public static let otherRead = Self(rawValue: 0o004)

    public static let otherWrite = Self(rawValue: 0o002)

    public static let otherExecute = Self(rawValue: 0o001)

    public static let otherReadWrite = Self(rawValue: 0o006)

    public static let otherAll = Self(rawValue: 0o007)

    public static let none = Self(rawValue: 0o000)

    public static let standard = Self(rawValue: 0o644)

    public static let executable = Self(rawValue: 0o755)

    public static let privateFile = Self(rawValue: 0o600)

    public static let privateExecutable = Self(rawValue: 0o700)

    public static let privateDirectory = Self(rawValue: 0o700)

    public static let standardDirectory = Self(rawValue: 0o755)

    @inlinable
    public static func | (lhs: Self, rhs: Self) -> Self {
        Self(rawValue: lhs.rawValue | rhs.rawValue)
    }

    @inlinable
    public static func |= (lhs: inout Self, rhs: Self) {
        lhs = lhs | rhs
    }

    @inlinable
    public static func & (lhs: Self, rhs: Self) -> Self {
        Self(rawValue: lhs.rawValue & rhs.rawValue)
    }

    @inlinable
    public static prefix func ~ (permissions: Self) -> Self {
        Self(rawValue: ~permissions.rawValue)
    }
}

extension Windows.`32`.Kernel.File.Permissions: ExpressibleByIntegerLiteral {

    @inlinable
    public init(integerLiteral value: UInt16) {
        self.rawValue = value
    }
}

extension Windows.`32`.Kernel.File.Permissions: CustomStringConvertible {
    public var description: Swift.String {
        let owner =
            "\(rawValue & 0o400 != 0 ? "r" : "-")\(rawValue & 0o200 != 0 ? "w" : "-")\(rawValue & 0o100 != 0 ? "x" : "-")"
        let group =
            "\(rawValue & 0o040 != 0 ? "r" : "-")\(rawValue & 0o020 != 0 ? "w" : "-")\(rawValue & 0o010 != 0 ? "x" : "-")"
        let other =
            "\(rawValue & 0o004 != 0 ? "r" : "-")\(rawValue & 0o002 != 0 ? "w" : "-")\(rawValue & 0o001 != 0 ? "x" : "-")"
        return "\(owner)\(group)\(other)"
    }
}
