// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "ReverseJson",
    products: [
        .executable(name: "ReverseJson", targets: ["ReverseJson"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tomquist/CoreJSON.git", from: "2.0.0")
    ],
    targets: [
        .target(name: "ReverseJsonCore", dependencies: ["CoreJSON"]),
        .target(name: "ReverseJsonObjc", dependencies: ["ReverseJsonCore"]),
        .target(name: "ReverseJsonModelExport", dependencies: ["ReverseJsonCore"]),
        .target(name: "ReverseJsonSwift", dependencies: ["ReverseJsonCore"]),
        .target(name: "ReverseJsonCommandLine", dependencies: ["ReverseJsonCore", "ReverseJsonObjc", "ReverseJsonModelExport", "ReverseJsonSwift"]),
        .target(name: "ReverseJsonSwagger", dependencies: ["ReverseJsonCore"]),
        .target(name: "ReverseJson", dependencies: ["ReverseJsonCommandLine"]),
        .testTarget(name: "ReverseJsonCoreTests", dependencies: ["ReverseJsonCore"]),
        .testTarget(name: "ReverseJsonObjcTests", dependencies: ["ReverseJsonObjc"]),
        .testTarget(name: "ReverseJsonModelExportTests", dependencies: ["ReverseJsonModelExport"]),
        .testTarget(name: "ReverseJsonSwiftTests", dependencies: ["ReverseJsonSwift"]),
        .testTarget(name: "ReverseJsonCommandLineTests", dependencies: ["ReverseJsonCommandLine"]),
    ]
)
