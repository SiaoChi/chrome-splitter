// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ChromeSplitter",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "ChromeSplitter",
            targets: ["ChromeSplitter"]
        )
    ],
    targets: [
        .executableTarget(
            name: "ChromeSplitter",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("ApplicationServices"),
                .linkedFramework("Carbon")
            ]
        )
    ]
)
