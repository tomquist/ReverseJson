//
//  main.swift
//  ReverseJson
//
//  Created by Tom Quist on 07.02.16.
//  Copyright © 2016 Tom Quist. All rights reserved.
//

import Foundation
import ReverseJsonCommandLine

do {
    let reverseJson = try ReverseJson(args: CommandLine.arguments)
    print(try reverseJson.main())
    exit(0)
} catch let error as ReverseJsonError {
    print(error)
    print(ReverseJson.usage())
    exit(1)
} catch {
    print(error)
    exit(1)
}
