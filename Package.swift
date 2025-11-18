// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MicDrop",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "MicDrop",
            targets: ["MicDrop"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "MicDrop",
            dependencies: ["KeyboardShortcuts"],
            path: "Sources/MicDrop",
            exclude: ["Info.plist"]
        )
    ]
)
