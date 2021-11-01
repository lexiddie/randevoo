//
//  Variant.swift
//  randevoo
//
//  Created by Lex on 18/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class Variant: Mappable, Codable {
    
    var color: String! = ""
    var size: String! = ""
    var quantity: Int! = 0
    var available: Int! = 0
    var reserve: Int! = 0
    var isDeletable: Bool! = true

    init(color: String, size: String, quantity: Int, available: Int = 0) {
        self.color = color
        self.size = size
        self.quantity = quantity
        self.available = available
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        color <- map["color"]
        size <- map["size"]
        quantity <- map["quantity"]
        available <- map["available"]
    }
    
    func copy(with zone: NSZone? = nil) -> Variant {
        let copy = Variant(color: color, size: size, quantity: quantity, available: available)
        return copy
    }
}

