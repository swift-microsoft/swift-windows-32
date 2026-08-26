#if os(Windows)
    public import WinSDK
    public import String

    extension Windows.`32`.Kernel.Environment {

        public static func get(_ name: Swift.String) -> String.String? {
            var wname = Array(name.utf16)
            wname.append(0)
            guard
                let units = wname.withUnsafeBufferPointer({ buf -> [UInt16]? in
                    let wptr = UnsafeRawPointer(buf.baseAddress!).assumingMemoryBound(
                        to: WCHAR.self
                    )
                    return get(name: wptr)
                })
            else {
                return nil
            }
            return String.String(units.span)
        }

        public static func set(
            _ name: Swift.String,
            to value: Swift.String,
            overwrite: Bool = true
        ) throws(Windows.`32`.Kernel.Environment.Error) {

            var wname = Array(name.utf16)
            wname.append(0)
            var wvalue = Array(value.utf16)
            wvalue.append(0)
            if !overwrite {
                let exists = wname.withUnsafeBufferPointer { buf in
                    let wptr = UnsafeRawPointer(buf.baseAddress!).assumingMemoryBound(
                        to: WCHAR.self
                    )
                    return GetEnvironmentVariableW(wptr, nil, 0) != 0
                }
                if exists {
                    return
                }
            }
            let ok = wname.withUnsafeBufferPointer { nameBuf in
                wvalue.withUnsafeBufferPointer { valueBuf in
                    SetEnvironmentVariableW(
                        UnsafeRawPointer(nameBuf.baseAddress!).assumingMemoryBound(to: WCHAR.self),
                        UnsafeRawPointer(valueBuf.baseAddress!).assumingMemoryBound(to: WCHAR.self)
                    )
                }
            }
            guard ok else {
                throw .current()
            }
        }

        public static func unset(_ name: Swift.String) throws(Windows.`32`.Kernel.Environment.Error)
        {
            var wname = Array(name.utf16)
            wname.append(0)
            let ok = wname.withUnsafeBufferPointer { buf in
                let wptr = UnsafeRawPointer(buf.baseAddress!).assumingMemoryBound(to: WCHAR.self)
                return SetEnvironmentVariableW(wptr, nil)
            }
            if !ok {
                if GetLastError() == DWORD(ERROR_ENVVAR_NOT_FOUND) {
                    return
                }
                throw .current()
            }
        }

        public static func entries() -> Entries? {
            Entries()
        }
    }

    extension Windows.`32`.Kernel.Environment.Entries.Entry {

        public var name: String.String.Borrowed {
            @_lifetime(borrow self)
            borrowing get {
                let ptr = unsafe _name.withUnsafeBufferPointer { $0.baseAddress! }
                let view = unsafe String.String.Borrowed(ptr, count: _name.count - 1)
                return unsafe _overrideLifetime(view, borrowing: self)
            }
        }

        public var value: String.String.Borrowed {
            @_lifetime(borrow self)
            borrowing get {
                let ptr = unsafe _value.withUnsafeBufferPointer { $0.baseAddress! }
                let view = unsafe String.String.Borrowed(ptr, count: _value.count - 1)
                return unsafe _overrideLifetime(view, borrowing: self)
            }
        }
    }

#endif
