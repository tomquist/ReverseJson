
import XCTest
import ReverseJsonCore
@testable import ReverseJsonObjc

class ObjcModelTranslatorTest: XCTestCase {
    
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
        let type: FieldType = .unnamedObject([])
        
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
    
    func testNamedEmptyObject() {
        let type: FieldType = .object(name: "CustomObjectName", [])
        
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// CustomObjectName.h",
            "#import <Foundation/Foundation.h>",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface CustomObjectName : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "// CustomObjectName.m",
            "#import \"CustomObjectName.h\"",
            "@implementation CustomObjectName",
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
        let type: FieldType = .unnamedEnum([])
        
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
    
    func testNamedEmptyEnum() {
        let type: FieldType = .enum(name: "CustomObject", [])
        
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// CustomObject.h",
            "#import <Foundation/Foundation.h>",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface CustomObject : NSObject",
            "- (instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "// CustomObject.m",
            "#import \"CustomObject.h\"",
            "@implementation CustomObject",
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
        let type: FieldType = .unnamedUnknown
        
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual("", modelResult)
    }
    
    func testListOfEmptyObject() {
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(.list(.unnamedObject([])), name: "TestObjectList")
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
        let type: FieldType = .unnamedObject([.init(name: "text", type: .text)])
        
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
    
    func testObjectWithSingleTextFieldAndReverseMapper() {
        let type: FieldType = .unnamedObject([.init(name: "text", type: .text)])
        
        var modelCreator = ObjcModelCreator()
        modelCreator.createToJson = true
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// TestObject.h",
            "#import <Foundation/Foundation.h>",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "- (NSDictionary<NSString *, id<NSObject>> *)toJson;",
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
            "- (NSDictionary<NSString *, id<NSObject>> *)toJson {",
            "    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:1];",
            "    ret[@\"text\"] = _text;",
            "    return [ret copy];",
            "}",
            "@end"
        ), modelResult)
    }
    
    func testObjectWithSingleReservedTextField() {
        let type: FieldType = .unnamedObject([.init(name: "signed", type: .text)])
        
        let modelCreator = ObjcModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
          "// TestObject.h",
          "#import <Foundation/Foundation.h>",
          "NS_ASSUME_NONNULL_BEGIN",
          "@interface TestObject : NSObject",
          "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
          "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
          "@property (nonatomic, copy, readonly) NSString *$signed;",
          "@end",
          "NS_ASSUME_NONNULL_END",
          "// TestObject.m",
          "#import \"TestObject.h\"",
          "@implementation TestObject",
          "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dict {",
          "    self = [super init];",
          "    if (self) {",
          "        _$signed = [dict[@\"signed\"] isKindOfClass:[NSString class]] ? dict[@\"signed\"] : @\"\";",
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
        let type: FieldType = .unnamedObject([.init(name: "texts", type: .list(.text))])
        
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
    
    func testObjectWithFieldContainingListOfTextWithReverseMapper() {
        let type: FieldType = .unnamedObject([.init(name: "texts", type: .list(.text))])
        
        var modelCreator = ObjcModelCreator()
        modelCreator.createToJson = true
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// TestObject.h",
            "#import <Foundation/Foundation.h>",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "- (NSDictionary<NSString *, id<NSObject>> *)toJson;",
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
            "- (NSDictionary<NSString *, id<NSObject>> *)toJson {",
            "    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:1];",
            "    ret[@\"texts\"] = ({",
            "        NSMutableArray<id<NSObject>> *values = nil;",
            "        NSArray *array = _texts;",
            "        if (array) {",
            "            values = [NSMutableArray arrayWithCapacity:array.count];",
            "            for (id item in array) {",
            "                if (item == [NSNull null]) {",
            "                    [values addObject:item];",
            "                } else {",
            "                    id json = item;",
            "                    [values addObject:json ?: (id)[NSNull null]];",
            "                }",
            "            }",
            "        }",
            "        [values copy] ?: @[];",
            "    });",
            "    return [ret copy];",
            "}",
            "@end"
        ), modelResult)
    }
    
    func testObjectWithFieldContainingOptionalListOfText() {
        let type: FieldType = .unnamedObject([.init(name: "texts", type: .optional(.list(.text)))])
        
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
        let modelResult: String = modelCreator.translate(.unnamedObject([
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
            "@property (nonatomic, assign, readonly) NSInteger $int;",
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
            "        _$int = [dict[@\"int\"] isKindOfClass:[NSNumber class]] ? [dict[@\"int\"] integerValue] : 0;",
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
        let modelResult: String = modelCreator.translate(.unnamedObject([
            .init(name: "subObject", type: .unnamedObject([]))
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
        let type: FieldType = .unnamedEnum([.text])
        
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
    
    func testEnumWithOneCaseAndReverseMapping() {
        let type: FieldType = .unnamedEnum([.text])
        
        var modelCreator = ObjcModelCreator()
        modelCreator.createToJson = true
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// TestObject.h",
            "#import <Foundation/Foundation.h>",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "- (id<NSObject>)toJson;",
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
            "- (id<NSObject>)toJson {",
            "    if (_text) {",
            "        return _text;",
            "    }",
            "    return nil;",
            "}",
            "@end"
        ), modelResult)
    }
    
    func testEnumWithTwoCases() {
        let type: FieldType = .unnamedEnum([
            .optional(.unnamedObject([])),
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
            "@property (nonatomic, copy, readonly, nullable) NSNumber/*NSInteger*/ *number;",
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
            "        _number = [jsonValue isKindOfClass:[NSNumber class]] ? jsonValue : nil;",
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

    func testEnumWithTwoCasesAndReverseMapping() {
        let type: FieldType = .unnamedEnum([
            .optional(.unnamedObject([])),
            .number(.int)
        ])
        
        var modelCreator = ObjcModelCreator()
        modelCreator.createToJson = true
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// TestObject.h",
            "#import <Foundation/Foundation.h>",
            "@class TestObjectObject;",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObject : NSObject",
            "- (instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "- (id<NSObject>)toJson;",
            "@property (nonatomic, copy, readonly, nullable) NSNumber/*NSInteger*/ *number;",
            "@property (nonatomic, strong, readonly, nullable) TestObjectObject *object;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "// TestObjectObject.h",
            "#import <Foundation/Foundation.h>",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface TestObjectObject : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "- (NSDictionary<NSString *, id<NSObject>> *)toJson;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "// TestObject.m",
            "#import \"TestObject.h\"",
            "#import \"TestObjectObject.h\"",
            "@implementation TestObject",
            "- (instancetype)initWithJsonValue:(id)jsonValue {",
            "    self = [super init];",
            "    if (self) {",
            "        _number = [jsonValue isKindOfClass:[NSNumber class]] ? jsonValue : nil;",
            "        _object = [[TestObjectObject alloc] initWithJsonValue:jsonValue];",
            "    }",
            "    return self;",
            "}",
            "- (id<NSObject>)toJson {",
            "    if (_number) {",
            "        return _number;",
            "    } else if (_object) {",
            "        return [_object toJson];",
            "    }",
            "    return nil;",
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
            "- (NSDictionary<NSString *, id<NSObject>> *)toJson {",
            "    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:0];",
            "    return [ret copy];",
            "}",
            "@end"
        ), modelResult)
    }
    
    func testNamedEnumWithTwoCasesAndReverseMapping() {
        let type: FieldType = .enum(name: "CustomEnumName", [
            .optional(.object(name: "CustomObjectName", [])),
            .number(.int)
        ])
        
        var modelCreator = ObjcModelCreator()
        modelCreator.createToJson = true
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// CustomEnumName.h",
            "#import <Foundation/Foundation.h>",
            "@class CustomObjectName;",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface CustomEnumName : NSObject",
            "- (instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "- (id<NSObject>)toJson;",
            "@property (nonatomic, strong, readonly, nullable) CustomObjectName *customObjectName;",
            "@property (nonatomic, copy, readonly, nullable) NSNumber/*NSInteger*/ *number;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "// CustomObjectName.h",
            "#import <Foundation/Foundation.h>",
            "NS_ASSUME_NONNULL_BEGIN",
            "@interface CustomObjectName : NSObject",
            "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
            "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            "- (NSDictionary<NSString *, id<NSObject>> *)toJson;",
            "@end",
            "NS_ASSUME_NONNULL_END",
            "// CustomEnumName.m",
            "#import \"CustomEnumName.h\"",
            "#import \"CustomObjectName.h\"",
            "@implementation CustomEnumName",
            "- (instancetype)initWithJsonValue:(id)jsonValue {",
            "    self = [super init];",
            "    if (self) {",
            "        _customObjectName = [[CustomObjectName alloc] initWithJsonValue:jsonValue];",
            "        _number = [jsonValue isKindOfClass:[NSNumber class]] ? jsonValue : nil;",
            "    }",
            "    return self;",
            "}",
            "- (id<NSObject>)toJson {",
            "    if (_customObjectName) {",
            "        return [_customObjectName toJson];",
            "    } else if (_number) {",
            "        return _number;",
            "    }",
            "    return nil;",
            "}",
            "@end",
            "// CustomObjectName.m",
            "#import \"CustomObjectName.h\"",
            "@implementation CustomObjectName",
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
            "- (NSDictionary<NSString *, id<NSObject>> *)toJson {",
            "    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:0];",
            "    return [ret copy];",
            "}",
            "@end"
        ), modelResult)
    }

    func testAtomicFieldsFlag() {
        let type: FieldType = .unnamedObject([.init(name: "text", type: .text)])
        
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
        let type: FieldType = .unnamedObject([.init(name: "text", type: .text)])
        
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
        let type: FieldType = .unnamedObject([.init(name: "text", type: .text)])
        
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

#if os(Linux)
extension ObjcModelTranslatorTest {
    static var allTests: [(String, (ObjcModelTranslatorTest) -> () throws -> Void)] {
        return [
            ("testAtomicFieldsFlag", testAtomicFieldsFlag),
            ("testBoolDouble", testBoolDouble),
            ("testEmptyEnum", testEmptyEnum),
            ("testNamedEmptyEnum", testNamedEmptyEnum),
            ("testEmptyObject", testEmptyObject),
            ("testNamedEmptyObject", testNamedEmptyObject),
            ("testEnumWithOneCase", testEnumWithOneCase),
            ("testEnumWithOneCaseAndReverseMapping", testEnumWithOneCaseAndReverseMapping),
            ("testEnumWithTwoCases", testEnumWithTwoCases),
            ("testEnumWithTwoCasesAndReverseMapping", testEnumWithTwoCasesAndReverseMapping),
            ("testNamedEnumWithTwoCasesAndReverseMapping", testNamedEnumWithTwoCasesAndReverseMapping),
            ("testListOfEmptyObject", testListOfEmptyObject),
            ("testMutableFieldsFlag", testMutableFieldsFlag),
            ("testPrefixOption", testPrefixOption),
            ("testObjectWithDifferentFields", testObjectWithDifferentFields),
            ("testObjectWithFieldContainingListOfText", testObjectWithFieldContainingListOfText),
            ("testObjectWithFieldContainingListOfTextWithReverseMapper", testObjectWithFieldContainingListOfTextWithReverseMapper),
            ("testObjectWithFieldContainingOptionalListOfText", testObjectWithFieldContainingOptionalListOfText),
            ("testObjectWithOneFieldWithSubDeclaration", testObjectWithOneFieldWithSubDeclaration),
            ("testObjectWithSingleTextField", testObjectWithSingleTextField),
            ("testObjectWithSingleTextFieldAndReverseMapper", testObjectWithSingleTextFieldAndReverseMapper),
            ("testObjectWithSingleReservedTextField", testObjectWithSingleReservedTextField),
            ("testSimpleDouble", testSimpleDouble),
            ("testSimpleFloat", testSimpleFloat),
            ("testSimpleInt", testSimpleInt),
            ("testSimpleString", testSimpleString),
            ("testTextList", testTextList),
            ("testUnknownType", testUnknownType),
        ]
    }
}
#endif
