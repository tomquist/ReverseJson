import Foundation
import ReverseJsonCore
import ReverseJsonSwift
import ReverseJsonObjc
import ReverseJsonModelExport
import CoreJSON
import CoreJSONFoundation

public enum ReverseJsonError: Error {
    case wrongArgumentCount
    case outputDirectoryDoesNotExist(String)
    case outputPathIsNoDirectory(String)
    case unsupportedLanguage(String)
    case unableToRead(file: String, Error)
    case unableToParseFile(error: Error)
}

extension Bool {
    fileprivate var boolValue: Bool {
        return self
    }
}

public struct ReverseJson: CommandLineArgumentsConvertible {
    
    public var translator: ModelTranslator
    public var json: Any
    public var modelName: String
    public var modelGenerator: ModelGenerator
    public var writeToConsole: Bool
    public var outputDirectory: String
    
    public init(json: Any, modelName: String, modelGenerator: ModelGenerator, translator: ModelTranslator, writeToConsole: Bool, outputDirectory: String) {
        self.json = json
        self.modelName = modelName
        self.modelGenerator = modelGenerator
        self.translator = translator
        self.writeToConsole = writeToConsole
        self.outputDirectory = outputDirectory
    }
    
    public static func usage(command: String = CommandLine.arguments[0]) -> String {
        let pathComponents = command.characters.split(separator: "/")
        let exec = pathComponents.last.map(String.init)!
        return [
            "Usage: \(exec) (swift|objc|export) NAME FILE <options>",
            "e.g. \(exec) swift User testModel.json <options>",
            "Options:",
            "   -v,  --verbose          Print result instead of creating files",
            "   -o,  --out <dir>        Output directory (default is current directory)",
            "   -c,  --class            (Swift) Use classes instead of structs for objects",
            "   -ca, --contiguousarray  (Swift) Use ContiguousArray for lists",
            "   -pt, --publictypes      (Swift) Make type declarations public instead of internal",
            "   -pf, --publicfields     (Swift) Make field declarations public instead of internal",
            "   -n,  --nullable         (Swift and Objective-C) Make all field declarations optional (nullable in Objective-C)",
            "   -m,  --mutable          (Swift and Objective-C) All object fields are mutable (var instead of",
            "                           let in Swift and 'readwrite' instead of 'readonly' in Objective-C)",
            "   -a,  --atomic           (Objective-C) Make properties 'atomic'",
            "   -p, --prefix <prefix>   (Objective-C) Class-prefix to use for type declarations",
            "   -r, --reversemapping    (Objective-C) Create method for reverse mapping (toJson)",
        ].joined(separator: "\n")
    }
    
    public func main() throws -> String {
        let model = try JSON(foundation: json)
        let rootType: FieldType
        if ModelExportTranslator.isSchema(model) {
            rootType = try FieldType(json: model)
        } else {
            rootType = modelGenerator.decode(model)
        }
        if writeToConsole {
            return translator.translate(rootType, name: modelName)
        }
        
        
        let files: [TranslatorOutput] = translator.translate(rootType, name: modelName)
        let baseUrl = URL(fileURLWithPath: outputDirectory, isDirectory: true)
        var isDir: ObjCBool = false
        if !FileManager.default.fileExists(atPath: baseUrl.path, isDirectory: &isDir) {
            throw ReverseJsonError.outputDirectoryDoesNotExist(outputDirectory)
        }
        if !isDir.boolValue {
            throw ReverseJsonError.outputPathIsNoDirectory(outputDirectory)
        }
        var output = ""
        let count = files.reduce(0) { count, file in
            let fileUrl = baseUrl.appendingPathComponent(file.name, isDirectory: false)
            output += "Writing \(fileUrl.path)"
            defer { output += "\n" }
            do {
                try file.content.data(using: .utf8)?.write(to: fileUrl)
                return count + 1
            } catch {
                output += " (FAILED: \(error))"
                return count
            }
        }
        return output + "Wrote \(count) files"
    }
    
}
