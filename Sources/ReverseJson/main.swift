//
//  main.swift
//  ReverseJson
//
//  Created by Tom Quist on 07.02.16.
//  Copyright © 2016 Tom Quist. All rights reserved.
//

import Foundation

enum ProgramResult {
    case Success(String)
    case Failure(String)
}

func usage() -> String {
    let commandArgChars = Process.arguments[0].characters
    let commandPathComponents = commandArgChars.split(separator: "/")
    let command = commandPathComponents.last.map(String.init) ?? ""
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
        return .Failure(usage())
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
        return .Failure("Unsupported language \(language)")
    }
    guard let data = NSData(contentsOfFile: file) else {
        return .Failure("Could not read file \(file)")
    }
    
    let model: Any
    do {
        model = try NSJSONSerialization.jsonObject(with: data, options: [])
    } catch {
        return .Failure("Could not parse json: \(error)")
    }
    let rootType: ModelParser.FieldType
    do {
        let rootTypeTmp = try ModelParser().decode(model)
        let makeAllFieldDeclarationsOptional = remainingArgs.contains("-n") || remainingArgs.contains("--nullable")
        if makeAllFieldDeclarationsOptional {
            rootType = ModelParser.transformAllFieldsToOptional(rootField: rootTypeTmp)
        } else {
            rootType = rootTypeTmp
        }
    } catch {
        return .Failure("Could convert json to model: \(error)")
    }
    let translators = translatorTypes.lazy.map { $0.init(args: remainingArgs) }
    return .Success(String(joined: translators.map { $0.translate(rootType, name: name) }, separator: "\n\n"))
}


switch main(with: Process.arguments) {
case let .Success(output):
    print(output)
    exit(0)
case let .Failure(output):
    print(output)
    exit(1)
}
