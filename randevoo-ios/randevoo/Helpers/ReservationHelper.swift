//
//  ReservationHelper.swift
//  randevoo
//
//  Created by Xell on 16/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Hydra
import ObjectMapper

class ReservationHelper {
    
    let db = Firestore.firestore()
    
    func makingReservation(timeSlot: Timeslot, reservation: Reservation) -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            let _ = async({ _ -> Bool in
                let prodStatus = try await(self.checkProductBeforeReserve(reservation: reservation))
                return prodStatus
            }).then({ prodStatus in
                print("status in main scope \(prodStatus)")
                if prodStatus {
                    let _ = async({ _ -> Bool in
                        let status = try await(self.addTimeSlotToDb(timeSlot: timeSlot))
                        return status
                    }).then({ status in
                        print(status)
                        if status {
                            let _ = async({ _ -> Bool in
                                let status = try await(self.bookProduct(reservation: reservation))
                                return status
                            }).then({ status in
                                if status {
                                    resolve(true)
                                } else {
                                    resolve(false)
                                }
                                
                            })
                        } else {
                            resolve(false)
                        }
                    })
                } else {
                    resolve(false)
                }
            })
        }
    }
    
    func checkBeforeReserve(){
        
    }
    
    func checkProductBeforeReserve(reservation: Reservation) -> Promise<Bool>{
        let productRef = db.collection("products")
        var isUnavailable = false
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            for product in reservation.products {
                productRef.whereField("id", isEqualTo: product.productId).getDocuments() { (querySnapShot, err) in
                    if err != nil {
                        resolve(false)
                        print("Fail to retrieve product")
                    } else {
                        for document in querySnapShot!.documents {
                            let currentData = Mapper<Product>().map(JSONObject: document.data())
                            if currentData?.isActive == true && !(currentData?.isBanned)! && ((currentData?.isAvailable) == true) {
                                for info in currentData!.variants {
                                    if info.color == product.variant.color && info.size == product.variant.size {
                                        if info.available >= product.variant.quantity {
                                            print("resolve \(true)")
                                            resolve(true)
                                        } else {
                                            isUnavailable = true
                                            print("resolve \(false)")
                                            resolve(false)
                                            break
                                        }
                                    }
                                }
                            } else {
                                print("resolve outer scope \(false)")
                                isUnavailable = true
                                resolve(false)
                            }
                            
                        }
                    }
                }
                if isUnavailable {
                    break
                }
            }
            
        }
    }
    
    func addTimeSlotToDb(timeSlot: Timeslot) -> Promise<Bool>{
        let timeslotRef = db.collection("timeslots")
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            timeslotRef.document(timeSlot.id).setData(timeSlot.toJSON()) { err in
                if err != nil {
                    resolve(false)
                    print("Faild to add Timeslot to db")
                } else {
                    resolve(true)
                    print("Add product to db successfully")
                }
                
            }
        }
    }
    
    func bookProduct(reservation: Reservation) -> Promise<Bool>{
        let reservationRef = db.collection("reservations")
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            reservationRef.document(reservation.id).setData(reservation.toJSON()) { err in
                if err != nil {
                    resolve(false)
                    print("Faild to make Reservation")
                } else {
                    resolve(true)
                    print("Add product to db successfully")
                }
                
            }
        }
    }
    
}
