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
    let command = (Process.arguments.first! as NSString).lastPathComponent ?? ""
    return [
        "Usage: \(command) (swift|objc) NAME FILE",
        "e.g. \(command) swift User testModel.json",
        ].joinWithSeparator("\n")
}

func main(args: [String]) -> ProgramResult {
    guard args.count >= 4 else {
        return .Failure(usage())
    }
    let language = args[1]
    let name = args[2]
    let file = args[3]
    let remainingArgs = args.suffixFrom(4).map {$0}
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
    
    let model: AnyObject
    do {
        model = try NSJSONSerialization.JSONObjectWithData(data, options: [])
    } catch {
        return .Failure("Could not parse json: \((error as NSError).localizedDescription)")
    }
    let rootType: ModelParser.FieldType
    do {
        rootType = try ModelParser().decode(model)
    } catch {
        return .Failure("Could convert json to model: \((error as NSError).localizedDescription)")
    }
    let translators = translatorTypes.lazy.map { $0.init(args: remainingArgs) }
    return .Success(translators.map { $0.translate(rootType, name: name) }.joinWithSeparator("\n\n"))
}


switch main(Process.arguments) {
case let .Success(output):
    print(output)
    exit(0)
case let .Failure(output):
    print(output)
    exit(1)
}
