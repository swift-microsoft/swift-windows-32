public import Spatial
public import Memory

extension Windows.`32`.Kernel.File {

    public typealias Size = Spatial::Magnitude<Space>.Value<Int64>
}

extension Windows.`32`.Kernel.File.Size {

    public static let kilobyte: Self = Self(1024)

    public static let megabyte: Self = Self(1024 * 1024)

    public static let gigabyte: Self = Self(1024 * 1024 * 1024)

    @inlinable
    public static func page(size pageSize: UInt) -> Self {
        Self(Int64(pageSize))
    }
}

extension Windows.`32`.Kernel.File.Size {

    @inlinable
    public init(pages: Int, pageSize: UInt) {
        self.init(Int64(pages) * Int64(pageSize))
    }

    @inlinable
    public init(_ value: Int) {
        self.init(Int64(value))
    }

    @inlinable
    public init(_ value: UInt64) {
        self.init(Int64(bitPattern: value))
    }

    @inlinable
    public init(_ delta: Windows.`32`.Kernel.File.Delta) {
        precondition(delta.underlying >= 0, "Delta must be non-negative to convert to Size")
        self.init(delta.underlying)
    }
}

extension Windows.`32`.Kernel.File.Size {

    @inlinable
    public var isZero: Bool {
        underlying == 0
    }

    @inlinable
    public var isPositive: Bool {
        underlying > 0
    }
}

extension Windows.`32`.Kernel.File.Size {

    public func isAligned(to alignment: Memory.Alignment) -> Bool {
        let mask: Int64 = alignment.mask()
        return underlying & mask == 0
    }

    public func alignedDown(to alignment: Memory.Alignment) -> Self {
        let mask: Int64 = alignment.mask()
        return Self(underlying & ~mask)
    }

    public func alignedUp(to alignment: Memory.Alignment) -> Self {
        let mask: Int64 = alignment.mask()
        return Self((underlying &+ mask) & ~mask)
    }
}

extension Int {

    @inlinable
    public init(_ size: Windows.`32`.Kernel.File.Size) {
        self = Int(size.underlying)
    }
}
