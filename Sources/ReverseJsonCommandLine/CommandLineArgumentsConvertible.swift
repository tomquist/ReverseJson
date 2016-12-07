import Foundation
import ReverseJsonCore
import ReverseJsonSwift
import ReverseJsonObjc

public protocol CommandLineArgumentsConvertible {
    init(consumableArgs args: inout [String]) throws
    init(args: [String]) throws
}

extension CommandLineArgumentsConvertible {
    public init(args: [String]) throws {
        var args = args
        self = try Self(consumableArgs: &args)
    }
}

extension Array where Element: Equatable {
    mutating func consume(flag: Element) -> Bool {
        if let idx = index(of: flag) {
            remove(at: idx)
            return true
        }
        return false
    }
    
    mutating func consume(value: Element) -> Element? {
        if let idx = self.index(of: value) , count > idx + 1 {
            remove(at: idx)
            return remove(at: idx)
        }
        return nil
    }
}

extension ReverseJson {
    
    public init(consumableArgs args: inout [String]) throws {
        guard args.count >= 4 else {
            throw ReverseJsonError.wrongArgumentCount
        }
        let language = args[1]
        modelName = args[2]
        let file = args[3]
        args = args.suffix(from: 4).map {$0}
        typealias CommandLineArgumentsConvertibleTranslator = (ModelTranslator & CommandLineArgumentsConvertible)
        var translatorType: CommandLineArgumentsConvertibleTranslator.Type
        switch language {
        case "swift":
            translatorType = SwiftTranslator.self
        case "objc":
            translatorType = ObjcModelCreator.self
        default:
            throw ReverseJsonError.unsupportedLanguage(language)
        }
        self.writeToConsole = args.consume(flag: "-v") || args.consume(flag: "--verbose")
        self.outputDirectory = args.consume(value: "-o") ?? args.consume(value: "--out") ?? ""
        
        let data: Data
        do {
            data = try Data(contentsOf: URL(fileURLWithPath: file))
        } catch {
            throw ReverseJsonError.unableToRead(file: file, error)
        }
        
        do {
            json = try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            throw ReverseJsonError.unableToParseFile(error: error)
        }
        
        modelGenerator = ModelGenerator(consumableArgs: &args)
        translator = try translatorType.init(consumableArgs: &args)
    }
    
}

extension SwiftTranslator: CommandLineArgumentsConvertible {
    public init(consumableArgs args: inout [String]) {
        self.init()
        objectType = args.consume(flag: "-c") || args.consume(flag: "--class") ? .classType : .structType
        listType = args.consume(flag: "-ca") || args.consume(flag: "--contiguousarray") ? .contiguousArray : .array
        mutableFields = args.consume(flag: "-m") || args.consume(flag: "--mutable")
        fieldVisibility = args.consume(flag: "-pf") || args.consume(flag: "--publicfields") ? .publicVisibility : .internalVisibility
        typeVisibility = args.consume(flag: "-pt") || args.consume(flag: "--publictypes") ? .publicVisibility : .internalVisibility
    }
}

extension ObjcModelCreator: CommandLineArgumentsConvertible {
    public init(consumableArgs args: inout [String]) {
        self.init()
        atomic = args.consume(flag: "-a") || args.consume(flag: "--atomic")
        readonly = !(args.consume(flag: "-m") || args.contains("--mutable"))
        createToJson = args.consume(flag: "-r") || args.contains("--reversemapping")
        if let prefix = (args.consume(value: "-p") ?? args.consume(value: "--prefix")) {
            typePrefix = prefix
        }
    }
}

extension ModelGenerator: CommandLineArgumentsConvertible {
    public init(consumableArgs args: inout [String]) {
        self.init()
        allFieldsOptional = args.consume(flag: "-n") || args.consume(flag: "--nullable")
    }
}
