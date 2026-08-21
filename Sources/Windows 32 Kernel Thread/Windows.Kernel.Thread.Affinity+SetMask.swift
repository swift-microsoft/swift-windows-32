#if os(Windows)

    internal import WinSDK

    extension Windows.`32`.Kernel.Thread.Affinity {

        public static func setMask(
            cores: Set<Int>
        ) throws(Windows.`32`.Kernel.Thread.Affinity.Error) {
            guard let maxCPU = cores.max(), maxCPU < 64 else {
                throw .tooManyCPUs
            }

            var mask: DWORD_PTR = 0
            for cpu in cores {
                mask |= DWORD_PTR(1) << cpu
            }

            let result = unsafe SetThreadAffinityMask(GetCurrentThread(), mask)
            guard result != 0 else {
                throw .platform(.win32(GetLastError()))
            }
        }
    }

#endif
