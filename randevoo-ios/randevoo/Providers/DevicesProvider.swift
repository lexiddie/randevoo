//
//  DevicesProvider.swift
//  randevoo
//
//  Created by Lex on 1/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseMessaging
import ObjectMapper
import SwiftyJSON
import Hydra

class DevicesProvider {
    
    private let db = Firestore.firestore()
    
    func validateDeviceToken(accountId: String) {
        self.checkDeviceExists(accountId: accountId).then { (check) in
            guard let fcmToken = Messaging.messaging().fcmToken else { return }
            print("FCM Token in MainController: ", fcmToken)
            if !check {
                print("This Account does not have device setup yet")
                self.initialDevice(accountId: accountId, fcmToken: fcmToken)
            } else {
                self.filterDeviceExists(accountId: accountId, fcmToken: fcmToken)
            }
        }
    }
    
    private func checkDeviceExists(accountId: String) -> Promise<Bool> {
        let deviceRef = db.collection("devices")
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            deviceRef
                .whereField("accountId", isEqualTo: accountId)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        reject(err)
                    } else {
                        if querySnapshot!.documents.count == 0 {
                            resolve(false)
                        } else {
                            resolve(true)
                        }
                    }
                }
        }
    }
    
    private func filterDeviceExists(accountId: String, fcmToken: String) {
        let deviceRef = db.collection("devices")
        deviceRef
            .whereField("accountId", isEqualTo: accountId)
            .limit(to: 1)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let currentDevice = Mapper<Device>().map(JSONObject: document.data())!
                        let tokens = currentDevice.tokens
                        let checkContain = tokens.contains { (item) -> Bool in
                            item.fcmToken == fcmToken
                        }
                        if checkContain {
                            print("Current Token is existed in Server")
                        } else if tokens.count < 3 {
                            let tokenId = deviceRef.document().documentID
                            let nextToken = Token(id: tokenId, fcmToken: fcmToken, createdAt: Date().iso8601withFractionalSeconds)
                            currentDevice.tokens.append(nextToken)
                            deviceRef.document(currentDevice.id).updateData(currentDevice.toJSON()) { err in
                                if let err = err {
                                    print("Add token is error: \(err)")
                                } else {
                                    print("Add token is completed")
                                }
                            }
                        } else {
                            var sortedTokens = tokens.sorted(by: {$0.createdAt.iso8601withFractionalSeconds! < $1.createdAt.iso8601withFractionalSeconds!})
                            sortedTokens.remove(at: 0)
                            let tokenId = deviceRef.document().documentID
                            let nextToken = Token(id: tokenId, fcmToken: fcmToken, createdAt: Date().iso8601withFractionalSeconds)
                            sortedTokens.append(nextToken)
                            currentDevice.tokens = sortedTokens
                            deviceRef.document(currentDevice.id).updateData(currentDevice.toJSON()) { err in
                                if let err = err {
                                    print("Replace token is error: \(err)")
                                } else {
                                    print("Replace token is completed")
                                }
                            }
                        }
                    }
                }
            }
    }
    
    private func initialDevice(accountId: String, fcmToken: String) {
        let deviceRef = db.collection("devices")
        let deviceId = deviceRef.document().documentID
        let tokenId = deviceRef.document().documentID
        var fcmTokens: [Token] = []
        let firstToken = Token(id: tokenId, fcmToken: fcmToken, createdAt: Date().iso8601withFractionalSeconds)
        fcmTokens.append(firstToken)
        let device = Device(id: deviceId, accountId: accountId, tokens: fcmTokens)
        deviceRef.document(deviceId).setData(device.toJSON()) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Device has been initialized successfully!")
            }
        }
    }
    
    private func fetchDevice(accountId: String) -> Promise<Device> {
        let deviceRef = db.collection("devices")
        return Promise<Device>(in: .background) { (resolve, reject, _) in
            deviceRef
                .whereField("accountId", isEqualTo: accountId)
                .limit(to: 1)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        reject(err)
                    } else {
                        for document in querySnapshot!.documents {
                            let device = Mapper<Device>().map(JSONObject: document.data())!
                            resolve(device)
                        }
                    }
                    
                }
        }
    }
    
    private func fetchAccounts(userId: String) -> Promise<[String]> {
        let businessRef = db.collection("businesses")
        return Promise<[String]>(in: .background) { (resolve, reject, _) in
            businessRef
                .whereField("userId", isEqualTo: userId)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        resolve([])
                    } else {
                        var tempList: [String] = []
                        for document in querySnapshot!.documents {
                            let business = Mapper<BusinessAccount>().map(JSONObject: document.data())!
                            tempList.append(business.id)
                        }
                        resolve(tempList)
                    }
                }
        }
    }
    
    func removeToken(userId: String, fcmToken: String) {
        print("Current token to remove", fcmToken)
        print("\n")
        var users: [String] = []
        users.append(userId)
        fetchAccounts(userId: userId).then { (accounts) in
            users.append(contentsOf: accounts)
            print("\nAccounts: \(JSON(users))")
            print("Checking Total Accounts", users.count)
            for i in users {
                self.fetchDevice(accountId: i).then { (device) in
                    let before = Mapper().toJSONString(device, prettyPrint: true)!
                    print("\nBefore Device: \(before)")
                    let tokens = device.tokens.filter({$0.fcmToken != fcmToken})
                    device.tokens = tokens
                    print("\n")
                    let json = Mapper().toJSONString(device, prettyPrint: true)!
                    print("\nDevice: \(json)")
                    self.updateDevice(device: device)
                }
            }
        }
    }
    
    private func updateDevice(device: Device) {
        let deviceRef = db.collection("devices")
        deviceRef.document(device.id).updateData([
            "tokens": device.tokens.toJSON()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Updated device successfully!")
            }
        }
    }
}
