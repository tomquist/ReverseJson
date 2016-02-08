//
//  main.swift
//  ReverseJson
//
//  Created by Tom Quist on 07.02.16.
//  Copyright © 2016 Tom Quist. All rights reserved.
//

import Foundation

let testModel = try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: "testModel.json")!, options: [])

if let rootType = try? ModelParser().decode(testModel) {
    print(SwiftModelCreator().translate(rootType, name: "User"))
    print(SwiftJsonParsingTranslator().translate(rootType, name: "User"))
}



