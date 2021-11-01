//
//  ReservedProduct.swift
//  randevoo
//
//  Created by Xell on 16/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import Foundation
import ObjectMapper

class ReservedProduct: Mappable, Codable  {
    
    var productId: String! = ""
    var variant: Variant!
    
    init(productId: String, variant: Variant) {
        self.productId = productId
        self.variant = variant
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        productId <- map["productId"]
        variant <- map["variant"]
    }
}
