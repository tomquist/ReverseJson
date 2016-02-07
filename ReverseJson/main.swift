//
//  main.swift
//  ReverseJson
//
//  Created by Tom Quist on 07.02.16.
//  Copyright © 2016 Tom Quist. All rights reserved.
//

import Foundation


let testModel: [NSObject: AnyObject] = [
    "locations": [
        ["lat": 10.5, "lon": NSNull(), "enum test": "bla"],
        ["lat": 10.5, "lon": "abc", "bla": [[[[["test":"a"]]]]], "enum test": [:]],
        ["lat": 10, "lon": 49.1, "bla": [[[[["test":123]]]]], "enum test": "bla"],
    ],
    "name": NSNull(),
    "blup": [["obj1": 10], ["obj1": "test"]],
    "numbers": [10,11,12],
    "mixed": [10,true,"hallo", ["field": "value"], ["otherField": 10], 1.2],
    "height": 10,
    "is_true": true,
    "private": false,
    "internal": false,
    "public": false,
    "let": false,
]


if let rootType = try? ModelParser().decode(testModel) {
    print(SwiftModelCreator().translate(rootType, name: "User"))
    print(SwiftJsonParsingTranslator().translate(rootType, name: "User"))
}





