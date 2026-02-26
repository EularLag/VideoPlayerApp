// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VideoPlayerApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "VideoPlayerApp", targets: ["VideoPlayerApp"])
    ],
    targets: [
        .executableTarget(
            name: "VideoPlayerApp",
            path: "VideoPlayerApp",
            exclude: ["Resources/Info.plist"],
            sources: [
                "VideoPlayerApp.swift",
                "Models",
                "ViewModels",
                "Views",
                "Utilities"
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        )
    ]
)
