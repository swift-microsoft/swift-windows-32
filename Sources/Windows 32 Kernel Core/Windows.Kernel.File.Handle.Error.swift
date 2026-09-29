public import Error
public import Memory

extension Windows.`32`.Kernel.File.Handle {

    public enum Error: Swift.Error, Sendable, Equatable {
        case invalidHandle
        case endOfFile
        case noSpace
        case misalignedBuffer(address: Memory.Address, required: Memory.Alignment)
        case misalignedOffset(offset: Int64, required: Memory.Alignment)
        case invalidLength(length: Int, requiredMultiple: Memory.Alignment)
        case requirementsUnknown
        case alignmentViolation(operation: Operation)
        case platform(code: Error::Error.Code, operation: Operation)
    }
}
