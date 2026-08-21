#if os(Windows)
    public import Error_Primitives

    extension Windows.`32`.Kernel.IO {

        public enum Completion {}
    }

#endif
