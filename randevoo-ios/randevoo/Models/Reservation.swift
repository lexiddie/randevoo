//
//  Reservation.swift
//  randevoo
//
//  Created by Xell on 16/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class Reservation: Mappable, Codable {
    
    var id: String! = ""
    var businessId: String! = ""
    var userId: String! = ""
    var qrCode: String! = ""
    var timeslotId: String! = ""
    var products: [ReservedProduct] = []
    var status: String! = ""
    var reason: String! = ""
    var isCanceled: Bool! = false
    var canceledBy: String = ""
    var canceledAt: String! = ""
    var createdAt: String! = ""
    var approvedAt: String! = ""
    var completedAt: String! = ""
    
    init(id: String, businessId: String, userId: String, qrCode: String, timeslotId: String, products: [ReservedProduct], status: String, reason: String = "", isCanceled: Bool = false, canceledBy: String = "", canceledAt: String = "", createdAt: String, approvedAt: String = "", completedAt: String = "") {
        self.id = id
        self.businessId = businessId
        self.userId = userId
        self.qrCode = qrCode
        self.timeslotId = timeslotId
        self.products = products
        self.status = status
        self.reason = reason
        self.isCanceled = isCanceled
        self.canceledBy = canceledBy
        self.canceledAt = canceledAt
        self.createdAt = createdAt
        self.approvedAt = approvedAt
        self.completedAt = completedAt
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        businessId <- map["businessId"]
        userId <- map["userId"]
        qrCode <- map["qrCode"]
        timeslotId <- map["timeslotId"]
        products <- map["products"]
        status <- map["status"]
        reason <- map["reason"]
        isCanceled <- map["isCanceled"]
        canceledBy <- map["canceledBy"]
        canceledAt <- map["canceledAt"]
        createdAt <- map["createdAt"]
        approvedAt <- map["approvedAt"]
        completedAt <- map["completedAt"]
    }
    
    func copy(with zone: NSZone? = nil) -> Reservation {
        let copy = Reservation(id: id, businessId: businessId, userId: userId, qrCode: qrCode, timeslotId: timeslotId, products: products, status: status, reason: reason, isCanceled: isCanceled, canceledBy: canceledBy, canceledAt: canceledAt, createdAt: createdAt, approvedAt: approvedAt, completedAt: completedAt)
        return copy
    }
}


