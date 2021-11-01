//
//  BizHour.swift
//  randevoo
//
//  Created by Alexander on 8/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class BizHour: Mappable, Codable {
    
    var dateLabel: String! = ""
    var openTime: String! = ""
    var closeTime: String! = ""
    var isActive: Bool! = true

    init(dateLabel: String, openTime: String, closeTime: String, isActive: Bool) {
        self.dateLabel = dateLabel
        self.openTime = openTime
        self.closeTime = closeTime
        self.isActive = isActive
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        dateLabel <- map["dateLabel"]
        openTime <- map["openTime"]
        closeTime <- map["closeTime"]
        isActive <- map["isActive"]
    }
}



 
