extension Windows.`32`.Kernel.Descriptor: Swift.Hashable {
    @inlinable
    public borrowing func hash(into hasher: inout Hasher) {
        _raw.hash(into: &hasher)
    }
}
