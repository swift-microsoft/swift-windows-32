public import Windows_32_Core

#if os(Windows)
    import Windows_Memory_Shims
#endif

extension Windows.Memory.Allocation {

    public struct Statistics: Sendable, Equatable {

        public let allocations: Int

        public let deallocations: Int

        public let bytesAllocated: Int

        public init(allocations: Int = 0, deallocations: Int = 0, bytesAllocated: Int = 0) {
            self.allocations = allocations
            self.deallocations = deallocations
            self.bytesAllocated = bytesAllocated
        }
    }
}

extension Windows.Memory.Allocation.Statistics {

    public static func capture() -> Self {
        #if os(Windows)
            let stats = windows_heap_statistics()
            return Self(
                allocations: Int(stats.allocations),
                deallocations: Int(stats.deallocations),
                bytesAllocated: Int(stats.bytes_allocated)
            )
        #else
            return Self()
        #endif
    }
}
