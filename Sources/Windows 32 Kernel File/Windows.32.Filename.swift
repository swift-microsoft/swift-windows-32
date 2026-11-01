#if os(Windows)

    public import Binary

    extension Windows.`32` {

        /// A Win32 file name: non-empty, with none of `\ / : * ? " < > |` and no code unit below 0x20.
        ///
        /// Stored inline in ``Path/Small``, which holds the 255 UTF-16 units NTFS allows without
        /// allocating. Text is held to more: it may not name a reserved device (`CON`, `NUL.txt`, `com1`)
        /// or end in a dot or a space, which Win32 would strip.
        @frozen
        public struct Filename: Hashable, Sendable {

            @usableFromInline
            internal var _units: Path.Small<256>

            @inlinable
            internal init(_units units: Path.Small<256>) {
                self._units = units
            }
        }
    }

    extension Path {

        /// One component of a path: on Windows, a ``Windows/32/Filename``.
        public typealias Component = Windows.`32`.Filename
    }

    extension Windows.`32`.Filename {

        /// The primary separator, `\`.
        public static var separator: Path.Char { 0x5C }

        /// The alternate separator, `/`.
        public static var alternateSeparator: Path.Char { 0x2F }

        /// The names Win32 reserves for devices, in upper case. A name whose part before its first dot
        /// is one of these, compared case-insensitively, names the device.
        public static let reserved: Set<Swift::String> = [
            "CON", "PRN", "AUX", "NUL",
            "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9",
            "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9",
        ]

        public enum Error: Swift::Error, Sendable, Equatable {

            case empty

            case containsPathSeparator

            case containsControlCharacters

            case containsInteriorNUL

            case containsReservedCharacter

            case reservedName

            case trailingDotOrSpace

            case invalidUTF8
        }
    }

    extension Windows.`32`.Filename.Error: CustomStringConvertible {

        public var description: Swift::String {
            switch self {
            case .empty: return "Component is empty"
            case .containsPathSeparator: return "Component contains path separator"
            case .containsControlCharacters: return "Component contains control characters"
            case .containsInteriorNUL: return "Component contains interior NUL byte"
            case .containsReservedCharacter: return "Component contains a character Windows reserves"
            case .reservedName: return "Component names a device Windows reserves"
            case .trailingDotOrSpace: return "Component ends in a dot or a space"
            case .invalidUTF8: return "Component contains invalid UTF-16"
            }
        }
    }

    extension Windows.`32`.Filename {

        /// The filename `string` spells.
        @inlinable
        public init(_ string: Swift::String) throws(Error) {
            guard !string.isEmpty else { throw .empty }
            for scalar in string.unicodeScalars {
                switch scalar {
                case "\0": throw .containsInteriorNUL
                case "\\", "/": throw .containsPathSeparator
                case ":", "*", "?", "\"", "<", ">", "|": throw .containsReservedCharacter
                default:
                    if scalar.value < 0x20 || scalar.value == 0x7F { throw .containsControlCharacters }
                }
            }
            if string != ".", string != "..", let last = string.last, last == "." || last == " " {
                throw .trailingDotOrSpace
            }
            if Self.reserved.contains(string.prefix { $0 != "." }.uppercased()) { throw .reservedName }
            do throws(Path.Error) {
                self.init(_units: try Path.Small<256>(string))
            } catch {
                preconditionFailure("text already checked: \(error)")
            }
        }

        /// The filename a directory entry names, from its code units. The units must be valid UTF-16 and
        /// hold to the rules for text.
        @inlinable
        public init(platformNative codeUnits: [Path.Char]) throws(Error) {
            guard let string = Swift::String(validating: codeUnits, as: Path.Codec.self) else {
                throw .invalidUTF8
            }
            try self.init(string)
        }

        /// Code units already known to form a filename: non-empty, no separator, no NUL.
        @inlinable
        public init(unchecked units: Swift::Span<Path.Char>) {
            self.init(_units: Path.Small<256>(units))
        }

        /// Text already known to form a filename.
        @inlinable
        public init(unchecked string: Swift::String) {
            do throws(Path.Error) {
                self.init(_units: try Path.Small<256>(string))
            } catch {
                preconditionFailure("not a filename: \(string) (\(error))")
            }
        }
    }

    extension Windows.`32`.Filename {

        /// The name as text.
        @inlinable
        public var string: Swift::String { _units.string }

        /// The number of code units.
        @inlinable
        public var count: Int { _units.count }

        /// The code units and their NUL, lent to a system call.
        @inlinable
        public var view: Path.Borrowed {
            @_lifetime(borrow self) borrowing get {
                let pointer = unsafe _units.view.pointer
                let view = unsafe Path.Borrowed(pointer, count: _units.count)
                return unsafe _overrideLifetime(view, borrowing: self)
            }
        }
    }

    extension Swift::String {

        /// The text of `filename`.
        @inlinable
        public init(_ filename: Windows.`32`.Filename) {
            self = filename.string
        }
    }

    extension Windows.`32`.Filename: CustomStringConvertible, CustomDebugStringConvertible {

        public var description: Swift::String { string }

        public var debugDescription: Swift::String { "Path.Component(\"\(string)\")" }
    }

    extension Windows.`32`.Filename: ExpressibleByStringLiteral {

        @inlinable
        public init(stringLiteral value: Swift::String) {
            do {
                try self.init(value)
            } catch {
                fatalError("Invalid path component literal: \(value) (\(error))")
            }
        }
    }

    extension Windows.`32`.Filename: Binary.Serializable {

        /// The name's text, as UTF-8.
        @inlinable
        public static func serialize<Buffer: RangeReplaceableCollection>(
            _ filename: borrowing Self,
            into buffer: inout Buffer
        ) where Buffer.Element == Byte {
            buffer.append(contentsOf: filename.string.utf8.map(Byte.init(bitPattern:)))
        }
    }

#endif
