//
//  Variation.swift
//  randevoo
//
//  Created by Lex on 21/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class Variation: Mappable, Codable {
    
    var id: String! = ""
    var label: String! = ""
    var name: String! = ""
    var values: [String] = []
    
    init(id: String, label: String, name: String, values: [String]) {
        self.id = id
        self.label = label
        self.name = name
        self.values = values
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        label <- map["label"]
        name <- map["name"]
        values <- map["values"]
    }
}
