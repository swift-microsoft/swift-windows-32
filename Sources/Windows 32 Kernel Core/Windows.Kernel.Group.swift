public import Tagged

extension Windows.`32`.Kernel {

    public enum Group: Sendable {}
}

extension Windows.`32`.Kernel.Group {

    public typealias ID = Tagged<Windows.`32`.Kernel.Group, UInt32>
}

extension Tagged where Tag == Windows.`32`.Kernel.Group, Underlying == UInt32 {

    public static var root: Self { .zero }
}
