//
//  BizInfo.swift
//  randevoo
//
//  Created by Lex on 12/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class BizInfo: Mappable, Codable {
    
    var id: String! = ""
    var businessId: String! = ""
    var about: String! = ""
    var policy: String! = ""
    var email: String! = ""
    var phoneNumber: String! = ""
    var geoPoint: GeoPoint!
    var createdAt: String! = ""
    var isCurrent: Bool! = false

    init(id: String, businessId: String, about: String, policy: String = "", email: String = "", phoneNumber: String = "", geoPoint: GeoPoint, createdAt: String, isCurrent: Bool) {
        self.id = id
        self.businessId = businessId
        self.about = about
        self.policy = policy
        self.email = email
        self.phoneNumber = phoneNumber
        self.geoPoint = geoPoint
        self.createdAt = createdAt
        self.isCurrent = isCurrent
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        businessId <- map["businessId"]
        about <- map["about"]
        policy <- map["policy"]
        email <- map["email"]
        phoneNumber <- map["phoneNumber"]
        geoPoint <- map["geoPoint"]
        createdAt <- map["createdAt"]
        isCurrent <- map["isCurrent"]
    }
    
    func copy(with zone: NSZone? = nil) -> BizInfo {
        let copy = BizInfo(id: id, businessId: businessId, about: about, policy: policy, email: email, phoneNumber: phoneNumber, geoPoint: geoPoint, createdAt: createdAt, isCurrent: isCurrent)
        return copy
    }
}
