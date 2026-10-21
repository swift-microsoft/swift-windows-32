extension UnsafeBufferPointer {

    /// The base address of a buffer the caller guarantees is non-empty.
    ///
    /// Traps when the buffer has no base address.
    @inlinable
    package var nonEmptyBaseAddress: UnsafePointer<Element> {
        guard let base = unsafe baseAddress else {
            preconditionFailure("Buffer must not be empty")
        }
        return unsafe base
    }
}

extension UnsafeMutableBufferPointer {

    /// The base address of a buffer the caller guarantees is non-empty.
    ///
    /// Traps when the buffer has no base address.
    @inlinable
    package var nonEmptyBaseAddress: UnsafeMutablePointer<Element> {
        guard let base = unsafe baseAddress else {
            preconditionFailure("Buffer must not be empty")
        }
        return unsafe base
    }
}

extension UnsafeRawBufferPointer {

    /// The base address of a buffer the caller guarantees is non-empty.
    ///
    /// Traps when the buffer has no base address.
    @inlinable
    package var nonEmptyBaseAddress: UnsafeRawPointer {
        guard let base = unsafe baseAddress else {
            preconditionFailure("Buffer must not be empty")
        }
        return unsafe base
    }
}
