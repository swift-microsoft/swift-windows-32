
extension Windows.`32`.Kernel.Descriptor: Swift.Equatable {
    @inlinable
    public static func == (
        lhs: borrowing Windows.`32`.Kernel.Descriptor,
        rhs: borrowing Windows.`32`.Kernel.Descriptor
    ) -> Bool {
        lhs._raw == rhs._raw
    }
}
