#if os(Windows)
    internal import WinSDK
#endif

extension Windows.`32`.Kernel.Process.Spawn {

    public struct Actions: ~Copyable {
        #if os(Windows)

            internal var _attributeListRaw: UnsafeMutableRawPointer?

            internal var _inheritHandlesRaw: UnsafeMutablePointer<HANDLE?>?

            internal var _inheritHandlesCount: Int = 0

            internal var _attributeListSize: SIZE_T = 0

            internal var _stdinHandle: HANDLE?

            internal var _stdoutHandle: HANDLE?

            internal var _stderrHandle: HANDLE?
        #endif

        public init() throws(Windows.`32`.Kernel.Process.Error) {
            #if os(Windows)

                var size: SIZE_T = 0

                _ = unsafe InitializeProcThreadAttributeList(nil, 1, 0, &size)
                let lastError = unsafe GetLastError()
                guard lastError == ERROR_INSUFFICIENT_BUFFER else {
                    throw .create(.win32(lastError))
                }

                let raw = unsafe UnsafeMutableRawPointer.allocate(
                    byteCount: Int(size),
                    alignment: MemoryLayout<HANDLE>.alignment
                )

                guard
                    unsafe InitializeProcThreadAttributeList(
                        LPPROC_THREAD_ATTRIBUTE_LIST(raw),
                        1,
                        0,
                        &size
                    )
                else {
                    let err = unsafe GetLastError()
                    unsafe raw.deallocate()
                    throw .create(.win32(err))
                }

                unsafe (self._attributeListRaw = raw)
                unsafe (self._inheritHandlesRaw = nil)
                self._inheritHandlesCount = 0
                self._attributeListSize = size
                unsafe (self._stdinHandle = nil)
                unsafe (self._stdoutHandle = nil)
                unsafe (self._stderrHandle = nil)
            #else

                throw .create(.win32(0))
            #endif
        }

        deinit {
            #if os(Windows)
                if let list = _attributeListRaw {
                    unsafe DeleteProcThreadAttributeList(LPPROC_THREAD_ATTRIBUTE_LIST(list))
                    unsafe list.deallocate()
                }
                if let handles = _inheritHandlesRaw {
                    unsafe handles.deinitialize(count: _inheritHandlesCount)
                    unsafe handles.deallocate()
                }
            #endif
        }
    }
}

#if os(Windows)

    private let processThreadAttributeHandleList: DWORD = 0x20002

    extension Windows.`32`.Kernel.Process.Spawn.Actions {

        internal var _attributeList: LPPROC_THREAD_ATTRIBUTE_LIST? {
            unsafe (_attributeListRaw.map { LPPROC_THREAD_ATTRIBUTE_LIST($0) })
        }

        internal var _stdioHandles: (stdin: HANDLE?, stdout: HANDLE?, stderr: HANDLE?)? {
            let standardInput = unsafe _stdinHandle
            let standardOutput = unsafe _stdoutHandle
            let standardError = unsafe _stderrHandle
            guard standardInput != nil || standardOutput != nil || standardError != nil else {
                return nil
            }
            return unsafe (standardInput, standardOutput, standardError)
        }
    }

    extension Windows.`32`.Kernel.Process.Spawn.Actions {

        public mutating func setStdin(_ descriptor: borrowing Windows.`32`.Kernel.Descriptor) {
            unsafe (_stdinHandle = UnsafeMutableRawPointer(bitPattern: descriptor._raw))
        }

        public mutating func setStdout(_ descriptor: borrowing Windows.`32`.Kernel.Descriptor) {
            unsafe (_stdoutHandle = UnsafeMutableRawPointer(bitPattern: descriptor._raw))
        }

        public mutating func setStderr(_ descriptor: borrowing Windows.`32`.Kernel.Descriptor) {
            unsafe (_stderrHandle = UnsafeMutableRawPointer(bitPattern: descriptor._raw))
        }
    }

    extension Windows.`32`.Kernel.Process.Spawn.Actions {

        public mutating func markHandleInheritable(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor
        ) throws(Windows.`32`.Kernel.Process.Error) {
            guard let handle = unsafe UnsafeMutableRawPointer(bitPattern: descriptor._raw) else {
                throw .create(.win32(UInt32(ERROR_INVALID_HANDLE)))
            }
            guard
                unsafe SetHandleInformation(
                    handle,
                    DWORD(HANDLE_FLAG_INHERIT),
                    DWORD(HANDLE_FLAG_INHERIT)
                )
            else {
                throw .create(Error_Primitives.Error.captureLastError())
            }

            let newCount = _inheritHandlesCount + 1
            let newRaw = unsafe UnsafeMutablePointer<HANDLE?>.allocate(capacity: newCount)
            if let old = _inheritHandlesRaw {
                unsafe newRaw.update(from: old, count: _inheritHandlesCount)
                unsafe old.deinitialize(count: _inheritHandlesCount)
                unsafe old.deallocate()
            }
            unsafe (newRaw + _inheritHandlesCount).initialize(to: handle)
            unsafe (self._inheritHandlesRaw = newRaw)
            self._inheritHandlesCount = newCount

            guard let attrList = unsafe _attributeListRaw else {
                throw .create(.win32(UInt32(ERROR_INVALID_HANDLE)))
            }

            unsafe DeleteProcThreadAttributeList(LPPROC_THREAD_ATTRIBUTE_LIST(attrList))
            var size = _attributeListSize
            guard
                unsafe InitializeProcThreadAttributeList(
                    LPPROC_THREAD_ATTRIBUTE_LIST(attrList),
                    1,
                    0,
                    &size
                )
            else {

                let err = Error_Primitives.Error.captureLastError()
                unsafe attrList.deallocate()
                unsafe (self._attributeListRaw = nil)
                throw .create(err)
            }

            guard
                unsafe UpdateProcThreadAttribute(
                    LPPROC_THREAD_ATTRIBUTE_LIST(attrList),
                    0,
                    DWORD_PTR(processThreadAttributeHandleList),
                    newRaw,
                    SIZE_T(MemoryLayout<HANDLE>.size * newCount),
                    nil,
                    nil
                )
            else {
                throw .create(Error_Primitives.Error.captureLastError())
            }
        }
    }

#endif
