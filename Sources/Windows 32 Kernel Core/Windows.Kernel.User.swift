public import Tagged_Primitives

extension Windows.`32`.Kernel {

    public enum User: Sendable {}
}

extension Windows.`32`.Kernel.User {

    public typealias ID = Tagged<Windows.`32`.Kernel.User, UInt32>
}

extension Tagged where Tag == Windows.`32`.Kernel.User, Underlying == UInt32 {

    public static var root: Self { .zero }
}
