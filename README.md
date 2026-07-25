# swift-windows-32

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Typed Swift bindings for the Win32 kernel API, split into focused products across processes, files, memory, threads, sockets, and more.

The package is modular — import the specific `Windows 32 Kernel …` product your target needs; `Windows 32 Kernel` is shown below as an example.

## Installation

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/swift-microsoft/swift-windows-32.git", branch: "main")
]
```

Add the product to a target that needs it:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Windows 32 Kernel", package: "swift-windows-32")
    ]
)
```

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
