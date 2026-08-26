public import Memory_Allocation

extension Windows.`32`.Kernel.Lock {

    public enum Range: Sendable, Equatable, Hashable {

        case file

        case bytes(start: Windows.`32`.Kernel.File.Offset, end: Windows.`32`.Kernel.File.Offset)

        @inlinable
        public init(
            forMappingAt offset: Windows.`32`.Kernel.File.Offset,
            length: Windows.`32`.Kernel.File.Size,
            granularity: Memory.Allocation.Granularity
        ) {

            let (sum, overflow) = offset.underlying.addingReportingOverflow(length.underlying)
            guard !overflow else {
                self = .bytes(start: offset, end: .max)
                return
            }
            let roundedEnd = granularity.underlying.alignUp(Windows.`32`.Kernel.File.Offset(sum))
            self = .bytes(start: offset, end: roundedEnd)
        }
    }
}

extension Windows.`32`.Kernel.Lock.Range {

    @inlinable
    public static func bytes(
        start: Windows.`32`.Kernel.File.Offset,
        length: Windows.`32`.Kernel.File.Size
    ) -> Self {

        let (sum, overflow) = start.underlying.addingReportingOverflow(length.underlying)
        return .bytes(start: start, end: overflow ? .max : Windows.`32`.Kernel.File.Offset(sum))
    }
}
