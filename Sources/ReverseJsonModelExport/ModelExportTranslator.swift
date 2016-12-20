import ReverseJsonCore
import CoreJSON
import CoreJSONConvenience
import CoreJSONPointer
import CoreJSONFoundation
import Foundation

public struct ModelExportTranslator: ModelTranslator {
    
    public static let schemaIdentifier = "https://github.com/tomquist/ReverseJson/tree/1.2.0"
    
    public var isPrettyPrinted: Bool = true
    
    public init() {}
    
    public static func isSchema(_ json: JSON) -> Bool {
        guard case let .object(props) = json else { return false }
        guard case let .string(schemaIdentifier)? = props["$schema"] else { return false }
        return schemaIdentifier == ModelExportTranslator.schemaIdentifier
    }
    
    public func translate(_ type: FieldType, name: String) -> [TranslatorOutput] {
        let json = type.toJSON(isRoot: true)
        let foundationJson = json.toFoundation()
        do {
            var options: JSONSerialization.WritingOptions = []
            if isPrettyPrinted {
                options.insert(.prettyPrinted)
            }
            let data = try JSONSerialization.data(withJSONObject: foundationJson, options: options)
            guard let jsonString = String(data: data, encoding: .utf8) else { return [] }
            return [TranslatorOutput(name: "\(name)-model.json", content: jsonString)]
        } catch {
            return []
        }
    }

}

extension NumberType {
    fileprivate var typeName: String {
        return self.rawValue.lowercased()
    }
}

extension FieldType {
    
    private var typeName: String {
        switch self {
        case .text: return "string"
        case let .number(numberType): return numberType.typeName
        case .unknown: return "any"
        case let .optional(type): return type.typeName
        case .list: return "list"
        case .enum: return "any"
        case .object: return "object"
        }
    }
    
    
    public func toJSON(isRoot: Bool = false) -> JSON {
        var ret = [String: JSON]()
        if isRoot {
            ret["$schema"] = .string(ModelExportTranslator.schemaIdentifier)
        }
        ret["type"] = .string(typeName)
        if isOptional {
            ret["isOptional"] = .bool(true)
        }
        switch self.unwrapOptional {
        case .text, .number, .unknown, .optional: break
        case let .object(name, fields):
            var properties: [String: JSON] = [:]
            fields.forEach {
                properties[$0.name] = $0.type.toJSON()
            }
            if let name = name {
                ret["name"] = .string(name)
            }
            if properties.count > 0 {
                ret["properties"] = .object(properties)
            }
        case let .enum(name, cases):
            if let name = name {
                ret["name"] = .string(name)
            }
            if cases.count > 0 {
                ret["of"] = .array(cases.sorted { $0.enumCaseName < $1.enumCaseName }.map { $0.toJSON() })
            }
        case let .list(type):
            ret["content"] = type.toJSON()
        }
        // Simplification for type-only models
        if ret.count == 1, let type = ret["type"] {
            return type
        }
        // Simplification for optional type-only models
        if ret.count == 2, case let .string(type)? = ret["type"],
            case let .bool(isOptional)? = ret["isOptional"], isOptional {
            return .string("\(type)?")
        }
        var result = JSON.object(ret)
        if isRoot {
            result.flattenSchema(isRoot: true)
        }
        return result
    }
    
}

extension JSON {
    
    mutating func flattenSchema(isRoot: Bool = false) {
        var collectedTypes: [String: JSON] = [:]
        var prevCollectedTypes = collectedTypes
        flattenSchema(types: &collectedTypes)
        while collectedTypes != prevCollectedTypes {
            prevCollectedTypes = collectedTypes
            for key in collectedTypes.keys {
                collectedTypes[key]?.flattenSchema(types: &prevCollectedTypes, isDefinitions: true)
            }
        }
        if !collectedTypes.isEmpty {
            self.objectValue?["definitions"] = .object(collectedTypes)
        }
    }
    
    mutating func flattenSchema(types: inout [String: JSON], isDefinitions: Bool = false) {
        if let type = objectValue?["type"]?.stringValue {
            if type == "any", var subTypes = objectValue?["of"]?.arrayValue {
                for i in subTypes.indices {
                    subTypes[i].flattenSchema(types: &types)
                }
                objectValue?["of"] = .array(subTypes)
            } else if type == "object", let name = objectValue?["name"]?.stringValue {
                let isOptional = objectValue?["isOptional"]?.boolValue ?? false
                objectValue?["isOptional"] = nil
                types[name] = self
                if var properties = objectValue?["properties"]?.objectValue {
                    for key in properties.keys {
                        properties[key]?.flattenSchema(types: &types)
                    }
                    objectValue?["properties"] = .object(properties)
                }
                if !isDefinitions {
                    self = .object(["$ref": .string("#/definitions/\(name)")])
                    if isOptional {
                        objectValue?["isOptional"] = .bool(true)
                    }
                }
            } else if type == "list", var content = objectValue?["content"] {
                content.flattenSchema(types: &types)
                objectValue?["content"] = content
            }
        }
    }
    
}

extension FieldType {

    public enum JSONConvertionError: Error {
        case missingParameter(String)
        case invalidType(String)
        case unexpectedPropertyType(JSON)
    }
    
    public init(json: JSON) throws {
        self = try FieldType(json: json, rootJson: json)
    }
    
    private init(json: JSON, rootJson: JSON) throws {
        func from(typeString: String, props: [String: JSON]) throws -> FieldType {
            var typeString = typeString
            if typeString.hasSuffix("?") {
                typeString = typeString.substring(to: typeString.index(before: typeString.endIndex))
            }
            switch typeString {
            case "string": return .text
            case "bool": return .number(.bool)
            case "int": return .number(.int)
            case "double": return .number(.double)
            case "float": return .number(.float)
            case "object":
                let jsonFields: [String: JSON]
                if case let .object(f)? = props["properties"] {
                    jsonFields = f
                } else {
                    jsonFields = [:]
                }
                let fields = try jsonFields.map { name, propertyModel in
                    return ObjectField(name: name, type: try FieldType(json: propertyModel, rootJson: rootJson))
                }
                let objectName: String?
                if case let .string(name)? = props["name"] {
                    objectName = name
                } else {
                    objectName = nil
                }
                return .object(name: objectName, Set(fields))
            case "any":
                let jsonCases: [JSON]
                if case let .array(c)? = props["of"] {
                    jsonCases = c
                } else {
                    jsonCases = []
                }
                let name: String?
                if case let .string(jsonName)? = props["name"] {
                    name = jsonName
                } else {
                    name = nil
                }
                guard !jsonCases.isEmpty else {
                    return .unknown(name: name)
                }
                let cases = try jsonCases.map { try FieldType(json: $0, rootJson: rootJson) }
                return .enum(name: name, Set(cases))
            case "list":
                let content = try props["content"].map { try FieldType(json: $0, rootJson: rootJson) } ?? .unnamedUnknown
                return .list(content)
            default:
                throw JSONConvertionError.invalidType(typeString)
            }
        }
        switch json {
        case let .string(string):
            let fieldType = try from(typeString: string, props: [:])
            if string.hasSuffix("?") {
                self = .optional(fieldType)
            } else {
                self = fieldType
            }
        case var .object(props):
            if case let .string(reference)? = props["$ref"],
                let refUri = URL(string: reference),
                let fragment = refUri.fragment,
                let jsonPointer = JSONPointer(string: fragment),
                let declaration = rootJson[jsonPointer] {
                var fieldType = try FieldType(json: declaration, rootJson: rootJson)
                switch fieldType {
                case let .enum(name: nil, subtypes):
                    fieldType = .enum(name: jsonPointer.lastPathComponent, subtypes)
                case let .object(name: nil, fields):
                    fieldType = .object(name: jsonPointer.lastPathComponent, fields)
                default:
                    break
                }
                self = fieldType
                if case let .bool(isOptional)? = props["isOptional"], isOptional && !fieldType.isOptional {
                    self = .optional(fieldType)
                }
                return
            }
            guard case let .string(typeString)? = props["type"] else {
                throw JSONConvertionError.missingParameter("type")
            }
            props["type"] = nil
            let fieldType = try from(typeString: typeString, props: props)
            if case .bool(true)? = props["isOptional"] {
                self = .optional(fieldType)
            } else if typeString.hasSuffix("?") {
                self = .optional(fieldType)
            } else {
                self = fieldType
            }
        default:
            throw JSONConvertionError.unexpectedPropertyType(json)
        }
    }

}
