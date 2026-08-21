public import Path_Primitives

extension Windows.`32`.Kernel.Directory {

    public struct Entry: Sendable {

        public let rawName: [UInt16]

        public let inode: Windows.`32`.Kernel.Inode?

        public let type: Windows.`32`.Kernel.File.Stats.Kind?

        public init(
            rawName: [UInt16],
            inode: Windows.`32`.Kernel.Inode? = nil,
            type: Windows.`32`.Kernel.File.Stats.Kind? = nil
        ) {
            precondition(
                rawName.last == 0,
                "Directory.Entry rawName must be a non-empty, null-terminated sequence"
            )
            self.rawName = rawName
            self.inode = inode
            self.type = type
        }

    }
}

extension Windows.`32`.Kernel.Directory.Entry {

    public var isDotOrDotDot: Bool {
        rawName == [0x002E, 0x0000] || rawName == [0x002E, 0x002E, 0x0000]
    }

    #if os(Windows)

        public func withName<R, E: Swift.Error>(
            _ body: (borrowing Path.Borrowed) throws(E) -> R
        ) throws(E) -> R {
            let result: Swift.Result<R, E> = unsafe rawName.withUnsafeBufferPointer { buffer in
                let view = unsafe Path.Borrowed(buffer.baseAddress!, count: buffer.count - 1)
                do throws(E) {
                    return .success(try body(view))
                } catch {
                    return .failure(error)
                }
            }
            return try result.get()
        }

        public var name: Path.Borrowed {
            @_lifetime(borrow self)
            borrowing get {
                let ptr = unsafe rawName.withUnsafeBufferPointer { $0.baseAddress! }
                let view = unsafe Path.Borrowed(ptr, count: rawName.count - 1)
                return unsafe _overrideLifetime(view, borrowing: self)
            }
        }
    #endif
}
