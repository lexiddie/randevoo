//
//  LocationPoint.swift
//  randevoo
//
//  Created by Lex on 1/01/2021.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class LocationPoint: Mappable, Codable {
    
    var name: String! = ""
    var dialCode: String! = ""
    var code: String! = ""
    var currency: Currency!
    var regions: [Region] = []

    init(name: String, dialCode: String, code: String, currency: Currency, regions: [Region] ) {
        self.name = name
        self.dialCode = dialCode
        self.code = code
        self.currency = currency
        self.regions = regions
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        name <- map["name"]
        dialCode <- map["dialCode"]
        code <- map["code"]
        currency <- map["currency"]
        regions <- map["regions"]
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = LocationPoint(name: name, dialCode: dialCode, code: code, currency: currency, regions: regions)
        return copy
    }
}

