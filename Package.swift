import PackageDescription

let package = Package(
    name: "ReverseJson",
    targets: [
        Target(name: "ReverseJsonCore", dependencies: []),
        Target(name: "ReverseJsonObjc", dependencies: ["ReverseJsonCore"]),
        Target(name: "ReverseJsonModelExport", dependencies: ["ReverseJsonCore"]),
        Target(name: "ReverseJsonSwift", dependencies: ["ReverseJsonCore"]),
        Target(name: "ReverseJsonCommandLine", dependencies: ["ReverseJsonCore", "ReverseJsonObjc", "ReverseJsonModelExport", "ReverseJsonSwift", "ReverseJsonSwift"]),
        Target(name: "ReverseJsonSwagger", dependencies: ["ReverseJsonCore"]),
        Target(name: "ReverseJson", dependencies: ["ReverseJsonCommandLine"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/tomquist/CoreJSON.git", "1.0.0")
    ]
)
