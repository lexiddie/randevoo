//
//  ReserveInformation.swift
//  randevoo
//
//  Created by Lex on 1/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper

class ReserveInformation: Mappable, Codable {
    
    var size: String! = ""
    var color: String! = ""
    var quantity: Int! = 0

    init(size: String, color: String, quantity: Int) {
        self.size = size
        self.color = color
        self.quantity = quantity
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        size <- map["size"]
        color <- map["color"]
        quantity <- map["quantity"]
    }
}
