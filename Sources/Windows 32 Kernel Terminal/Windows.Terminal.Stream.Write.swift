#if os(Windows)
    public import Terminal_Primitives

    extension Terminal.Stream.Write {

        @discardableResult
        public func callAsFunction(
            _ bytes: some Swift.Sequence<UInt8>
        ) throws(Windows.`32`.Kernel.IO.Write.Error) -> Int {
            let array = ContiguousArray<UInt8>(bytes)
            return try unsafe array.withUnsafeBufferPointer {
                (
                    buffer: UnsafeBufferPointer<UInt8>
                ) throws(Windows.`32`.Kernel.IO.Write.Error) -> Int in
                let raw = UnsafeRawBufferPointer(buffer)
                return try unsafe write(raw)
            }
        }

        private func write(
            _ raw: UnsafeRawBufferPointer
        ) throws(Windows.`32`.Kernel.IO.Write.Error) -> Int {
            var written = 0
            while written < raw.count {
                let remaining = unsafe UnsafeRawBufferPointer(rebasing: raw[written..<raw.count])
                let n = try unsafe Windows.`32`.Kernel.IO.Write.write(stream, from: remaining)
                written += n
            }
            return written
        }
    }

#endif
