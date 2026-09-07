// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-windows-32",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [

        .library(
            name: "Windows 32 Kernel",
            targets: ["Windows 32 Kernel"]
        ),
        .library(
            name: "Windows 32 Kernel Clock",
            targets: ["Windows 32 Kernel Clock"]
        ),
        .library(
            name: "Windows 32 Kernel Lock",
            targets: ["Windows 32 Kernel Lock"]
        ),
        .library(
            name: "Windows 32 Kernel Console",
            targets: ["Windows 32 Kernel Console"]
        ),
        .library(
            name: "Windows 32 Kernel Directory",
            targets: ["Windows 32 Kernel Directory"]
        ),
        .library(
            name: "Windows 32 Kernel Environment",
            targets: ["Windows 32 Kernel Environment"]
        ),
        .library(
            name: "Windows 32 Kernel File",
            targets: ["Windows 32 Kernel File"]
        ),
        .library(
            name: "Windows 32 Kernel IO",
            targets: ["Windows 32 Kernel IO"]
        ),
        .library(
            name: "Windows 32 Kernel Terminal",
            targets: ["Windows 32 Kernel Terminal"]
        ),
        .library(
            name: "Windows 32 Kernel Memory Map",
            targets: ["Windows 32 Kernel Memory Map"]
        ),
        .library(
            name: "Windows 32 Kernel Process",
            targets: ["Windows 32 Kernel Process"]
        ),
        .library(
            name: "Windows 32 Kernel Socket",
            targets: ["Windows 32 Kernel Socket"]
        ),
        .library(
            name: "Windows 32 Kernel System",
            targets: ["Windows 32 Kernel System"]
        ),
        .library(
            name: "Windows 32 Kernel Thread",
            targets: ["Windows 32 Kernel Thread"]
        ),
        .library(
            name: "Windows 32 Kernel Time",
            targets: ["Windows 32 Kernel Time"]
        ),

        .library(
            name: "Windows 32 Identity",
            targets: ["Windows 32 Identity"]
        ),
        .library(
            name: "Windows 32 Interop",
            targets: ["Windows 32 Interop"]
        ),
        .library(
            name: "Windows 32 Loader",
            targets: ["Windows 32 Loader"]
        ),
        .library(
            name: "Windows 32 Memory",
            targets: ["Windows 32 Memory"]
        ),

        .library(
            name: "Windows 32 Kernel Test Support",
            targets: ["Windows 32 Kernel Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-memory.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory-map.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory-lock.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory-shared.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory-allocation.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-clock.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-time.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-loader-vocabulary.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-sequence.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-standard-library-extensions.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-error.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-random.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-path.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-system.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-binary.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-byte.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-spatial.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-terminal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-pair.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-equation.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-hash.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-tagged.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-cardinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-string.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Windows 32 Core",
            dependencies: []
        ),
        .target(
            name: "Windows Memory Shims",
            dependencies: []
        ),

        .target(
            name: "Windows 32 Kernel Core",
            dependencies: [
                .target(name: "Windows 32 Core"),
                .product(name: "Error", package: "swift-error"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Path", package: "swift-path"),
                .product(
                    name: "Equation Protocol",
                    package: "swift-equation"
                ),
                .product(name: "Hash Protocol", package: "swift-hash"),
                .product(name: "Time", package: "swift-time"),
                .product(name: "Spatial", package: "swift-spatial"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(
                    name: "Memory Allocation",
                    package: "swift-memory-allocation"
                ),
                .product(name: "Clock", package: "swift-clock"),
            ]
        ),

        .target(
            name: "Windows 32 Kernel Clock",
            dependencies: [
                "Windows 32 Kernel Core",
                .product(name: "Clock", package: "swift-clock"),
            ]
        ),

        .target(
            name: "Windows 32 Kernel Lock",
            dependencies: [
                "Windows 32 Kernel Core",
                "Windows 32 Kernel Clock",
                .product(name: "Clock", package: "swift-clock"),
            ]
        ),

        .target(
            name: "Windows 32 Kernel Console",
            dependencies: [
                "Windows 32 Kernel Core"
            ]
        ),

        .target(
            name: "Windows 32 Kernel Directory",
            dependencies: [
                "Windows 32 Kernel Core",
                .product(name: "Path", package: "swift-path"),
            ]
        ),

        .target(
            name: "Windows 32 Kernel Environment",
            dependencies: [
                "Windows 32 Kernel Core",
                .product(name: "Sequence", package: "swift-sequence"),
                .product(name: "Error", package: "swift-error"),
                .product(name: "String", package: "swift-string"),
            ]
        ),

        .target(
            name: "Windows 32 Kernel File",
            dependencies: [
                "Windows 32 Kernel Core",
                .product(name: "Path", package: "swift-path"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Binary", package: "swift-binary"),
                .product(name: "Spatial", package: "swift-spatial"),
                .product(name: "Pair", package: "swift-pair"),
                .product(name: "String", package: "swift-string"),
            ]
        ),

        .target(
            name: "Windows 32 Kernel IO",
            dependencies: [
                "Windows 32 Kernel Core",
                .product(name: "Byte", package: "swift-byte"),
            ]
        ),

        .target(
            name: "Windows 32 Kernel Terminal",
            dependencies: [
                "Windows 32 Kernel Core",
                "Windows 32 Kernel IO",
                .product(name: "Terminal", package: "swift-terminal"),
            ]
        ),

        .target(
            name: "Windows 32 Kernel Memory Map",
            dependencies: [
                "Windows 32 Kernel Core",
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Memory Map", package: "swift-memory-map"),
                .product(name: "Memory Lock", package: "swift-memory-lock"),
                .product(
                    name: "Memory Shared",
                    package: "swift-memory-shared"
                ),
                .product(
                    name: "Memory Allocation",
                    package: "swift-memory-allocation"
                ),
            ]
        ),

        .target(
            name: "Windows 32 Kernel Process",
            dependencies: [
                "Windows 32 Kernel Core",
                "Windows 32 Kernel File",
                .product(name: "Path", package: "swift-path"),
            ]
        ),

        .target(
            name: "Windows 32 Kernel Socket",
            dependencies: [
                "Windows 32 Kernel Core"
            ]
        ),

        .target(
            name: "Windows 32 Kernel System",
            dependencies: [
                "Windows 32 Kernel Core",
                .product(name: "System", package: "swift-system"),
                .product(name: "Random", package: "swift-random"),
            ]
        ),

        .target(
            name: "Windows 32 Kernel Thread",
            dependencies: [
                "Windows 32 Kernel Core",
                .product(name: "Error", package: "swift-error"),
            ]
        ),

        .target(
            name: "Windows 32 Kernel Time",
            dependencies: [
                "Windows 32 Kernel Core",
                "Windows 32 Kernel Clock",
            ]
        ),

        .target(
            name: "Windows 32 Kernel",
            dependencies: [
                "Windows 32 Kernel Core",
                "Windows 32 Kernel Clock",
                "Windows 32 Kernel Lock",
                "Windows 32 Kernel Console",
                "Windows 32 Kernel Directory",
                "Windows 32 Kernel Environment",
                "Windows 32 Kernel File",
                "Windows 32 Kernel IO",
                "Windows 32 Kernel Terminal",
                "Windows 32 Kernel Memory Map",
                "Windows 32 Kernel Process",
                "Windows 32 Kernel Socket",
                "Windows 32 Kernel System",
                "Windows 32 Kernel Thread",
                "Windows 32 Kernel Time",
            ]
        ),

        .target(
            name: "Windows 32 Identity",
            dependencies: [
                .target(name: "Windows 32 Core")
            ]
        ),

        .target(
            name: "Windows 32 Interop",
            dependencies: [
                .target(name: "Windows 32 Core")
            ]
        ),

        .target(
            name: "Windows 32 Loader",
            dependencies: [
                .target(name: "Windows 32 Core"),
                .product(name: "Loader", package: "swift-loader-vocabulary"),
            ]
        ),

        .target(
            name: "Windows 32 Memory",
            dependencies: [
                .target(name: "Windows 32 Core"),
                .target(name: "Windows Memory Shims", condition: .when(platforms: [.windows])),
            ]
        ),

        .target(
            name: "Windows 32 Kernel Test Support",
            dependencies: [
                "Windows 32 Kernel",
                "Windows 32 Loader",
            ],
            path: "Tests/Support"
        ),

        .testTarget(
            name: "Windows 32 Kernel Tests",
            dependencies: [
                "Windows 32 Kernel",
                "Windows 32 Kernel Test Support",
                "Windows 32 Kernel Memory Map",
                .product(
                    name: "Standard Library Extensions",
                    package: "swift-standard-library-extensions"
                ),
            ]
        ),
        .testTarget(
            name: "Windows 32 Loader Tests",
            dependencies: [
                "Windows 32 Loader",
                "Windows 32 Kernel Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
