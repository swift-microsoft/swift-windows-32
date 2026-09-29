#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.Pipe {

        public struct Named {
            private init() {}
        }
    }

    extension Windows.`32`.Kernel.Pipe.Named {

        public struct OpenMode: OptionSet, Sendable {
            public let rawValue: DWORD

            public init(rawValue: DWORD) {
                self.rawValue = rawValue
            }
        }

        public struct PipeMode: OptionSet, Sendable {
            public let rawValue: DWORD

            public init(rawValue: DWORD) {
                self.rawValue = rawValue
            }
        }
    }

    extension Windows.`32`.Kernel.Pipe.Named.OpenMode {

        public static let accessDuplex = Self(rawValue: DWORD(PIPE_ACCESS_DUPLEX))

        public static let accessInbound = Self(rawValue: DWORD(PIPE_ACCESS_INBOUND))

        public static let accessOutbound = Self(rawValue: DWORD(PIPE_ACCESS_OUTBOUND))

        public static let overlapped = Self(rawValue: DWORD(FILE_FLAG_OVERLAPPED))

        public static let writeThrough = Self(rawValue: DWORD(FILE_FLAG_WRITE_THROUGH))

        public static let firstPipeInstance = Self(rawValue: DWORD(FILE_FLAG_FIRST_PIPE_INSTANCE))
    }

    extension Windows.`32`.Kernel.Pipe.Named.PipeMode {

        public static let typeByte = Self(rawValue: DWORD(PIPE_TYPE_BYTE))

        public static let typeMessage = Self(rawValue: DWORD(PIPE_TYPE_MESSAGE))

        public static let readModeByte = Self(rawValue: DWORD(PIPE_READMODE_BYTE))

        public static let readModeMessage = Self(rawValue: DWORD(PIPE_READMODE_MESSAGE))

        public static let wait = Self(rawValue: DWORD(PIPE_WAIT))

        public static let noWait = Self(rawValue: DWORD(PIPE_NOWAIT))

        public static let acceptRemoteClients = Self(rawValue: DWORD(PIPE_ACCEPT_REMOTE_CLIENTS))

        public static let rejectRemoteClients = Self(rawValue: DWORD(PIPE_REJECT_REMOTE_CLIENTS))

        public static let defaultByte: Self = [.typeByte, .readModeByte, .wait]

        public static let defaultMessage: Self = [.typeMessage, .readModeMessage, .wait]
    }

    extension Windows.`32`.Kernel.Pipe.Named {

        public static func create(
            name: UnsafePointer<WCHAR>,
            openMode: OpenMode = .accessDuplex,
            pipeMode: PipeMode = .defaultByte,
            maxInstances: DWORD = DWORD(PIPE_UNLIMITED_INSTANCES),
            outBufferSize: DWORD = 4096,
            inBufferSize: DWORD = 4096,
            defaultTimeout: DWORD = 0
        ) throws(Windows.`32`.Kernel.Pipe.Error) -> Windows.`32`.Kernel.Descriptor {
            let handle = CreateNamedPipeW(
                name,
                openMode.rawValue,
                pipeMode.rawValue,
                maxInstances,
                outBufferSize,
                inBufferSize,
                defaultTimeout,
                nil
            )

            guard handle != INVALID_HANDLE_VALUE else {
                throw .current()
            }

            return Windows.`32`.Kernel.Descriptor(_raw: UInt(bitPattern: handle))
        }

        package static func connect(
            _ handle: UInt
        ) throws(Windows.`32`.Kernel.Pipe.Error) -> Bool {
            if ConnectNamedPipe(UnsafeMutableRawPointer(bitPattern: handle)!, nil) {
                return true
            }

            let error = GetLastError()
            if error == DWORD(ERROR_PIPE_CONNECTED) {
                return false
            }

            throw .platform(Error::Error(code: .win32(error)))
        }

        package static func disconnect(
            _ handle: UInt
        ) throws(Windows.`32`.Kernel.Pipe.Error) {
            guard DisconnectNamedPipe(UnsafeMutableRawPointer(bitPattern: handle)!) else {
                throw .current()
            }
        }

        public static func connect(
            _ pipe: borrowing Windows.`32`.Kernel.Descriptor
        ) throws(Windows.`32`.Kernel.Pipe.Error) -> Bool {
            try connect(pipe._rawValue)
        }

        public static func disconnect(
            _ pipe: borrowing Windows.`32`.Kernel.Descriptor
        ) throws(Windows.`32`.Kernel.Pipe.Error) {
            try disconnect(pipe._rawValue)
        }
    }

    extension Windows.`32`.Kernel.Pipe.Named {

        public static func open(
            name: UnsafePointer<WCHAR>,
            access: Windows.`32`.Kernel.File.Open.Mode = .readWrite
        ) throws(Windows.`32`.Kernel.Pipe.Error) -> Windows.`32`.Kernel.Descriptor {
            let handle = CreateFileW(
                name,
                access.windowsDesiredAccess,
                0,
                nil,
                DWORD(OPEN_EXISTING),
                0,
                nil
            )

            guard handle != INVALID_HANDLE_VALUE else {
                throw .current()
            }

            return Windows.`32`.Kernel.Descriptor(_raw: UInt(bitPattern: handle))
        }

        public static func wait(
            name: UnsafePointer<WCHAR>,
            timeout: DWORD = DWORD(NMPWAIT_WAIT_FOREVER)
        ) -> Bool {
            WaitNamedPipeW(name, timeout)
        }
    }

    extension Windows.`32`.Kernel.Pipe.Named {

        package static func getInfo(_ handle: UInt) -> (current: DWORD, max: DWORD)? {
            var flags: DWORD = 0
            var outBufferSize: DWORD = 0
            var inBufferSize: DWORD = 0
            var maxInstances: DWORD = 0

            let pipePtr = UnsafeMutableRawPointer(bitPattern: handle)!
            guard GetNamedPipeInfo(pipePtr, &flags, &outBufferSize, &inBufferSize, &maxInstances)
            else {
                return nil
            }

            var state: DWORD = 0
            var curInstances: DWORD = 0
            guard GetNamedPipeHandleStateW(pipePtr, &state, &curInstances, nil, nil, nil, 0) else {
                return (0, maxInstances)
            }

            return (curInstances, maxInstances)
        }

        package static func peek(
            _ handle: UInt,
            into buffer: UnsafeMutableRawBufferPointer? = nil
        ) -> (read: DWORD, available: DWORD, leftInMessage: DWORD)? {
            var bytesRead: DWORD = 0
            var totalAvailable: DWORD = 0
            var leftInMessage: DWORD = 0

            let result = PeekNamedPipe(
                UnsafeMutableRawPointer(bitPattern: handle)!,
                buffer?.baseAddress,
                DWORD(buffer?.count ?? 0),
                &bytesRead,
                &totalAvailable,
                &leftInMessage
            )

            guard result else { return nil }
            return (bytesRead, totalAvailable, leftInMessage)
        }

        package static func getInfo(
            _ pipe: borrowing Windows.`32`.Kernel.Descriptor
        ) -> (current: DWORD, max: DWORD)? {
            getInfo(pipe._rawValue)
        }

        public static func peek(
            _ pipe: borrowing Windows.`32`.Kernel.Descriptor,
            into buffer: UnsafeMutableRawBufferPointer? = nil
        ) -> (read: DWORD, available: DWORD, leftInMessage: DWORD)? {
            peek(pipe._rawValue, into: buffer)
        }
    }

#endif
