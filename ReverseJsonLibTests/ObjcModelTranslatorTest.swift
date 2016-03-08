//
//  ObjcModelTranslatorTest.swift
//  ReverseJson
//
//  Created by Tom Quist on 08.03.16.
//  Copyright © 2016 Tom Quist. All rights reserved.
//

import XCTest
@testable import ReverseJsonLib

class ObjcModelTranslatorTest: XCTestCase {
    
    func testSimpleString() {
        let type: ModelParser.FieldType = .Text
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "SimpleText")
        XCTAssertEqual("#import <Foundation/Foundation.h>", modelResult)
    }
    
    func testSimpleInt() {
        let type: ModelParser.FieldType = .Number(.Int)
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("#import <Foundation/Foundation.h>", modelResult)
    }

    func testSimpleFloat() {
        let type: ModelParser.FieldType = .Number(.Float)
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("#import <Foundation/Foundation.h>", modelResult)
    }
    
    func testSimpleDouble() {
        let type: ModelParser.FieldType = .Number(.Double)
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("#import <Foundation/Foundation.h>", modelResult)
    }
    
    func testBoolDouble() {
        let type: ModelParser.FieldType = .Number(.Bool)
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("#import <Foundation/Foundation.h>", modelResult)
    }
    
    func testEmptyObject() {
        let type: ModelParser.FieldType = .Object([])
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual([
            "#import <Foundation/Foundation.h>",
            "",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "",
            "@implementation TestObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dict {",
            "    self = [super init];",
            "    if (self) {",
            "    }",
            "    return self;",
            "}",
            "- (instancetype)initWithJsonValue:(id)jsonValue {",
            "    if ([jsonValue isKindOfClass:[NSDictionary class]]) {",
            "        self = [self initWithJsonDictionary:jsonValue];",
            "    } else {",
            "        self = nil;",
            "    }",
            "    return self;",
            "}",
            "@end"
        ].joinWithSeparator("\n"), modelResult)
    }
    
    func testEmptyEnum() {
        let type: ModelParser.FieldType = .Enum([])
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual([
            "#import <Foundation/Foundation.h>",
            "",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "",
            "@implementation TestObject",
            "- (instancetype)initWithJsonValue:(id)jsonValue {",
            "    self = [super init];",
            "    if (self) {",
            "    }",
            "    return self;",
            "}",
            "@end"
        ].joinWithSeparator("\n"), modelResult)
    }
    
    func testTextList() {
        let type: ModelParser.FieldType = .List(.Text)
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "TextList")
        XCTAssertEqual("#import <Foundation/Foundation.h>", modelResult)
    }
    
    func testUnknownType() {
        let type: ModelParser.FieldType = .Unknown
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual("#import <Foundation/Foundation.h>", modelResult)
    }
    
    func testListOfEmptyObject() {
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(.List(.Object([])), name: "TestObjectList")
        XCTAssertEqual([
            "#import <Foundation/Foundation.h>",
            "",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObjectListItem : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "",
            "@implementation TestObjectListItem",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dict {",
            "    self = [super init];",
            "    if (self) {",
            "    }",
            "    return self;",
            "}",
            "- (instancetype)initWithJsonValue:(id)jsonValue {",
            "    if ([jsonValue isKindOfClass:[NSDictionary class]]) {",
            "        self = [self initWithJsonDictionary:jsonValue];",
            "    } else {",
            "        self = nil;",
            "    }",
            "    return self;",
            "}",
            "@end"
        ].joinWithSeparator("\n"), modelResult)
    }
    func testObjectWithSingleTextField() {
        let type: ModelParser.FieldType = .Object([.init(name: "text", type: .Text)])
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual([
            "#import <Foundation/Foundation.h>",
            "",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@property (nonatomic, copy, readonly) NSString *text;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "",
            "@implementation TestObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dict {",
            "    self = [super init];",
            "    if (self) {",
            "        _text = [dict[@\"text\"] isKindOfClass:[NSString class]] ? dict[@\"text\"] : nil;",
            "    }",
            "    return self;",
            "}",
            "- (instancetype)initWithJsonValue:(id)jsonValue {",
            "    if ([jsonValue isKindOfClass:[NSDictionary class]]) {",
            "        self = [self initWithJsonDictionary:jsonValue];",
            "    } else {",
            "        self = nil;",
            "    }",
            "    return self;",
            "}",
            "@end"
        ].joinWithSeparator("\n"), modelResult)
    }
    
    func testObjectWithFieldContainingListOfText() {
        let type: ModelParser.FieldType = .Object([.init(name: "texts", type: .List(.Text))])
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual([
            "#import <Foundation/Foundation.h>",
            "",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@property (nonatomic, strong, readonly) NSArray<NSString *> *texts;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "",
            "@implementation TestObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dict {",
            "    self = [super init];",
            "    if (self) {",
            "        _texts = ({",
            "            id value = dict[@\"texts\"];",
            "            NSMutableArray<NSString *> *values = nil;",
            "            if ([value isKindOfClass:[NSArray class]]) {",
            "                NSArray *array = value;",
            "                values = [NSMutableArray arrayWithCapacity:array.count];",
            "                for (id item in array) {",
            "                    NSString *parsedItem = [item isKindOfClass:[NSString class]] ? item : nil;",
            "                    [values addObject:parsedItem ?: (id)[NSNull null]];",
            "                }",
            "            }",
            "            [values copy];",
            "        });",
            "    }",
            "    return self;",
            "}",
            "- (instancetype)initWithJsonValue:(id)jsonValue {",
            "    if ([jsonValue isKindOfClass:[NSDictionary class]]) {",
            "        self = [self initWithJsonDictionary:jsonValue];",
            "    } else {",
            "        self = nil;",
            "    }",
            "    return self;",
            "}",
            "@end"
        ].joinWithSeparator("\n"), modelResult)
    }
    
}
