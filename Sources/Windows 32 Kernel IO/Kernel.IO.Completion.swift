#if os(Windows)
    public import Error

    extension Windows.`32`.Kernel.IO {

        public enum Completion {}
    }

#endif
