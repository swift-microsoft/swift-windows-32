import Hash_Protocol

extension Windows.`32`.Kernel.Descriptor: Hash.`Protocol` {
    @inlinable
    public borrowing func hash(into hasher: inout Hasher) {
        _raw.hash(into: &hasher)
    }
}
