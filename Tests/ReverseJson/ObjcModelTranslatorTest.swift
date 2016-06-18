//
//  ObjcModelTranslatorTest.swift
//  ReverseJson
//
//  Created by Tom Quist on 08.03.16.
//  Copyright © 2016 Tom Quist. All rights reserved.
//

import XCTest
@testable import ReverseJson

class ObjcModelTranslatorTest: XCTestCase {
    
    static var allTests: [(String, (ObjcModelTranslatorTest) -> () throws -> Void)] {
        return [
            ("testAtomicFieldsFlag", testAtomicFieldsFlag),
            ("testBoolDouble", testBoolDouble),
            ("testEmptyEnum", testEmptyEnum),
            ("testEmptyObject", testEmptyObject),
            ("testEnumWithOneCase", testEnumWithOneCase),
            ("testEnumWithTwoCases", testEnumWithTwoCases),
            ("testListOfEmptyObject", testListOfEmptyObject),
            ("testMutableFieldsFlag", testMutableFieldsFlag),
            ("testPrefixOption", testPrefixOption),
            ("testObjectWithDifferentFields", testObjectWithDifferentFields),
            ("testObjectWithFieldContainingListOfText", testObjectWithFieldContainingListOfText),
            ("testObjectWithOneFieldWithSubDeclaration", testObjectWithOneFieldWithSubDeclaration),
            ("testObjectWithSingleTextField", testObjectWithSingleTextField),
            ("testSimpleDouble", testSimpleDouble),
            ("testSimpleFloat", testSimpleFloat),
            ("testSimpleInt", testSimpleInt),
            ("testSimpleString", testSimpleString),
            ("testTextList", testTextList),
            ("testUnknownType", testUnknownType),
        ]
    }
    
    func testSimpleString() {
        let type: ModelParser.FieldType = .text
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "SimpleText")
        XCTAssertEqual("#import <Foundation/Foundation.h>", modelResult)
    }
    
    func testSimpleInt() {
        let type: ModelParser.FieldType = .number(.Int)
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("#import <Foundation/Foundation.h>", modelResult)
    }

    func testSimpleFloat() {
        let type: ModelParser.FieldType = .number(.Float)
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("#import <Foundation/Foundation.h>", modelResult)
    }
    
    func testSimpleDouble() {
        let type: ModelParser.FieldType = .number(.Double)
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("#import <Foundation/Foundation.h>", modelResult)
    }
    
    func testBoolDouble() {
        let type: ModelParser.FieldType = .number(.Bool)
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("#import <Foundation/Foundation.h>", modelResult)
    }
    
    func testEmptyObject() {
        let type: ModelParser.FieldType = .object([])
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
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
        ), modelResult)
    }
    
    func testEmptyEnum() {
        let type: ModelParser.FieldType = .enum([])
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
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
        ), modelResult)
    }
    
    func testTextList() {
        let type: ModelParser.FieldType = .list(.text)
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "TextList")
        XCTAssertEqual("#import <Foundation/Foundation.h>", modelResult)
    }
    
    func testUnknownType() {
        let type: ModelParser.FieldType = .unknown
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual("#import <Foundation/Foundation.h>", modelResult)
    }
    
    func testListOfEmptyObject() {
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(.list(.object([])), name: "TestObjectList")
        XCTAssertEqual(String(lines:
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
        ), modelResult)
    }
    func testObjectWithSingleTextField() {
        let type: ModelParser.FieldType = .object([.init(name: "text", type: .text)])
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
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
        ), modelResult)
    }
    
    func testObjectWithFieldContainingListOfText() {
        let type: ModelParser.FieldType = .object([.init(name: "texts", type: .list(.text))])
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
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
        ), modelResult)
    }

    func testObjectWithDifferentFields() {
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(.object([
            .init(name: "listOfListsOfText", type: .list(.list(.text))),
            .init(name: "numbers", type: .list(.number(.Int))),
            .init(name: "int", type: .number(.Int)),
            .init(name: "optionalText", type: .optional(.text))
        ]), name: "TestObject")
        XCTAssertEqual(String(lines:
            "#import <Foundation/Foundation.h>",
            "",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@property (nonatomic, strong, readonly) NSArray<NSArray<NSString *> *> *listOfListsOfText;",
            "@property (nonatomic, strong, readonly) NSArray<NSNumber/*NSInteger*/ *> *numbers;",
            "@property (nonatomic, assign, readonly) NSInteger int;",
            "@property (nonatomic, strong, readonly, nullable) NSString *optionalText;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "",
            "@implementation TestObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dict {",
            "    self = [super init];",
            "    if (self) {",
            "        _listOfListsOfText = ({",
            "            id value = dict[@\"listOfListsOfText\"];",
            "            NSMutableArray<NSArray<NSString *> *> *values = nil;",
            "            if ([value isKindOfClass:[NSArray class]]) {",
            "                NSArray *array = value;",
            "                values = [NSMutableArray arrayWithCapacity:array.count];",
            "                for (id item in array) {",
            "                    NSArray<NSString *> *parsedItem = ({",
            "                        id value = item;",
            "                        NSMutableArray<NSString *> *values = nil;",
            "                        if ([value isKindOfClass:[NSArray class]]) {",
            "                            NSArray *array = value;",
            "                            values = [NSMutableArray arrayWithCapacity:array.count];",
            "                            for (id item in array) {",
            "                                NSString *parsedItem = [item isKindOfClass:[NSString class]] ? item : nil;",
            "                                [values addObject:parsedItem ?: (id)[NSNull null]];",
            "                            }",
            "                        }",
            "                        [values copy];",
            "                    });",
            "                    [values addObject:parsedItem ?: (id)[NSNull null]];",
            "                }",
            "            }",
            "            [values copy];",
            "        });",
            "        _numbers = ({",
            "            id value = dict[@\"numbers\"];",
            "            NSMutableArray<NSNumber/*NSInteger*/ *> *values = nil;",
            "            if ([value isKindOfClass:[NSArray class]]) {",
            "                NSArray *array = value;",
            "                values = [NSMutableArray arrayWithCapacity:array.count];",
            "                for (id item in array) {",
            "                    NSNumber/*NSInteger*/ *parsedItem = [item isKindOfClass:[NSNumber class]] ? item : nil;",
            "                    [values addObject:parsedItem ?: (id)[NSNull null]];",
            "                }",
            "            }",
            "            [values copy];",
            "        });",
            "        _int = [dict[@\"int\"] isKindOfClass:[NSNumber class]] ? [dict[@\"int\"] integerValue] : 0;",
            "        _optionalText = [dict[@\"optionalText\"] isKindOfClass:[NSString class]] ? dict[@\"optionalText\"] : nil;",
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
        ), modelResult)
    }
    
    func testObjectWithOneFieldWithSubDeclaration() {
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(.object([
            .init(name: "subObject", type: .object([]))
            ]), name: "TestObject")
        XCTAssertEqual(String(lines:
            "#import <Foundation/Foundation.h>",
            "",
            "@class TestObjectSubObject;",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@property (nonatomic, strong, readonly) TestObjectSubObject *subObject;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObjectSubObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "",
            "@implementation TestObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dict {",
            "    self = [super init];",
            "    if (self) {",
            "        _subObject = [[TestObjectSubObject alloc] initWithJsonValue:dict[@\"subObject\"]];",
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
            "@end",
            "",
            "@implementation TestObjectSubObject",
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
        ), modelResult)
    }
    
    func testEnumWithOneCase() {
        let type: ModelParser.FieldType = .enum([.text])
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "#import <Foundation/Foundation.h>",
            "",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@property (nonatomic, copy, readonly) NSString *text;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "",
            "@implementation TestObject",
            "- (instancetype)initWithJsonValue:(id)jsonValue {",
            "    self = [super init];",
            "    if (self) {",
            "        _text = [jsonValue isKindOfClass:[NSString class]] ? jsonValue : nil;",
            "    }",
            "    return self;",
            "}",
            "@end"
        ), modelResult)
    }
    
    func testEnumWithTwoCases() {
        let type: ModelParser.FieldType = .enum([
            .optional(.object([])),
            .number(.Int)
        ])
        
        let modelCreator = ObjcModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "#import <Foundation/Foundation.h>",
            "",
            "@class TestObjectObject;",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@property (nonatomic, assign, readonly) NSInteger number;",
            "@property (nonatomic, strong, readonly, nullable) TestObjectObject *object;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObjectObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "",
            "@implementation TestObject",
            "- (instancetype)initWithJsonValue:(id)jsonValue {",
            "    self = [super init];",
            "    if (self) {",
            "        _number = [jsonValue isKindOfClass:[NSNumber class]] ? [jsonValue integerValue] : 0;",
            "        _object = [[TestObjectObject alloc] initWithJsonValue:jsonValue];",
            "    }",
            "    return self;",
            "}",
            "@end",
            "",
            "@implementation TestObjectObject",
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
        ), modelResult)
    }
    
    func testAtomicFieldsFlag() {
        let type: ModelParser.FieldType = .object([.init(name: "text", type: .text)])
        
        let modelResult1 = ObjcModelCreator(args: ["-a"]).translate(type, name: "TestObject")
        let modelResult2 = ObjcModelCreator(args: ["--atomic"]).translate(type, name: "TestObject")
        let expected = String(lines:
            "#import <Foundation/Foundation.h>",
            "",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@property (atomic, copy, readonly) NSString *text;",
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
        )
        XCTAssertEqual(expected, modelResult1)
        XCTAssertEqual(expected, modelResult2)
    }
    
    func testMutableFieldsFlag() {
        let type: ModelParser.FieldType = .object([.init(name: "text", type: .text)])
        
        let modelResult1 = ObjcModelCreator(args: ["-m"]).translate(type, name: "TestObject")
        let modelResult2 = ObjcModelCreator(args: ["--mutable"]).translate(type, name: "TestObject")
        let expected = String(lines:
            "#import <Foundation/Foundation.h>",
            "",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@property (nonatomic, copy) NSString *text;",
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
        )
        XCTAssertEqual(expected, modelResult1)
        XCTAssertEqual(expected, modelResult2)
    }
    
    
    func testPrefixOption() {
        let type: ModelParser.FieldType = .object([.init(name: "text", type: .text)])
        
        let modelResult1 = ObjcModelCreator(args: ["-p", "ABC"]).translate(type, name: "TestObject")
        let modelResult2 = ObjcModelCreator(args: ["--prefix", "ABC"]).translate(type, name: "TestObject")
        let expected = [
            "#import <Foundation/Foundation.h>",
            "",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface ABCTestObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@property (nonatomic, copy, readonly) NSString *text;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "",
            "@implementation ABCTestObject",
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
            ].joined(separator: "\n")
        XCTAssertEqual(expected, modelResult1)
        XCTAssertEqual(expected, modelResult2)
    }
    
}
