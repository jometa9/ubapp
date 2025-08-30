// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "UnplugBlock",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "UnplugBlock",
            targets: ["UnplugBlock"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "UnplugBlock",
            path: "UnplugBlock",
            exclude: [
                "Info.plist",
                "UnplugBlock.entitlements"
            ],
                               sources: [
                       "main.swift",
                       "AppDelegate.swift",
                       "PowerMonitor.swift"
                   ],
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
