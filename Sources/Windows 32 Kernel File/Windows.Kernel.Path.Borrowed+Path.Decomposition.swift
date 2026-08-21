#if os(Windows)

    extension Path.Borrowed: @retroactive Path.Decomposition {
        public typealias Char = Path.Char

        @inlinable
        @_lifetime(copy view)
        public static func parent(of view: borrowing Path.Borrowed) -> Swift.Span<Path.Char>? {
            guard
                let lastSep = Path.Scan.lastSeparatorIndex(
                    in: view.span,
                    primary: 0x5C,
                    alt: 0x2F
                )
            else { return nil }

            if lastSep == 0 && view.count == 1 { return nil }

            let parentCount = lastSep == 0 ? 1 : lastSep
            return unsafe _overrideLifetime(
                Span(_unsafeStart: view.pointer, count: parentCount),
                copying: view
            )
        }

        @inlinable
        @_lifetime(copy view)
        public static func component(of view: borrowing Path.Borrowed) -> Swift.Span<Path.Char> {
            guard
                let lastSep = Path.Scan.lastSeparatorIndex(
                    in: view.span,
                    primary: 0x5C,
                    alt: 0x2F
                )
            else {

                return unsafe _overrideLifetime(
                    Span(_unsafeStart: view.pointer, count: view.count),
                    copying: view
                )
            }
            let offset = lastSep + 1
            return unsafe _overrideLifetime(
                Span(_unsafeStart: view.pointer + offset, count: view.count - offset),
                copying: view
            )
        }
    }

#endif
