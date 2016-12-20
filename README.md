[![Build Status](https://travis-ci.org/tomquist/ReverseJson.svg)](https://travis-ci.org/tomquist/ReverseJson)
[![codecov.io](https://codecov.io/github/tomquist/ReverseJson/coverage.svg)](https://codecov.io/github/tomquist/ReverseJson)

# ReverseJson

## Introduction
Generate data model code and JSON-parser code from JSON-files. Currently you can generate Swift and Objective-C code.

## Features
- Scans the whole JSON-file to get most information out of it
- Detects variadic types within arrays, even in sub structures
- Detects nullability attributes, e.g. when a single occurrence of a property is null or a property is missing, the property is declared as Optional/Nullable
- Generates parsing instructions for Swift and Objective-C 
- Converts any JSON data-structure into a simple schema which then can be modified/adjusted and be used to generate Swift/Objective-C code

## Usage

### Prerequisites

* Swift 3.0
* Any Swift 3.0 compatible platform (e.g. macOS or Linux)

### Build

	swift build --configuration release

By default, you'll find the executable in ```.build/release/ReverseJson```

### Test

    swift test

### General usage:

```
Usage: ReverseJson (swift|objc|export) NAME FILE <options>
e.g. ReverseJson swift User testModel.json <options>
Options:
   -v,  --verbose          Print result instead of creating files
   -o,  --out <dir>        Output directory (default is current directory)
   -c,  --class            (Swift) Use classes instead of structs for objects
   -ca, --contiguousarray  (Swift) Use ContiguousArray for lists
   -pt, --publictypes      (Swift) Make type declarations public instead of internal
   -pf, --publicfields     (Swift) Make field declarations public instead of internal
   -n,  --nullable         (Swift and Objective-C) Make all field declarations optional (nullable in Objective-C)
   -m,  --mutable          (Swift and Objective-C) All object fields are mutable (var instead of
                           let in Swift and 'readwrite' instead of 'readonly' in Objective-C)
   -a,  --atomic           (Objective-C) Make properties 'atomic'
   -p, --prefix <prefix>   (Objective-C) Class-prefix to use for type declarations
   -r, --reversemapping    (Objective-C) Create method for reverse mapping (toJson)
```

### To create a Swift data model:

	./ReverseJson swift User testModel.json

### To create an Objective-C data model:

    ./ReverseJson objc User testModel.json

## Demo
Turns this:

```json
{
  "name": "Tom",
  "is_private": false,
  "mixed": [10, "Some text"],
  "numbers": [10, 11, 12],
  "locations": [
    {"lat": 10.5, "lon": 49},
    {
      "lat": -74.1184284,
      "lon": 40.7055647,
      "address": {
        "street": "Some Street",
        "city": "New York"
      }
    }
  ],
  "internal": false
}
```

...into this:

```swift
// JsonModel.swift
struct User {
    enum MixedItem {
        case number(Int)
        case text(String)
    }
    struct LocationsItem {
        struct Address {
            let city: String
            let street: String
        }
        let address: Address?
        let lat: Double
        let lon: Double
    }
    let `internal`: Bool
    let isPrivate: Bool
    let locations: [LocationsItem]
    let mixed: [MixedItem]
    let name: String
    let numbers: [Int]
}
// JsonModelMapping.swift
enum JsonParsingError: Error {
    case unsupportedTypeError
}

extension Array {
    init(jsonValue: Any?, map: (Any) throws -> Element) throws {
        guard let items = jsonValue as? [Any] else {
            throw JsonParsingError.unsupportedTypeError
        }
        self = try items.map(map)
    }
}

extension Bool {
    init(jsonValue: Any?) throws {
        if let number = jsonValue as? NSNumber {
            guard String(cString: number.objCType) == String(cString: NSNumber(value: true).objCType) else {
                throw JsonParsingError.unsupportedTypeError
            }
            self = number.boolValue
        } else if let number = jsonValue as? Bool {
            self = number
        } else {
            throw JsonParsingError.unsupportedTypeError
        }
    }
}

extension Double {
    init(jsonValue: Any?) throws {
        if let number = jsonValue as? NSNumber {
            self = number.doubleValue
        } else if let number = jsonValue as? Int {
            self = Double(number)
        } else if let number = jsonValue as? Double {
            self = number
        } else if let number = jsonValue as? Float {
            self = Double(number)
        } else {
            throw JsonParsingError.unsupportedTypeError
        }
    }
}

extension Int {
    init(jsonValue: Any?) throws {
        if let number = jsonValue as? NSNumber {
            self = number.intValue
        } else if let number = jsonValue as? Int {
            self = number
        } else if let number = jsonValue as? Double {
            self = Int(number)
        } else if let number = jsonValue as? Float {
            self = Int(number)
        } else {
            throw JsonParsingError.unsupportedTypeError
        }
    }
}

extension Optional {
    init(jsonValue: Any?, map: (Any) throws -> Wrapped) throws {
        if let jsonValue = jsonValue, !(jsonValue is NSNull) {
            self = try map(jsonValue)
        } else {
            self = nil
        }
    }
}

extension String {
    init(jsonValue: Any?) throws {
        guard let string = jsonValue as? String else {
            throw JsonParsingError.unsupportedTypeError
        }
        self = string
    }
}

extension User {
    init(jsonValue: Any?) throws {
        guard let dict = jsonValue as? [String: Any] else {
            throw JsonParsingError.unsupportedTypeError
        }
        self.mixed = try Array(jsonValue: dict["mixed"]) { try User.MixedItem(jsonValue: $0) }
        self.numbers = try Array(jsonValue: dict["numbers"]) { try Int(jsonValue: $0) }
        self.`internal` = try Bool(jsonValue: dict["internal"])
        self.isPrivate = try Bool(jsonValue: dict["is_private"])
        self.locations = try Array(jsonValue: dict["locations"]) { try User.LocationsItem(jsonValue: $0) }
        self.name = try String(jsonValue: dict["name"])
    }
}

extension User.LocationsItem {
    init(jsonValue: Any?) throws {
        guard let dict = jsonValue as? [String: Any] else {
            throw JsonParsingError.unsupportedTypeError
        }
        self.lat = try Double(jsonValue: dict["lat"])
        self.lon = try Double(jsonValue: dict["lon"])
        self.address = try Optional(jsonValue: dict["address"]) { try User.LocationsItem.Address(jsonValue: $0) }
    }
}

extension User.LocationsItem.Address {
    init(jsonValue: Any?) throws {
        guard let dict = jsonValue as? [String: Any] else {
            throw JsonParsingError.unsupportedTypeError
        }
        self.street = try String(jsonValue: dict["street"])
        self.city = try String(jsonValue: dict["city"])
    }
}

extension User.MixedItem {
    init(jsonValue: Any?) throws {
        if let value = try? Int(jsonValue: jsonValue) {
            self = .number(value)
        } else if let value = try? String(jsonValue: jsonValue) {
            self = .text(value)
        } else {
            throw JsonParsingError.unsupportedTypeError
        }
    }
}

func parseUser(jsonValue: Any?) throws -> User {
    return try User(jsonValue: jsonValue)
}
```

...or into this...

```objective-c
// User.h
#import <Foundation/Foundation.h>
@class UserLocationsItem, UserMixedItem;
NS_ASSUME_NONNULL_BEGIN
@interface User : NSObject
- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;
- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;
- (NSDictionary<NSString *, id<NSObject>> *)toJson;
@property (nonatomic, assign, readonly) BOOL internal;
@property (nonatomic, assign, readonly) BOOL isPrivate;
@property (nonatomic, strong, readonly) NSArray<NSNumber/*NSInteger*/ *> *numbers;
@property (nonatomic, strong, readonly) NSArray<UserLocationsItem *> *locations;
@property (nonatomic, strong, readonly) NSArray<UserMixedItem *> *mixed;
@property (nonatomic, copy, readonly) NSString *name;
@end
NS_ASSUME_NONNULL_END
// UserLocationsItem.h
#import <Foundation/Foundation.h>
@class UserLocationsItemAddress;
NS_ASSUME_NONNULL_BEGIN
@interface UserLocationsItem : NSObject
- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;
- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;
- (NSDictionary<NSString *, id<NSObject>> *)toJson;
@property (nonatomic, strong, readonly, nullable) UserLocationsItemAddress *address;
@property (nonatomic, assign, readonly) double lat;
@property (nonatomic, assign, readonly) double lon;
@end
NS_ASSUME_NONNULL_END
// UserLocationsItemAddress.h
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface UserLocationsItemAddress : NSObject
- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;
- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;
- (NSDictionary<NSString *, id<NSObject>> *)toJson;
@property (nonatomic, copy, readonly) NSString *city;
@property (nonatomic, copy, readonly) NSString *street;
@end
NS_ASSUME_NONNULL_END
// UserMixedItem.h
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface UserMixedItem : NSObject
- (instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;
- (id<NSObject>)toJson;
@property (nonatomic, copy, readonly, nullable) NSNumber/*NSInteger*/ *number;
@property (nonatomic, strong, readonly, nullable) NSString *text;
@end
NS_ASSUME_NONNULL_END
// User.m
#import "User.h"
#import "UserLocationsItem.h"
#import "UserMixedItem.h"
@implementation User
- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dict {
    self = [super init];
    if (self) {
        _internal = [dict[@"internal"] isKindOfClass:[NSNumber class]] ? [dict[@"internal"] boolValue] : 0;
        _isPrivate = [dict[@"is_private"] isKindOfClass:[NSNumber class]] ? [dict[@"is_private"] boolValue] : 0;
        _numbers = ({
            id value = dict[@"numbers"];
            NSMutableArray<NSNumber/*NSInteger*/ *> *values = nil;
            if ([value isKindOfClass:[NSArray class]]) {
                NSArray *array = value;
                values = [NSMutableArray arrayWithCapacity:array.count];
                for (id item in array) {
                    NSNumber/*NSInteger*/ *parsedItem = [item isKindOfClass:[NSNumber class]] ? item : nil;
                    [values addObject:parsedItem ?: (id)[NSNull null]];
                }
            }
            [values copy] ?: @[];
        });
        _locations = ({
            id value = dict[@"locations"];
            NSMutableArray<UserLocationsItem *> *values = nil;
            if ([value isKindOfClass:[NSArray class]]) {
                NSArray *array = value;
                values = [NSMutableArray arrayWithCapacity:array.count];
                for (id item in array) {
                    UserLocationsItem *parsedItem = ([[UserLocationsItem alloc] initWithJsonValue:item] ?: [[UserLocationsItem alloc] initWithJsonDictionary:@{}]);
                    [values addObject:parsedItem ?: (id)[NSNull null]];
                }
            }
            [values copy] ?: @[];
        });
        _mixed = ({
            id value = dict[@"mixed"];
            NSMutableArray<UserMixedItem *> *values = nil;
            if ([value isKindOfClass:[NSArray class]]) {
                NSArray *array = value;
                values = [NSMutableArray arrayWithCapacity:array.count];
                for (id item in array) {
                    UserMixedItem *parsedItem = [[UserMixedItem alloc] initWithJsonValue:item];
                    [values addObject:parsedItem ?: (id)[NSNull null]];
                }
            }
            [values copy] ?: @[];
        });
        _name = [dict[@"name"] isKindOfClass:[NSString class]] ? dict[@"name"] : @"";
    }
    return self;
}
- (instancetype)initWithJsonValue:(id)jsonValue {
    if ([jsonValue isKindOfClass:[NSDictionary class]]) {
        self = [self initWithJsonDictionary:jsonValue];
    } else {
        self = nil;
    }
    return self;
}
- (NSDictionary<NSString *, id<NSObject>> *)toJson {
    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:6];
    ret[@"internal"] = @(_internal);
    ret[@"is_private"] = @(_isPrivate);
    ret[@"numbers"] = ({
        NSMutableArray<id<NSObject>> *values = nil;
        NSArray *array = _numbers;
        if (array) {
            values = [NSMutableArray arrayWithCapacity:array.count];
            for (id item in array) {
                if (item == [NSNull null]) {
                    [values addObject:item];
                } else {
                    id json = item;
                    [values addObject:json ?: (id)[NSNull null]];
                }
            }
        }
        [values copy] ?: @[];
    });
    ret[@"locations"] = ({
        NSMutableArray<id<NSObject>> *values = nil;
        NSArray *array = _locations;
        if (array) {
            values = [NSMutableArray arrayWithCapacity:array.count];
            for (id item in array) {
                if (item == [NSNull null]) {
                    [values addObject:item];
                } else {
                    id json = [item toJson];
                    [values addObject:json ?: (id)[NSNull null]];
                }
            }
        }
        [values copy] ?: @[];
    });
    ret[@"mixed"] = ({
        NSMutableArray<id<NSObject>> *values = nil;
        NSArray *array = _mixed;
        if (array) {
            values = [NSMutableArray arrayWithCapacity:array.count];
            for (id item in array) {
                if (item == [NSNull null]) {
                    [values addObject:item];
                } else {
                    id json = [item toJson];
                    [values addObject:json ?: (id)[NSNull null]];
                }
            }
        }
        [values copy] ?: @[];
    });
    ret[@"name"] = _name;
    return [ret copy];
}
@end
// UserLocationsItem.m
#import "UserLocationsItem.h"
#import "UserLocationsItemAddress.h"
@implementation UserLocationsItem
- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dict {
    self = [super init];
    if (self) {
        _address = [[UserLocationsItemAddress alloc] initWithJsonValue:dict[@"address"]];
        _lat = [dict[@"lat"] isKindOfClass:[NSNumber class]] ? [dict[@"lat"] doubleValue] : 0;
        _lon = [dict[@"lon"] isKindOfClass:[NSNumber class]] ? [dict[@"lon"] doubleValue] : 0;
    }
    return self;
}
- (instancetype)initWithJsonValue:(id)jsonValue {
    if ([jsonValue isKindOfClass:[NSDictionary class]]) {
        self = [self initWithJsonDictionary:jsonValue];
    } else {
        self = nil;
    }
    return self;
}
- (NSDictionary<NSString *, id<NSObject>> *)toJson {
    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:3];
    ret[@"address"] = [_address toJson];
    ret[@"lat"] = @(_lat);
    ret[@"lon"] = @(_lon);
    return [ret copy];
}
@end
// UserLocationsItemAddress.m
#import "UserLocationsItemAddress.h"
@implementation UserLocationsItemAddress
- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dict {
    self = [super init];
    if (self) {
        _city = [dict[@"city"] isKindOfClass:[NSString class]] ? dict[@"city"] : @"";
        _street = [dict[@"street"] isKindOfClass:[NSString class]] ? dict[@"street"] : @"";
    }
    return self;
}
- (instancetype)initWithJsonValue:(id)jsonValue {
    if ([jsonValue isKindOfClass:[NSDictionary class]]) {
        self = [self initWithJsonDictionary:jsonValue];
    } else {
        self = nil;
    }
    return self;
}
- (NSDictionary<NSString *, id<NSObject>> *)toJson {
    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:2];
    ret[@"city"] = _city;
    ret[@"street"] = _street;
    return [ret copy];
}
@end
// UserMixedItem.m
#import "UserMixedItem.h"
@implementation UserMixedItem
- (instancetype)initWithJsonValue:(id)jsonValue {
    self = [super init];
    if (self) {
        _number = [jsonValue isKindOfClass:[NSNumber class]] ? jsonValue : nil;
        _text = [jsonValue isKindOfClass:[NSString class]] ? jsonValue : nil;
    }
    return self;
}
- (id<NSObject>)toJson {
    if (_number) {
        return _number;
    } else if (_text) {
        return _text;
    }
    return nil;
}
@end
```

## ReverseJson Schema
Sometimes the inferred model requires some small adjustments, e.g. a field which has been inferred as non-optional should be optional.
Therefore ReverseJson allows to export a simple schema which then can be adjusted and be used to generate Swift or Objective-C code:

### Export ReverseJson schema

    ./ReverseJson export User testModel.json

The example from above produces the following schema:
```json
{
  "type" : "object",
  "$schema" : "https:\/\/github.com\/tomquist\/ReverseJson\/tree\/1.2.0",
  "properties" : {
    "mixed" : {
      "type" : "list",
      "content" : {
        "type" : "any",
        "of" : [
          "int",
          "text"
        ]
      }
    },
    "numbers" : {
      "type" : "list",
      "content" : "int"
    },
    "name" : "text",
    "internal" : "bool",
    "locations" : {
      "type" : "list",
      "content" : {
        "type" : "object",
        "properties" : {
          "lat" : "double",
          "lon" : "double",
          "address" : {
            "type" : "object",
            "isOptional" : true,
            "properties" : {
              "street" : "text",
              "city" : "text"
            }
          }
        }
      }
    },
    "is_private" : "bool"
  }
}
```

### Convert ReverseJson schema into Swift

    ./ReverseJson swift User mySchema.json

### General schema structure
A schema is a simple type description which always has the following structure:
```json
{
    "type": "<object|list|string|int|float|double|bool|any>",
    "isOptional": true
}
```
If there is only a "type" property, it is also possible to simply use the type identifier, e.g. the following expressions
```json
"string"
```
is identical to
```json
{
    "type": "string"
}
```

If the property "isOptional" is missing, the type is assumed to be non-optional. Instead of having a property "isOptional", it is also possible to just add a "?" as a suffix to the type name. E.g. this expression
```json
"string?"
```
is identical to
```json
{
    "type": "string",
    "isOptional": true
}
```

### Objects
Object have an additional property "properties" which is a JSON-object containing all properties, where the key is the property name and the value is a schema. Optionally you can add the "name" property to override the auto-generated name when converting the model to code. E.g.
```json
{
    "type": "object",
    "name": "MyObject",
    "properties": {
        "property1": {
            "type": "string"
        },
        "property2": "int?"
    }
}
```

### Lists
Lists describe their content-type using the "content" property. E.g.
```json
{
    "type": "list",
    "content": {
        "type": "object",
        "properties": {
            "id": "int",
            "name": "string",
            "description": "string?"
        }
    }
}
```

### Any
The type "any" allows to support multiple value types at the same place. To describe which types are allows, use the "of" property. Optionally you can add the "name" property to override the auto-generated name when converting the model to code. E.g.
```json
{
    "type": "any",
    "name": "MyObject",
    "of": [
        {
            "type": "object",
            "properties": {
                "id": "text",
                "name": "text",
                "description": "text?"
            }
        },
        "int"
    ]
}
```
