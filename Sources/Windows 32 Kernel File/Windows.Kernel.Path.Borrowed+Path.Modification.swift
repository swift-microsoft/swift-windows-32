#if os(Windows)

    extension Path.Borrowed: @retroactive Path.Modification {
        @inlinable
        public static func appending(
            _ view: borrowing Path.Borrowed,
            _ other: borrowing Path.Borrowed
        ) -> Path {
            let selfEndsWithSep: Bool
            if view.count > 0 {
                let last = unsafe view.pointer[view.count - 1]
                selfEndsWithSep = last == 0x5C || last == 0x2F
            } else {
                selfEndsWithSep = false
            }
            let separatorSize = selfEndsWithSep ? 0 : 1
            let totalCount = view.count + separatorSize + other.count

            let buffer = UnsafeMutablePointer<Path.Char>.allocate(capacity: totalCount + 1)
            unsafe buffer.initialize(from: view.pointer, count: view.count)
            var offset = view.count
            if !selfEndsWithSep {
                (unsafe buffer)[offset] = 0x5C
                offset += 1
            }
            unsafe (buffer + offset).initialize(from: other.pointer, count: other.count)
            (unsafe buffer)[totalCount] = 0

            return unsafe Path(adopting: buffer, count: totalCount)
        }
    }

#endif
