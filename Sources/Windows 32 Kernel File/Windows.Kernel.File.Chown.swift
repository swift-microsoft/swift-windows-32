#if os(Windows)
    public import Error_Primitives

    extension Windows.`32`.Kernel.File {

        public enum Chown {}
    }

    extension Windows.`32`.Kernel.File.Chown {

        public enum Error: Swift.Error, Sendable, Equatable {

            case path(Path)

            case permission(Permission)

            case io(IO)

            case platform(Error_Primitives.Error)

            public enum Path: Swift.Error, Sendable, Equatable {
                case notFound
                case tooLong
                case loop
            }

            public enum Permission: Swift.Error, Sendable, Equatable {
                case denied
                case notPermitted
                case readOnlyFilesystem
            }

            public enum IO: Swift.Error, Sendable, Equatable {
                case hardware
            }
        }
    }

    extension Windows.`32`.Kernel.File.Chown {

        public static func chown(
            path: borrowing Path.Borrowed,
            uid: Windows.`32`.Kernel.User.ID,
            gid: Windows.`32`.Kernel.Group.ID
        ) throws(Error) {
            guard uid == .root && gid == .root else {
                throw .permission(.notPermitted)
            }
        }

        public static func lchown(
            path: borrowing Path.Borrowed,
            uid: Windows.`32`.Kernel.User.ID,
            gid: Windows.`32`.Kernel.Group.ID
        ) throws(Error) {
            guard uid == .root && gid == .root else {
                throw .permission(.notPermitted)
            }
        }

        public static func fchown(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
            uid: Windows.`32`.Kernel.User.ID,
            gid: Windows.`32`.Kernel.Group.ID
        ) throws(Error) {
            guard uid == .root && gid == .root else {
                throw .permission(.notPermitted)
            }
        }
    }

#endif
