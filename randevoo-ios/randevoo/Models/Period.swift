//
//  Period.swift
//  randevoo
//
//  Created by Alexander on 8/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class Period: Mappable, Codable {
    
    var label: String! = ""
    var value: Double = 0

    init(label: String, value: Double) {
        self.label = label
        self.value = value
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        label <- map["label"]
        value <- map["value"]
    }
}


