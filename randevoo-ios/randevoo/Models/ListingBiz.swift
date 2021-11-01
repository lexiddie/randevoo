//
//  ListingBiz.swift
//  randevoo
//
//  Created by Alexander on 15/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class ListingBiz: Mappable, Codable {
    
    var businessId: String!
    var bizName: String! = ""
    var bizUsername: String! = ""
    var bizProfileUrl: String! = ""
    var bizLocation: String! = ""

    init(businessId: String, bizName: String, bizUsername: String = "", bizProfileUrl: String = "", bizLocation: String = "") {
        self.businessId = businessId
        self.bizName = bizName
        self.bizUsername = bizUsername
        self.bizProfileUrl = bizProfileUrl
        self.bizLocation = bizLocation
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        businessId <- map["businessId"]
        bizName <- map["bizName"]
        bizUsername <- map["bizUsername"]
        bizProfileUrl <- map["bizProfileUrl"]
        bizLocation <- map["bizLocation"]
    }
}
