extension Windows.`32`.Kernel.File {

    @frozen
    public struct Handle: ~Copyable, Sendable {

        public let descriptor: Windows.`32`.Kernel.File.Descriptor

        public let direct: Windows.`32`.Kernel.File.Direct.Mode.Resolved

        public let requirements: Windows.`32`.Kernel.File.Direct.Requirements

        public init(
            descriptor: consuming Windows.`32`.Kernel.File.Descriptor,
            direct: Windows.`32`.Kernel.File.Direct.Mode.Resolved,
            requirements: Windows.`32`.Kernel.File.Direct.Requirements
        ) {
            self.descriptor = descriptor
            self.direct = direct
            self.requirements = requirements
        }
    }
}
