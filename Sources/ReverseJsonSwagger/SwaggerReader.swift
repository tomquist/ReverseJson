//
//  SchemaImport.swift
//  ReverseJson
//
//  Created by Tom Quist on 07.02.16.
//  Copyright © 2016 Tom Quist. All rights reserved.
//

import Foundation
import ReverseJsonCore
import CoreJSON
import CoreJSONConvenience
import CoreJSONPointer

public enum SwaggerReadingError: Error {
    case missingParameter(String)
    case invalidType(String)
    case unexpectedPropertyType(JSON)
}

public struct SwaggerReader {
    
    private let rootJSON: JSON
    
    public init(json: JSON) {
        rootJSON = json
    }
    
    private func resolve(_ json: JSON) -> (JSON, String?) {
        var json = json
        if case let .string(ref)? = json.objectValue?["$ref"],
            let refUrl = URL(string: ref),
            let fragment = refUrl.fragment,
            let jsonPointer = JSONPointer(string: fragment),
            let refObject = rootJSON[jsonPointer] {
            return (refObject, jsonPointer.lastPathComponent)
        }
        return (json, nil)
    }
    
    private func from(responses json: JSON, path: String, method: String) throws -> [FieldType] {
        guard let properties = json.objectValue else {
            return []
        }
        return properties.flatMap { statusCode, object in
            let (object, refName) = resolve(object)
            let name: String
            if let refName = refName {
                name = refName
            } else {
                let cleanedPath = path.replacingOccurrences(of: "/", with: " ").trimmingCharacters(in: .whitespaces)
                name = "\(method.firstCapitalized())\(cleanedPath.camelCasedString)"
            }
            if let schema = object.objectValue?["schema"] {
                let type = try? FieldType(swaggerSchema: schema, rootJson: rootJSON)
                switch type {
                case let .enum(name: nil, subTypes)?:
                    return .enum(name: name, subTypes)
                case let .object(name: nil, fields)?:
                    return .object(name: name, fields)
                default:
                    return type
                }
            }
            return nil
        }
    }
    
    private func from(operation json: JSON, path: String, method: String) throws -> [FieldType] {
        guard let properties = json.objectValue else {
            return []
        }
        guard let responses = properties["responses"] else {
            return []
        }
        return try from(responses: responses, path: path, method: method)
    }
    
    private func from(pathItem json: JSON, path: String) throws -> [FieldType] {
        guard let properties = json.objectValue else {
            return []
        }
        return try ["get", "put", "post", "delete", "options", "head", "patch"].flatMap { method in
            properties[method].map { (method, $0) }
        }.flatMap { method, operation in
            try from(operation: operation, path: path, method: method)
        }
    }
    
    public func allTypes() throws -> Set<FieldType> {
        guard case let .object(paths)? = rootJSON.objectValue?["paths"] else {
            throw SwaggerReadingError.missingParameter("paths")
        }
        let types = try paths.flatMap { path, value in
            try from(pathItem: value, path: path)
        }
        return Set(types)
    }
    
}

extension FieldType {
    
    fileprivate init(swaggerSchema json: JSON, rootJson: JSON) throws {
        func from(typeString: String, props: [String: JSON]) throws -> FieldType {
            switch typeString {
            case "string": return .text
            case "boolean": return .number(.bool)
            case "integer": return .number(.int)
            case "number":
                switch props["format"] {
                case .string("float")?:
                    return .number(.float)
                case .string("double")?:
                    fallthrough
                default:
                    return .number(.double)
                }
            case "object":
                let properties: [String: JSON]
                if case let .object(f)? = props["properties"] {
                    properties = f
                } else {
                    properties = [:]
                }
                let required: Set<String>
                if case let .array(jsonRequired)? = props["required"] {
                    required = Set(jsonRequired.flatMap { $0.stringValue })
                } else {
                    required = []
                }
                let fields = try properties.map { name, propertyModel -> ObjectField in
                    var type = try FieldType(swaggerSchema: propertyModel, rootJson: rootJson)
                    if !required.contains(name) {
                        type = .optional(type)
                    }
                    return ObjectField(name: name, type: type)
                }
                let objectName: String?
                if case let .string(name)? = props["name"] {
                    objectName = name
                } else {
                    objectName = nil
                }
                if properties.count == 0 {
                    return .unknown(name: objectName)
                } else {
                    return .object(name: objectName, Set(fields))
                }
            case "array":
                let content = try props["items"].map { try FieldType(swaggerSchema: $0, rootJson: rootJson) } ?? .unnamedUnknown
                return .list(content)
            default:
                throw SwaggerReadingError.invalidType(typeString)
            }
        }
        switch json {
        case let .string(string):
            self = try from(typeString: string, props: [:])
        case var .object(props):
            if case let .string(reference)? = props["$ref"],
                let refUri = URL(string: reference),
                let fragment = refUri.fragment,
                let jsonPointer = JSONPointer(string: fragment),
                let declaration = rootJson[jsonPointer] {
                var fieldType = try FieldType(swaggerSchema: declaration, rootJson: rootJson)
                switch fieldType {
                case let .enum(name: nil, subtypes):
                    fieldType = .enum(name: jsonPointer.lastPathComponent, subtypes)
                case let .object(name: nil, fields):
                    fieldType = .object(name: jsonPointer.lastPathComponent, fields)
                default:
                    break
                }
                self = fieldType
                return
            }
            guard case let .string(typeString)? = props["type"] else {
                throw SwaggerReadingError.missingParameter("type")
            }
            props["type"] = nil
            self = try from(typeString: typeString, props: props)
        default:
            throw SwaggerReadingError.unexpectedPropertyType(json)
        }
    }
    
}
