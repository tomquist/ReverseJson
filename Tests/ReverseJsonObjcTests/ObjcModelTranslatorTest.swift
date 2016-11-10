
import XCTest
import ReverseJsonCore
@testable import ReverseJsonObjc

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
            ("testObjectWithFieldContainingOptionalListOfText", testObjectWithFieldContainingOptionalListOfText),
            ("testObjectWithOneFieldWithSubDeclaration", testObjectWithOneFieldWithSubDeclaration),
            ("testObjectWithSingleTextField", testObjectWithSingleTextField),
            ("testObjectWithSingleReservedTextField", testObjectWithSingleReservedTextField),
            ("testSimpleDouble", testSimpleDouble),
            ("testSimpleFloat", testSimpleFloat),
            ("testSimpleInt", testSimpleInt),
            ("testSimpleString", testSimpleString),
            ("testTextList", testTextList),
            ("testUnknownType", testUnknownType),
        ]
    }
    
    func testSimpleString() {
        let type: FieldType = .text
        
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "SimpleText")
        XCTAssertEqual("", modelResult)
    }
    
    func testSimpleInt() {
        let type: FieldType = .number(.int)
        
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("", modelResult)
    }

    func testSimpleFloat() {
        let type: FieldType = .number(.float)
        
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("", modelResult)
    }
    
    func testSimpleDouble() {
        let type: FieldType = .number(.double)
        
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("", modelResult)
    }
    
    func testBoolDouble() {
        let type: FieldType = .number(.bool)
        
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("", modelResult)
    }
    
    func testEmptyObject() {
        let type: FieldType = .object([])
        
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// TestObject.h",
            "#import <Foundation/Foundation.h>",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "// TestObject.m",
            "#import \"TestObject.h\"",
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
        let type: FieldType = .enum([])
        
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// TestObject.h",
            "#import <Foundation/Foundation.h>",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "// TestObject.m",
            "#import \"TestObject.h\"",
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
        let type: FieldType = .list(.text)
        
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "TextList")
        XCTAssertEqual("", modelResult)
    }
    
    func testUnknownType() {
        let type: FieldType = .unknown
        
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual("", modelResult)
    }
    
    func testListOfEmptyObject() {
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(.list(.object([])), name: "TestObjectList")
        XCTAssertEqual(String(lines:
            "// TestObjectListItem.h",
            "#import <Foundation/Foundation.h>",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObjectListItem : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "// TestObjectListItem.m",
            "#import \"TestObjectListItem.h\"",
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
        let type: FieldType = .object([.init(name: "text", type: .text)])
        
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// TestObject.h",
            "#import <Foundation/Foundation.h>",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@property (nonatomic, copy, readonly) NSString *text;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "// TestObject.m",
            "#import \"TestObject.h\"",
            "@implementation TestObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dict {",
            "    self = [super init];",
            "    if (self) {",
            "        _text = [dict[@\"text\"] isKindOfClass:[NSString class]] ? dict[@\"text\"] : @\"\";",
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
    
    func testObjectWithSingleReservedTextField() {
        let type: FieldType = .object([.init(name: "signed", type: .text)])
        
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
          "// TestObject.h",
          "#import <Foundation/Foundation.h>",
          "NS_ASSUME_NONNULL_BEGIN",
          "@interface TestObject : NSObject",
          "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
          "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
          "@property (nonatomic, copy, readonly) NSString *isSigned;",
          "@end",
          "NS_ASSUME_NONNULL_END",
          "// TestObject.m",
          "#import \"TestObject.h\"",
          "@implementation TestObject",
          "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dict {",
          "    self = [super init];",
          "    if (self) {",
          "        _isSigned = [dict[@\"signed\"] isKindOfClass:[NSString class]] ? dict[@\"signed\"] : @\"\";",
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
        let type: FieldType = .object([.init(name: "texts", type: .list(.text))])
        
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// TestObject.h",
            "#import <Foundation/Foundation.h>",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@property (nonatomic, strong, readonly) NSArray<NSString *> *texts;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "// TestObject.m",
            "#import \"TestObject.h\"",
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
            "                    NSString *parsedItem = [item isKindOfClass:[NSString class]] ? item : @\"\";",
            "                    [values addObject:parsedItem ?: (id)[NSNull null]];",
            "                }",
            "            }",
            "            [values copy] ?: @[];",
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
    
    func testObjectWithFieldContainingOptionalListOfText() {
        let type: FieldType = .object([.init(name: "texts", type: .optional(.list(.text)))])
        
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// TestObject.h",
          "#import <Foundation/Foundation.h>",
          "NS_ASSUME_NONNULL_BEGIN",
          "@interface TestObject : NSObject",
          "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
          "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
          "@property (nonatomic, strong, readonly, nullable) NSArray<NSString *> *texts;",
          "@end",
          "NS_ASSUME_NONNULL_END",
          "// TestObject.m",
          "#import \"TestObject.h\"",
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
          "                    NSString *parsedItem = [item isKindOfClass:[NSString class]] ? item : @\"\";",
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
        let modelResult: String = modelCreator.translate(.object([
            .init(name: "listOfListsOfText", type: .list(.list(.text))),
            .init(name: "numbers", type: .list(.number(.int))),
            .init(name: "int", type: .number(.int)),
            .init(name: "optionalText", type: .optional(.text))
        ]), name: "TestObject")
        XCTAssertEqual(String(lines:
            "// TestObject.h",
            "#import <Foundation/Foundation.h>",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@property (nonatomic, strong, readonly) NSArray<NSArray<NSString *> *> *listOfListsOfText;",
            "@property (nonatomic, strong, readonly) NSArray<NSNumber/*NSInteger*/ *> *numbers;",
            "@property (nonatomic, assign, readonly) NSInteger _int;",
            "@property (nonatomic, strong, readonly, nullable) NSString *optionalText;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "// TestObject.m",
            "#import \"TestObject.h\"",
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
            "                                NSString *parsedItem = [item isKindOfClass:[NSString class]] ? item : @\"\";",
            "                                [values addObject:parsedItem ?: (id)[NSNull null]];",
            "                            }",
            "                        }",
            "                        [values copy] ?: @[];",
            "                    });",
            "                    [values addObject:parsedItem ?: (id)[NSNull null]];",
            "                }",
            "            }",
            "            [values copy] ?: @[];",
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
            "            [values copy] ?: @[];",
            "        });",
            "        __int = [dict[@\"int\"] isKindOfClass:[NSNumber class]] ? [dict[@\"int\"] integerValue] : 0;",
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
        let modelResult: String = modelCreator.translate(.object([
            .init(name: "subObject", type: .object([]))
            ]), name: "TestObject")
        XCTAssertEqual(String(lines:
            "// TestObject.h",
            "#import <Foundation/Foundation.h>",
            "@class TestObjectSubObject;",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@property (nonatomic, strong, readonly) TestObjectSubObject *subObject;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "// TestObjectSubObject.h",
            "#import <Foundation/Foundation.h>",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObjectSubObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "// TestObject.m",
            "#import \"TestObject.h\"",
            "#import \"TestObjectSubObject.h\"",
            "@implementation TestObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dict {",
            "    self = [super init];",
            "    if (self) {",
            "        _subObject = ([[TestObjectSubObject alloc] initWithJsonValue:dict[@\"subObject\"]] ?: [[TestObjectSubObject alloc] initWithJsonDictionary:@{}]);",
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
            "// TestObjectSubObject.m",
            "#import \"TestObjectSubObject.h\"",
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
        let type: FieldType = .enum([.text])
        
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// TestObject.h",
            "#import <Foundation/Foundation.h>",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@property (nonatomic, copy, readonly) NSString *text;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "// TestObject.m",
            "#import \"TestObject.h\"",
            "@implementation TestObject",
            "- (instancetype)initWithJsonValue:(id)jsonValue {",
            "    self = [super init];",
            "    if (self) {",
            "        _text = [jsonValue isKindOfClass:[NSString class]] ? jsonValue : @\"\";",
            "    }",
            "    return self;",
            "}",
            "@end"
        ), modelResult)
    }
    
    func testEnumWithTwoCases() {
        let type: FieldType = .enum([
            .optional(.object([])),
            .number(.int)
        ])
        
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// TestObject.h",
            "#import <Foundation/Foundation.h>",
            "@class TestObjectObject;",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@property (nonatomic, assign, readonly) NSInteger number;",
            "@property (nonatomic, strong, readonly, nullable) TestObjectObject *object;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "// TestObjectObject.h",
            "#import <Foundation/Foundation.h>",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObjectObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "// TestObject.m",
            "#import \"TestObject.h\"",
            "#import \"TestObjectObject.h\"",
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
            "// TestObjectObject.m",
            "#import \"TestObjectObject.h\"",
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
        let type: FieldType = .object([.init(name: "text", type: .text)])
        
        var modelCreator = ObjcModelCreator()
        modelCreator.atomic = true
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        let expected = String(lines:
            "// TestObject.h",
            "#import <Foundation/Foundation.h>",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@property (atomic, copy, readonly) NSString *text;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "// TestObject.m",
            "#import \"TestObject.h\"",
            "@implementation TestObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dict {",
            "    self = [super init];",
            "    if (self) {",
            "        _text = [dict[@\"text\"] isKindOfClass:[NSString class]] ? dict[@\"text\"] : @\"\";",
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
        XCTAssertEqual(expected, modelResult)
    }
    
    func testMutableFieldsFlag() {
        let type: FieldType = .object([.init(name: "text", type: .text)])
        
        var modelCreator = ObjcModelCreator()
        modelCreator.readonly = false
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        let expected = String(lines:
            "// TestObject.h",
            "#import <Foundation/Foundation.h>",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@property (nonatomic, copy) NSString *text;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "// TestObject.m",
            "#import \"TestObject.h\"",
            "@implementation TestObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dict {",
            "    self = [super init];",
            "    if (self) {",
            "        _text = [dict[@\"text\"] isKindOfClass:[NSString class]] ? dict[@\"text\"] : @\"\";",
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
        XCTAssertEqual(expected, modelResult)
    }
    
    
    func testPrefixOption() {
        let type: FieldType = .object([.init(name: "text", type: .text)])
        
        var modelCreator = ObjcModelCreator()
        modelCreator.typePrefix = "ABC"
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        let expected = [
            "// ABCTestObject.h",
            "#import <Foundation/Foundation.h>",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface ABCTestObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@property (nonatomic, copy, readonly) NSString *text;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "// ABCTestObject.m",
            "#import \"ABCTestObject.h\"",
            "@implementation ABCTestObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dict {",
            "    self = [super init];",
            "    if (self) {",
            "        _text = [dict[@\"text\"] isKindOfClass:[NSString class]] ? dict[@\"text\"] : @\"\";",
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
        XCTAssertEqual(expected, modelResult)
    }
    
}
