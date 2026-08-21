public import Path_Primitives

extension Windows.`32`.Kernel.File.Direct {

    public enum Requirements: Sendable, Equatable {

        case known(Alignment)

        case unknown(reason: Reason)
    }
}

extension Windows.`32`.Kernel.File.Direct.Requirements {

    public init(_ path: borrowing Path.Borrowed) {
        self = .unknown(reason: .sectorSizeUndetermined)
    }
}
