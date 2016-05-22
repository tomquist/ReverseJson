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

## Usage
### Build

	xcrun swiftc ReverseJson/*.swift -o ReverseJson

### General usage:

```
Usage: ReverseJson (swift|objc) NAME FILE <options>
e.g. ReverseJson swift User testModel.json <options>
Options:
   -c,  --class            (Swift) Use classes instead of structs for objects
   -ca, --contiguousarray  (Swift) Use ContiguousArray for lists
   -pt, --publictypes      (Swift) Make type declarations public instead of internal
   -pf, --publicfields     (Swift) Make field declarations public instead of internal
   -n,  --nullable         (Swift and Objective-C) Make all field declarations optional (nullable in Objective-C)
   -m,  --mutable          (Swift and Objective-C) All object fields are mutable (var instead of
                           let in Swift and 'readwrite' instead of 'readonly' in Objective-C)
   -a,  --atomic           (Objective-C) Make properties 'atomic'
   -p <prefix>             (Objective-C) Class-prefix to use for type declarations
   --prefix <prefix>       
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
struct User {
    enum MixedItem {
        case Number(Int)
        case Text(String)
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

enum JsonParsingError: ErrorType {
    case UnsupportedTypeError
}

extension String {
    init(jsonValue: AnyObject?) throws {
        guard let string = jsonValue as? String else {
            throw JsonParsingError.UnsupportedTypeError
        }
        self = string
    }
}

extension Bool {
    init(jsonValue: AnyObject?) throws {
        if let number = jsonValue as? NSNumber {
            self = number.boolValue
        } else if let number = jsonValue as? Bool {
            self = number
        } else if let number = jsonValue as? Double {
            self = Bool(number)
        } else if let number = jsonValue as? Float {
            self = Bool(number)
        } else if let number = jsonValue as? Int {
            self = Bool(number)
        } else {
            throw JsonParsingError.UnsupportedTypeError
        }
    }
}

extension Array {
    init(jsonValue: AnyObject?, map: AnyObject throws -> Element) throws {
        guard let items = jsonValue as? [AnyObject] else {
            throw JsonParsingError.UnsupportedTypeError
        }
        self = try items.map(map)
    }
}

extension Double {
    init(jsonValue: AnyObject?) throws {
        if let number = jsonValue as? NSNumber {
            self = number.doubleValue
        } else if let number = jsonValue as? Int {
            self = Double(number)
        } else if let number = jsonValue as? Double {
            self = number
        } else if let number = jsonValue as? Float {
            self = Double(number)
        } else {
            throw JsonParsingError.UnsupportedTypeError
        }
    }
}

extension Int {
    init(jsonValue: AnyObject?) throws {
        if let number = jsonValue as? NSNumber {
            self = number.integerValue
        } else if let number = jsonValue as? Int {
            self = number
        } else if let number = jsonValue as? Double {
            self = Int(number)
        } else if let number = jsonValue as? Float {
            self = Int(number)
        } else {
            throw JsonParsingError.UnsupportedTypeError
        }
    }
}

extension Optional {
    init(jsonValue: AnyObject?, map: AnyObject throws -> Wrapped) throws {
        if let jsonValue = jsonValue where !(jsonValue is NSNull) {
            self = try map(jsonValue)
        } else {
            self = nil
        }
    }
}

extension User.MixedItem {
    init(jsonValue: AnyObject?) throws {
        if let value = try? Int(jsonValue: jsonValue) {
            self = Number(value)
        } else if let value = try? String(jsonValue: jsonValue) {
            self = Text(value)
        } else {
            throw JsonParsingError.UnsupportedTypeError
        }
    }
}

extension User.LocationsItem.Address {
    init(jsonValue: AnyObject?) throws {
        guard let dict = jsonValue as? [NSObject: AnyObject] else {
            throw JsonParsingError.UnsupportedTypeError
        }
        self.city = try String(jsonValue: dict["city"])
        self.street = try String(jsonValue: dict["street"])
    }
}

extension User.LocationsItem {
    init(jsonValue: AnyObject?) throws {
        guard let dict = jsonValue as? [NSObject: AnyObject] else {
            throw JsonParsingError.UnsupportedTypeError
        }
        self.lat = try Double(jsonValue: dict["lat"])
        self.lon = try Double(jsonValue: dict["lon"])
        self.address = try Optional(jsonValue: dict["address"]) { try User.LocationsItem.Address(jsonValue: $0) }
    }
}

extension User {
    init(jsonValue: AnyObject?) throws {
        guard let dict = jsonValue as? [NSObject: AnyObject] else {
            throw JsonParsingError.UnsupportedTypeError
        }
        self.mixed = try Array(jsonValue: dict["mixed"]) { try User.MixedItem(jsonValue: $0) }
        self.isPrivate = try Bool(jsonValue: dict["is_private"])
        self.numbers = try Array(jsonValue: dict["numbers"]) { try Int(jsonValue: $0) }
        self.name = try String(jsonValue: dict["name"])
        self.locations = try Array(jsonValue: dict["locations"]) { try User.LocationsItem(jsonValue: $0) }
        self.`internal` = try Bool(jsonValue: dict["internal"])
    }
}

func parseUser(jsonValue: AnyObject?) throws -> User {
    return try User(jsonValue: jsonValue)
}
```

...or into this...

```objective-c
#import <Foundation/Foundation.h>

@class UserLocationsItemAddress;
NS_ASSUME_NONNULL_BEGIN
@interface UserLocationsItem : NSObject
- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;
- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;
@property (nonatomic, strong, readonly, nullable) UserLocationsItemAddress *address;
@property (nonatomic, assign, readonly) double lat;
@property (nonatomic, assign, readonly) double lon;
@end
NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN
@interface UserLocationsItemAddress : NSObject
- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;
- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;
@property (nonatomic, copy, readonly) NSString *city;
@property (nonatomic, copy, readonly) NSString *street;
@end
NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN
@interface UserMixedItem : NSObject
- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;
@property (nonatomic, assign, readonly) NSInteger number;
@property (nonatomic, copy, readonly) NSString *text;
@end
NS_ASSUME_NONNULL_END

@class UserLocationsItem, UserMixedItem;
NS_ASSUME_NONNULL_BEGIN
@interface User : NSObject
- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;
- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;
@property (nonatomic, assign, readonly) BOOL internal;
@property (nonatomic, assign, readonly) BOOL isPrivate;
@property (nonatomic, strong, readonly) NSArray<NSNumber/*NSInteger*/ *> *numbers;
@property (nonatomic, strong, readonly) NSArray<UserLocationsItem *> *locations;
@property (nonatomic, strong, readonly) NSArray<UserMixedItem *> *mixed;
@property (nonatomic, copy, readonly) NSString *name;
@end
NS_ASSUME_NONNULL_END

@implementation UserLocationsItemAddress
- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dict {
    self = [super init];
    if (self) {
        _city = [dict[@"city"] isKindOfClass:[NSString class]] ? dict[@"city"] : nil;
        _street = [dict[@"street"] isKindOfClass:[NSString class]] ? dict[@"street"] : nil;
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
@end

@implementation UserMixedItem
- (instancetype)initWithJsonValue:(id)jsonValue {
    self = [super init];
    if (self) {
        _number = [jsonValue isKindOfClass:[NSNumber class]] ? [jsonValue integerValue] : 0;
        _text = [jsonValue isKindOfClass:[NSString class]] ? jsonValue : nil;
    }
    return self;
}
@end

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
            [values copy];
        });
        _locations = ({
            id value = dict[@"locations"];
            NSMutableArray<UserLocationsItem *> *values = nil;
            if ([value isKindOfClass:[NSArray class]]) {
                NSArray *array = value;
                values = [NSMutableArray arrayWithCapacity:array.count];
                for (id item in array) {
                    UserLocationsItem *parsedItem = [[UserLocationsItem alloc] initWithJsonValue:item];
                    [values addObject:parsedItem ?: (id)[NSNull null]];
                }
            }
            [values copy];
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
            [values copy];
        });
        _name = [dict[@"name"] isKindOfClass:[NSString class]] ? dict[@"name"] : nil;
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
@end

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
@end
```