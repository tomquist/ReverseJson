//
//  main.swift
//  ReverseJson
//
//  Created by Tom Quist on 07.02.16.
//  Copyright © 2016 Tom Quist. All rights reserved.
//

import Foundation

enum ProgramResult {
    case success(String)
    case failure(String)
}

func usage() -> String {
    let command = ProcessInfo.processInfo.arguments[0].characters.split(separator: "/").last.map(String.init) ?? ""
    return String(lines:
        "Usage: \(command) (swift|objc) NAME FILE <options>",
        "e.g. \(command) swift User testModel.json <options>",
        "Options:",
        "   -c,  --class            (Swift) Use classes instead of structs for objects",
        "   -ca, --contiguousarray  (Swift) Use ContiguousArray for lists",
        "   -pt, --publictypes      (Swift) Make type declarations public instead of internal",
        "   -pf, --publicfields     (Swift) Make field declarations public instead of internal",
        "   -n,  --nullable         (Swift and Objective-C) Make all field declarations optional (nullable in Objective-C)",
        "   -m,  --mutable          (Swift and Objective-C) All object fields are mutable (var instead of",
        "                           let in Swift and 'readwrite' instead of 'readonly' in Objective-C)",
        "   -a,  --atomic           (Objective-C) Make properties 'atomic'",
        "   -p <prefix>             (Objective-C) Class-prefix to use for type declarations",
        "   --prefix <prefix>       "
    )
}

func main(with args: [String]) -> ProgramResult {
    guard args.count >= 4 else {
        return .failure(usage())
    }
    let language = args[1]
    let name = args[2]
    let file = args[3]
    let remainingArgs = args.suffix(from: 4).map {$0}
    let translatorTypes: [ModelTranslator.Type]
    switch language {
    case "swift":
        translatorTypes = [SwiftTranslator.self]
    case "objc":
        translatorTypes = [ObjcModelCreator.self]
    default:
        return .failure("Unsupported language \(language)")
    }
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: file)) else {
        return .failure("Could not read file \(file)")
    }
    
    let model: JSON
    do {
        let parsed = try JSONSerialization.jsonObject(with: data, options: [])
        model = try FoundationJSONTransformer().transform(parsed)
    } catch {
        return .failure("Could not parse json: \(error)")
    }
    
    let rootType: FieldType
    let rootTypeTmp = ModelGenerator().decode(model)
    let makeAllFieldDeclarationsOptional = remainingArgs.contains("-n") || remainingArgs.contains("--nullable")
    if makeAllFieldDeclarationsOptional {
        rootType = ModelGenerator.transformAllFieldsToOptional(rootTypeTmp)
    } else {
        rootType = rootTypeTmp
    }
    let translators = translatorTypes.lazy.map { $0.init(args: remainingArgs) }
    return .success(String(joined: translators.map { $0.translate(rootType, name: name) }, separator: "\n\n"))
}

switch main(with: ProcessInfo.processInfo.arguments) {
case let .success(output):
    print(output)
    exit(0)
case let .failure(output):
    print(output)
    exit(1)
}
