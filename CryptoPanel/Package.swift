// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CryptoPanel",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "CryptoPanel",
            targets: ["CryptoPanel"]),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "CryptoPanel",
            dependencies: []),
    ]
)

