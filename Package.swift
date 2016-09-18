import PackageDescription

let package = Package(
    name: "ReverseJson",
    targets: [
        Target(name: "ReverseJsonCore"),
        Target(name: "ReverseJsonFoundation", dependencies: ["ReverseJsonCore"]),
        Target(name: "ReverseJsonObjc", dependencies: ["ReverseJsonCore"]),
        Target(name: "ReverseJsonSwift", dependencies: ["ReverseJsonCore"]),
        Target(name: "ReverseJson", dependencies: ["ReverseJsonCore", "ReverseJsonObjc", "ReverseJsonSwift", "ReverseJsonFoundation"]),
    ],
    dependencies: []
)
