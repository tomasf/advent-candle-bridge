// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "advent-candle-bridge",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/tomasf/Cadova.git", .upToNextMinor(from: "0.2.0")),
        .package(url: "https://github.com/tomasf/Helical.git", .upToNextMinor(from: "0.4.0")),
    ],
    targets: [
        .executableTarget(
            name: "advent-candle-bridge",
            dependencies: ["Cadova", "Helical"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ]
)
