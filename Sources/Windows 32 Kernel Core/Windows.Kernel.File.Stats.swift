extension Windows.`32`.Kernel.File {

    public struct Stats: Sendable, Equatable {

        public let size: Windows.`32`.Kernel.File.Size

        public let type: Kind

        public let permissions: Windows.`32`.Kernel.File.Permissions

        public let uid: Windows.`32`.Kernel.User.ID

        public let gid: Windows.`32`.Kernel.Group.ID

        public let inode: Windows.`32`.Kernel.Inode

        public let device: Windows.`32`.Kernel.Device

        public let linkCount: Windows.`32`.Kernel.Link.Count

        public let accessTime: Windows.`32`.Kernel.Time

        public let modificationTime: Windows.`32`.Kernel.Time

        public let changeTime: Windows.`32`.Kernel.Time

        @inlinable
        public init(
            size: Windows.`32`.Kernel.File.Size,
            type: Kind,
            permissions: Windows.`32`.Kernel.File.Permissions,
            uid: Windows.`32`.Kernel.User.ID,
            gid: Windows.`32`.Kernel.Group.ID,
            inode: Windows.`32`.Kernel.Inode,
            device: Windows.`32`.Kernel.Device,
            linkCount: Windows.`32`.Kernel.Link.Count,
            accessTime: Windows.`32`.Kernel.Time,
            modificationTime: Windows.`32`.Kernel.Time,
            changeTime: Windows.`32`.Kernel.Time
        ) {
            self.size = size
            self.type = type
            self.permissions = permissions
            self.uid = uid
            self.gid = gid
            self.inode = inode
            self.device = device
            self.linkCount = linkCount
            self.accessTime = accessTime
            self.modificationTime = modificationTime
            self.changeTime = changeTime
        }
    }
}
