#if os(Windows)

    extension Path.`Protocol` where Self: ~Copyable {

        /// The path `string` spells, with Win32's own separator rule: each `/` becomes `\`, except in
        /// a path that begins `\\?\`, which Win32 passes to the file system without parsing.
        ///
        /// Text may not be empty or contain NUL or control characters; see `init(validating:)`.
        @inlinable
        public init(_ string: Swift::String) throws(Path.Error) {
            let units = try Path.Unique(validating: string)
            let verbatim =
                unsafe units.count >= 4
                && units.view.pointer[0] == 0x5C && units.view.pointer[1] == 0x5C
                && units.view.pointer[2] == 0x3F && units.view.pointer[3] == 0x5C
            let count = units.count
            let source = unsafe units.view.pointer
            unsafe self.init(count: count) { base in
                (0..<count).forEach { index in
                    let unit = unsafe source[index]
                    unsafe base[index] =
                        !verbatim && unit == Windows.`32`.Filename.alternateSeparator
                        ? Windows.`32`.Filename.separator : unit
                }
            }
        }
    }

    extension Path: @retroactive ExpressibleByStringLiteral {

        @inlinable
        public init(stringLiteral value: Swift::String) {
            do throws(Path.Error) {
                try self.init(value)
            } catch {
                fatalError("Invalid path literal: \(value) (\(error))")
            }
        }
    }

    /// Interpolated text is a path by the same rule as a plain literal.
    extension Path: @retroactive ExpressibleByStringInterpolation {}

    extension Path.`Protocol` where Self: ~Copyable {

        /// Whether the path names its volume: `C:\…` or `\\…`.
        @inlinable
        public var isAbsolute: Bool {
            if view.count >= 2, _isSeparator(at: 0), _isSeparator(at: 1) {
                return true
            }
            return view.count >= 3 && _isDrive && _isSeparator(at: 2)
        }

        /// Whether the path is resolved against a working directory.
        @inlinable
        public var isRelative: Bool { !isAbsolute }

        /// Whether the path is a volume's root: `C:\`, or a UNC prefix with at most a share.
        @inlinable
        public var isRoot: Bool {
            if view.count >= 2, _isSeparator(at: 0), _isSeparator(at: 1) {
                var separators = 0
                var index = 2
                while index < view.count {
                    if _isSeparator(at: index) {
                        separators += 1
                        if separators > 1 { return false }
                    }
                    index += 1
                }
                return true
            }
            return view.count == 3 && _isDrive && _isSeparator(at: 2)
        }

        /// Whether the last code unit is a separator.
        @inlinable
        public var endsWithSeparator: Bool {
            view.count > 0 && _isSeparator(at: view.count - 1)
        }
    }

    extension Path.`Protocol` where Self: ~Copyable {

        /// The path without its last component: `nil` for a root and for a single relative
        /// component, and the drive's root for a component directly under it.
        @inlinable
        public var parent: Self? {
            guard let separator = _lastSeparator(before: view.count) else { return nil }
            if separator == 0 { return nil }
            if separator == 2 && _isDrive {
                if view.count == 3 { return nil }
                return prefix(3)
            }
            return prefix(separator)
        }

        /// The last component, or `nil` when the path has none.
        @inlinable
        public var lastComponent: Path.Component? {
            let end = _lastNonSeparator(before: view.count)
            guard end > 0 else { return nil }
            let start = _lastSeparator(before: end).map { $0 + 1 } ?? 0
            let span = unsafe Swift::Span<Path.Char>(_unsafeStart: view.pointer + start, count: end - start)
            return Path.Component(unchecked: span)
        }

        /// The path with `component` after it, joined by one separator.
        @inlinable
        public borrowing func appending(_ component: Path.Component) -> Self {
            Self.joining(
                view,
                separator: endsWithSeparator ? nil : Windows.`32`.Filename.separator,
                component.view
            )
        }

        /// The path with the component that `string` spells after it.
        @inlinable
        public borrowing func appending(_ string: Swift::String) throws(Path.Component.Error) -> Self {
            appending(try Path.Component(string))
        }

        /// `other` resolved against this path: `other` itself when it is absolute, otherwise both
        /// joined by one separator.
        @inlinable
        public borrowing func appending<Other: Path.`Protocol` & ~Copyable>(_ other: borrowing Other) -> Self {
            if other.isAbsolute {
                return Self(copying: other.view)
            }
            return Self.joining(
                view,
                separator: endsWithSeparator ? nil : Windows.`32`.Filename.separator,
                other.view
            )
        }
    }

    extension Path.`Protocol` where Self: ~Copyable {

        /// The components, without separators. A drive (`C:`) is the first component.
        @inlinable
        public var components: Path.Components {
            Path.Components(Path(copying: view))
        }

        /// Whether `other`'s components begin this path's, and both are absolute or both relative.
        @inlinable
        public borrowing func hasPrefix<Other: Path.`Protocol` & ~Copyable>(_ other: borrowing Other) -> Bool {
            guard isAbsolute == other.isAbsolute else { return false }
            var mine = components.makeIterator()
            var theirs = other.components.makeIterator()
            while let component = theirs.next() {
                guard let own = mine.next(), own == component else { return false }
            }
            return true
        }

        /// This path relative to `base`: `nil` unless `base` is a prefix of it, and `.` when both are
        /// the same.
        @inlinable
        public borrowing func relative<Other: Path.`Protocol` & ~Copyable>(to base: borrowing Other) -> Self? {
            guard isAbsolute == base.isAbsolute else { return nil }
            let own = components
            var index = own.startIndex
            var theirs = base.components.makeIterator()
            while let component = theirs.next() {
                guard index != own.endIndex, own[index] == component else { return nil }
                index = own.index(after: index)
            }
            guard index != own.endIndex else {
                let dot: [Path.Char] = [0x2E]
                return Self(dot.span)
            }
            let path = own.path
            let start = index
            let count = path._lastNonSeparator(before: path.count) - start
            return unsafe Self(count: count) { base in
                unsafe base.initialize(from: path.view.pointer + start, count: count)
            }
        }
    }

    extension Path.`Protocol` {

        /// `lhs` with `rhs` after it.
        @inlinable
        public static func / (lhs: Self, rhs: Path.Component) -> Self {
            lhs.appending(rhs)
        }

        /// `rhs` resolved against `lhs`.
        @_disfavoredOverload
        @inlinable
        public static func / (lhs: Self, rhs: Self) -> Self {
            lhs.appending(rhs)
        }
    }

    extension Path.`Protocol` where Self: ~Copyable {

        /// Whether the path begins with a drive letter and a colon.
        @inlinable
        package var _isDrive: Bool {
            guard view.count >= 2 else { return false }
            let letter = unsafe view.pointer[0]
            let isLetter = (letter >= 0x41 && letter <= 0x5A) || (letter >= 0x61 && letter <= 0x7A)
            return unsafe isLetter && view.pointer[1] == 0x3A
        }

        @inlinable
        package borrowing func _isSeparator(at index: Int) -> Bool {
            let unit = unsafe view.pointer[index]
            return unit == Windows.`32`.Filename.separator || unit == Windows.`32`.Filename.alternateSeparator
        }

        @inlinable
        package borrowing func _firstSeparator(from start: Int) -> Int? {
            var index = start
            while index < view.count {
                if _isSeparator(at: index) { return index }
                index += 1
            }
            return nil
        }

        @inlinable
        package borrowing func _firstNonSeparator(from start: Int) -> Int {
            var index = start
            while index < view.count {
                if !_isSeparator(at: index) { return index }
                index += 1
            }
            return view.count
        }

        @inlinable
        package borrowing func _lastSeparator(before end: Int) -> Int? {
            var index = end - 1
            while index >= 0 {
                if _isSeparator(at: index) { return index }
                index -= 1
            }
            return nil
        }

        /// The end of the last component that ends at or before `end`: the index after its last unit.
        @inlinable
        package borrowing func _lastNonSeparator(before end: Int) -> Int {
            var index = end - 1
            while index >= 0 {
                if !_isSeparator(at: index) { return index + 1 }
                index -= 1
            }
            return 0
        }
    }

    extension Path {

        /// A path's components, in order, without separators.
        public struct Components: BidirectionalCollection, Sendable {

            @usableFromInline
            package let path: Path

            @inlinable
            package init(_ path: Path) {
                self.path = path
            }
        }
    }

    extension Path.Components {

        public typealias Element = Path.Component

        public typealias Index = Int

        @inlinable
        public var startIndex: Int { path._firstNonSeparator(from: 0) }

        @inlinable
        public var endIndex: Int { path.count }

        @inlinable
        public subscript(position: Int) -> Path.Component {
            let end = path._firstSeparator(from: position) ?? endIndex
            return Path.Component(unchecked: path.content.extracting(position..<end))
        }

        @inlinable
        public func index(after index: Int) -> Int {
            let end = path._firstSeparator(from: index) ?? endIndex
            return path._firstNonSeparator(from: end)
        }

        @inlinable
        public func index(before index: Int) -> Int {
            let end = path._lastNonSeparator(before: index)
            return path._lastSeparator(before: end).map { $0 + 1 } ?? 0
        }
    }

#endif
