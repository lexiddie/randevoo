//
//  LocationPointHelper.swift
//  randevoo
//
//  Created by Lex on 1/01/2021.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class LocationPointHelper {
    
    func getCurrentLocationPoint(country: String = "Thailand") -> LocationPoint? {
        let currents = Mapper<LocationPoint>().mapArray(JSONfile: "Locations.json")!
        for i in currents {
            if country == i.name {
                let locationPoint = i
                locationPoint.regions = i.regions.sorted(by: {$0.name < $1.name})
                return locationPoint
            }
        }
        return nil
    }
}
