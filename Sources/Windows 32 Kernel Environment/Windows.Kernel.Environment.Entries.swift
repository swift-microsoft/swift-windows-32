#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.Environment {

        public struct Entries: ~Copyable {
            private let block: LPWCH

            private var current: LPWCH

            public init?() {
                guard let block = GetEnvironmentStringsW() else {
                    return nil
                }
                self.block = block
                self.current = block
            }

            deinit {
                FreeEnvironmentStringsW(block)
            }
        }
    }

    extension Windows.`32`.Kernel.Environment.Entries {
        public func makeIterator() -> Iterator {
            Iterator(current: block)
        }

        public mutating func next() -> Entry? {
            var iterator = Iterator(current: current)
            while let entry = iterator.next() {
                current = iterator.position
                if entry.raw.first == 0x003D {
                    continue
                }
                return entry
            }
            current = iterator.position
            return nil
        }
    }

    extension Windows.`32`.Kernel.Environment.Entries {

        public struct Entry: Sendable {

            public let raw: [UInt16]

            @usableFromInline
            internal let _name: [UInt16]

            @usableFromInline
            internal let _value: [UInt16]

            init(raw: [UInt16]) {
                self.raw = raw
                let bound = raw.firstIndex(of: 0x003D) ?? raw.endIndex
                var name = Array(raw[..<bound])
                name.append(0)
                self._name = name
                var value = bound < raw.endIndex ? Array(raw[raw.index(after: bound)...]) : []
                value.append(0)
                self._value = value
            }
        }
    }

    extension Windows.`32`.Kernel.Environment.Entries.Entry {

        public var string: String? {
            String(decoding: raw, as: UTF16.self)
        }

        public var parsed: (name: String, value: String)? {
            guard let str = string,
                let eqIndex = str.firstIndex(of: "="),
                eqIndex != str.startIndex
            else {
                return nil
            }
            let name = String(str[..<eqIndex])
            let value = String(str[str.index(after: eqIndex)...])
            return (name, value)
        }
    }

    extension Windows.`32`.Kernel.Environment.Entries {

        public struct Iterator: IteratorProtocol {
            private var current: LPWCH

            init(current: LPWCH) {
                self.current = current
            }
        }
    }

    extension Windows.`32`.Kernel.Environment.Entries.Iterator {

        internal var position: LPWCH { current }

        public mutating func next() -> Windows.`32`.Kernel.Environment.Entries.Entry? {

            guard current.pointee != 0 else {
                return nil
            }

            var end = current
            while end.pointee != 0 {
                end = end.advanced(by: 1)
            }

            let length = current.distance(to: end)
            guard length > 0 else {
                return nil
            }

            var chars = [UInt16](repeating: 0, count: length)
            for i in 0..<length {
                chars[i] = current.advanced(by: i).pointee
            }

            current = end.advanced(by: 1)

            return Windows.`32`.Kernel.Environment.Entries.Entry(raw: chars)
        }
    }

    extension Windows.`32`.Kernel.Environment {

        public static func all() -> [String: String]? {
            guard let entries = Entries() else { return nil }

            var result = [String: String]()
            var iterator = entries.makeIterator()
            while let entry = iterator.next() {
                if let (name, value) = entry.parsed {
                    result[name] = value
                }
            }
            return result
        }
    }

#endif
