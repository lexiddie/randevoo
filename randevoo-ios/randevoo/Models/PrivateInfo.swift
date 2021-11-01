//
//  PrivateInfo.swift
//  randevoo
//
//  Created by Lex on 10/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class PrivateInfo: Mappable, Codable {
    
    var id: String! = ""
    var lat: Double! = 0.0
    var long: Double! = 0.0

    init(lat: Double, long: Double) {
        self.lat = lat
        self.long = long
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        lat <- map["lat"]
        long <- map["long"]
    }
    
}
