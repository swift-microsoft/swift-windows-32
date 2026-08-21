public import Cardinal_Primitives
public import Tagged_Primitives

extension Windows.`32`.Kernel {

    public enum Link {}
}

extension Windows.`32`.Kernel.Link {

    public typealias Count = Tagged<Windows.`32`.Kernel.Link, Cardinal>
}
