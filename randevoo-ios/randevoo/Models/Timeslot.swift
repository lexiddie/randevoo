//
//  Timeslot.swift
//  randevoo
//
//  Created by Lex on 22/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class Timeslot: Mappable, Codable {
    
    var id: String! = ""
    var businessId: String! = ""
    var userId: String! = ""
    var date: String! = ""
    var time: String! = ""
    var isApproved: Bool! = false
    
    init(id: String, businessId: String, userId: String, date: String, time: String, isApproved: Bool = false) {
        self.id = id
        self.businessId = businessId
        self.userId = userId
        self.date = date
        self.time = time
        self.isApproved = isApproved
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        businessId <- map["businessId"]
        userId <- map["userId"]
        date <- map["date"]
        time <- map["time"]
        isApproved <- map["isApproved"]
    }
}

