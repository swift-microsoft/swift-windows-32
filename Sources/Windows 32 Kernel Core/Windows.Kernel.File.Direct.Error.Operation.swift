extension Windows.`32`.Kernel.File.Direct.Error {

    public enum Operation: Sendable, Equatable {
        case open
        case cache(Cache)
        case sector(Sector)
        case read
        case write
    }
}

extension Windows.`32`.Kernel.File.Direct.Error.Operation {
}
