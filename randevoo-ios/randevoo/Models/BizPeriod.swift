//
//  BizPeriod.swift
//  randevoo
//
//  Created by Alexander on 8/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class BizPeriod: Mappable, Codable {
    
    var id: String! = ""
    var businessId: String! = ""
    var bizHours: [BizHour] = []
    var bizRange: Period!
    var bizTimeslot: Period!
    var bizAvailability: Period!
    var createdAt: String! = ""

    init(id: String, businessId: String, bizHours: [BizHour], bizRange: Period, bizTimeslot: Period, bizAvailability: Period, createdAt: String) {
        self.id = id
        self.businessId = businessId
        self.bizHours = bizHours
        self.bizRange = bizRange
        self.bizTimeslot = bizTimeslot
        self.bizAvailability = bizAvailability
        self.createdAt = createdAt
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        businessId <- map["businessId"]
        bizHours <- map["bizHours"]
        bizRange <- map["bizRange"]
        bizTimeslot <- map["bizTimeslot"]
        bizAvailability <- map["bizAvailability"]
        createdAt <- map["createdAt"]
    }
    
    func copy(with zone: NSZone? = nil) -> BizPeriod {
        let copy = BizPeriod(id: id, businessId: businessId, bizHours: bizHours, bizRange: bizRange, bizTimeslot: bizTimeslot, bizAvailability: bizAvailability, createdAt: createdAt)
        return copy
    }
}



