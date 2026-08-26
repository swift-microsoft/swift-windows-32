#if os(Windows)
    public import Error

    extension Windows.`32`.Kernel.IO.Completion.Port {

        public enum Write {}
    }

#endif
