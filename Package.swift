// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "fileconverter",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "fileconverter",
            targets: ["FileConverterCLI"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FileConverterCore",
            dependencies: [],
            path: "Core",
            resources: [
                .copy("Resources/converters.yaml")
            ]
        ),
        .executableTarget(
            name: "FileConverterCLI",
            dependencies: ["FileConverterCore"],
            path: "CLI"
        )
    ]
)
