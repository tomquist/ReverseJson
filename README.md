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
   -c,  --class            Swift: Use classes instead of structs for objects
   -ca, --contiguousarray  Swift: Use ContiguousArray for lists
   -m,  --mutable          Swift: All object fields are mutable (var instead of let)
   -pt, --publictypes      Swift: Make type declarations public instead of internal
   -pf, --publicfields     Swift: Make field declarations public instead of internal
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