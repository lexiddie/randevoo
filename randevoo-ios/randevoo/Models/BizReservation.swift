//
//  BizReservation.swift
//  randevoo
//
//  Created by Lex on 6/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class BizReservation: Mappable, Codable {
    
    var id: String! = ""
    var businessId: String! = ""
    var qrCode: String! = ""
    var status: String! = ""
    var isCanceled: Bool! = false
    var canceledBy: String = ""
    var canceledAt: String! = ""
    var createdAt: String! = ""
    var approvedAt: String! = ""
    var completedAt: String! = ""
    var products: [ReservedProduct] = []
    var user: User!
    var timeslot: Timeslot!
    
    init(reservation: Reservation, user: User, timeslot: Timeslot) {
        self.id = reservation.id
        self.businessId = reservation.businessId
        self.qrCode = reservation.qrCode
        self.status = reservation.status
        self.isCanceled = reservation.isCanceled
        self.canceledBy = reservation.canceledBy
        self.canceledAt = reservation.canceledAt
        self.createdAt = reservation.createdAt
        self.approvedAt = reservation.approvedAt
        self.completedAt = reservation.completedAt
        self.products = reservation.products
        self.user = user
        self.timeslot = timeslot
    }
    
    func updateData(reservation: Reservation) {
        self.id = reservation.id
        self.businessId = reservation.businessId
        self.qrCode = reservation.qrCode
        self.status = reservation.status
        self.isCanceled = reservation.isCanceled
        self.canceledBy = reservation.canceledBy
        self.canceledAt = reservation.canceledAt
        self.createdAt = reservation.createdAt
        self.approvedAt = reservation.approvedAt
        self.completedAt = reservation.completedAt
        self.products = reservation.products
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        businessId <- map["businessId"]
        qrCode <- map["qrCode"]
        status <- map["status"]
        isCanceled <- map["isCanceled"]
        canceledBy <- map["canceledBy"]
        canceledAt <- map["canceledAt"]
        createdAt <- map["createdAt"]
        approvedAt <- map["approvedAt"]
        completedAt <- map["completedAt"]
        products <- map["reserves"]
        user <- map["user"]
        timeslot <- map["timeslot"]
    }
}
