// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DesktopWindow",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "DesktopWindow", targets: ["DesktopWindow"])
    ],
    targets: [
        .target(name: "DesktopWindowCore"),
        .executableTarget(
            name: "DesktopWindow",
            dependencies: ["DesktopWindowCore"],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("WebKit")
            ]
        ),
        .testTarget(
            name: "DesktopWindowCoreTests",
            dependencies: ["DesktopWindowCore"]
        )
    ]
)
