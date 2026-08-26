public import Dimension

extension Windows.`32`.Kernel.File {

    public typealias Offset = Coordinate.X<Space>.Value<Int64>

    public typealias Delta = Displacement.X<Space>.Value<Int64>
}

extension Windows.`32`.Kernel.File.Offset {

    public static let max = Self(Int64.max)
}

extension Windows.`32`.Kernel.File.Offset {

    @inlinable
    public init(_ value: Int) {
        self.init(Int64(value))
    }
}
