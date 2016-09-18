import Foundation
import ReverseJsonCore
import ReverseJsonSwift
import ReverseJsonObjc
import ReverseJsonFoundation

public enum ReverseJsonError: Error {
    case wrongArgumentCount
    case unsupportedLanguage(String)
    case unableToRead(file: String, Error)
    case unableToParseFile(error: Error)
}

public struct ReverseJson: CommandLineArgumentsConvertible {
    
    public var translator: ModelTranslator
    public var json: Any
    public var modelName: String
    public var modelGenerator: ModelGenerator
    
    public init(json: Any, modelName: String, modelGenerator: ModelGenerator, translator: ModelTranslator) {
        self.json = json
        self.modelName = modelName
        self.modelGenerator = modelGenerator
        self.translator = translator
    }
    
    public init(args: [String]) throws {
        guard args.count >= 4 else {
            throw ReverseJsonError.wrongArgumentCount
        }
        let language = args[1]
        modelName = args[2]
        let file = args[3]
        let remainingArgs = args.suffix(from: 4).map {$0}
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
        
        modelGenerator = ModelGenerator(args: remainingArgs)
        translator = try translatorType.init(args: remainingArgs)
    }
    
    public static func usage(command: String = CommandLine.arguments[0]) -> String {
        let pathComponents = command.characters.split(separator: "/")
        let exec = pathComponents.last.map(String.init)!
        return [
            "Usage: \(exec) (swift|objc) NAME FILE <options>",
            "e.g. \(exec) swift User testModel.json <options>",
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
        ].joined(separator: "\n")
    }
    
    public func main() throws -> String {
        let model = try FoundationJSONTransformer().transform(json)
        let rootType = modelGenerator.decode(model)
        return translator.translate(rootType, name: modelName)
    }
    
}
