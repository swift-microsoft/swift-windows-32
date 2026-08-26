public import Memory

extension Windows.`32`.Kernel.File.Direct.Requirements {

    public struct Alignment: Sendable, Equatable {

        public let bufferAlignment: Memory.Alignment

        public let offsetAlignment: Memory.Alignment

        public let lengthMultiple: Memory.Alignment

        public init(
            bufferAlignment: Memory.Alignment,
            offsetAlignment: Memory.Alignment,
            lengthMultiple: Memory.Alignment
        ) {
            self.bufferAlignment = bufferAlignment
            self.offsetAlignment = offsetAlignment
            self.lengthMultiple = lengthMultiple
        }

        public init(uniform alignment: Memory.Alignment) {
            self.bufferAlignment = alignment
            self.offsetAlignment = alignment
            self.lengthMultiple = alignment
        }
    }
}
