//
//  MessagesProvider.swift
//  randevoo
//
//  Created by Lex on 11/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseMessaging
import FirebaseStorage
import Alamofire
import AlamofireImage
import ObjectMapper
import SwiftyJSON
import Hydra


class MessagesProvider {
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    var messenger: Messenger!
    
    func checkMessenger(accountId: String, memberId: String) -> Promise<Bool> {
        let users = [accountId, memberId]
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            self.verifyExistedMessengers(users: users).then { (messengers) in
                if messengers.count == 0 {
                    resolve(false)
                } else {
                    for i in messengers {
                        if i.members.contains(accountId) {
                            if i.members.contains(memberId) {
                                self.messenger = i
                                resolve(true)
                            }
                        }
                    }
                    resolve(false)
                }
            }
        }
    }
    
    private func verifyExistedMessengers(users: [String]) -> Promise<[Messenger]> {
        let messengerRef = db.collection("messengers")
        return Promise<[Messenger]>(in: .background) { (resolve, reject, _) in
            messengerRef
                .whereField("members", arrayContainsAny: users)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        resolve([])
                    } else {
                        var tempList: [Messenger] = []
                        for document in querySnapshot!.documents {
                            let messenger = Mapper<Messenger>().map(JSONObject: document.data())!
                            tempList.append(messenger)
                        }
                        resolve(tempList)
                    }
                }
        }
    }
 
    func createMessenger(accountId: String, memberId: String) -> Promise<Messenger> {
        let messengerRef = db.collection("messengers")
        let messengerId = messengerRef.document().documentID
        let members: [String] = [accountId, memberId]
        let messenger = Messenger(id: messengerId, members: members, createdAt: Date().iso8601withFractionalSeconds)
        return Promise<Messenger>(in: .background) { (resolve, reject, _) in
            messengerRef.document(messengerId).setData(messenger.toJSON()) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    reject(err)
                } else {
                    print("Messenger successfully written!")
                    resolve(messenger)
                }
            }
        }
    }
    
    func fetchMessengers(accountId: String) -> Promise<[Messenger]> {
        let messengerRef = db.collection("messengers")
        return Promise<[Messenger]>(in: .background) { (resolve, reject, _) in
            messengerRef.whereField("members", arrayContains: accountId)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        resolve([])
                    } else {
                        var tempList: [Messenger] = []
                        for document in querySnapshot!.documents {
                            let messenger = Mapper<Messenger>().map(JSONObject: document.data())!
                            tempList.append(messenger)
                        }
                        resolve(tempList)
                    }
                }
        }
    }
    
    func fetchMessenger(accountId: String, memberId: String) -> Promise<Messenger> {
        let messengerRef = db.collection("messengers")
        return Promise<Messenger>(in: .background) { (resolve, reject, _) in
            messengerRef
                .whereField("members", arrayContainsAny: [accountId, memberId])
                .limit(to: 1)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        reject(err)
                    } else {
                        for document in querySnapshot!.documents {
                            let messenger = Mapper<Messenger>().map(JSONObject: document.data())!
                            resolve(messenger)
                        }
                    }
                }
        }
    }
    
    func fetchMessenger(messengerId: String) -> Promise<Messenger> {
        let messengerRef = db.collection("messengers")
        return Promise<Messenger>(in: .background) { (resolve, reject, _) in
            messengerRef.document(messengerId).getDocument { (document, err) in
                if let document = document, document.exists {
                    let result = Mapper<Messenger>().map(JSONObject: document.data())!
                    resolve(result)
                } else {
                    print("Messenger does not exist")
                    reject(err!)
                }
            }
        }
    }
    
    func getMemberIds(accountId: String, messengers: [Messenger]) -> [String] {
        var tempList: [String] = []
        for i in messengers {
            if let member = i.members.first(where: {$0 != accountId}) {
                tempList.append(member)
            }
        }
        return tempList
    }
    
    func getSenderIds(activities: [Activity]) -> [String] {
        var tempList: [String] = []
        for i in activities {
            if !tempList.contains(i.senderId) {
                tempList.append(i.senderId)
            }
        }
        return tempList
    }
    
    func fetchCachedStores(accountIds: [String]) -> Promise<[User]> {
        let businessRef = db.collection("businesses")
        return Promise<[User]>(in: .background) { (resolve, reject, _) in
            var tempList: [User] = []
            for (_, element) in accountIds.enumerated() {
                businessRef.document(element).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let result = Mapper<User>().map(JSONObject: document.data())!
                        tempList.append(result)
                    } else {
                        print("Store does not exist")
                    }
                    if tempList.count == accountIds.count {
                        resolve(tempList)
                    }
                }
            }
        }
    }
    
    func fetchCachedUsers(accountIds: [String]) -> Promise<[User]> {
        let userRef = db.collection("users")
        return Promise<[User]>(in: .background) { (resolve, reject, _) in
            var tempList: [User] = []
            for (_, element) in accountIds.enumerated() {
                userRef.document(element).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let result = Mapper<User>().map(JSONObject: document.data())!
                        tempList.append(result)
                    } else {
                        print("User does not exist")
                    }
                    if tempList.count == accountIds.count {
                        resolve(tempList)
                    }
                }
            }
        }
    }
    
    
    // Limit 100
    func fetchMessages(messengerId: String) -> Promise<[iMessage]> {
        let messageRef = db.collection("messages")
        return Promise<[iMessage]>(in: .background) { (resolve, reject, _) in
            messageRef
                .document(messengerId)
                .collection("contents")
                .order(by: "createdAt", descending: true)
                .limit(to: 100)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        resolve([])
                    } else {
                        var tempList: [iMessage] = []
                        for document in querySnapshot!.documents {
                            let message = Mapper<iMessage>().map(JSONObject: document.data())!
                            tempList.append(message)
                        }
                        resolve(tempList)
                    }
                }
        }
    }
    
    
    // Limit 100
    func fetchActivities(accountId: String) -> Promise<[Activity]> {
        let activityRef = db.collection("activities")
        return Promise<[Activity]>(in: .background) { (resolve, reject, _) in
            activityRef
                .whereField("receiverId", isEqualTo: accountId)
                .order(by: "createdAt", descending: true)
                .limit(to: 100)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        resolve([])
                    } else {
                        var tempList: [Activity] = []
                        for document in querySnapshot!.documents {
                            let activity = Mapper<Activity>().map(JSONObject: document.data())!
                            tempList.append(activity)
                        }
                        resolve(tempList)
                    }
                }
        }
    }
    
    func saveMessage(messengerId: String, senderId: String, receiverId: String, message: Message)-> Promise<Bool> {
        let messageRef = db.collection("messages")
        let content = getContent(message: message)
        let record = iMessage(id: message.messageId, type: message.kind.messageKindString, content: content, senderId: senderId, receiverId: receiverId, createdAt: message.sentDate.iso8601withFractionalSeconds)
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            messageRef.document(messengerId).collection("contents").document(message.messageId).setData(record.toJSON()) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    resolve(false)
                } else {
//                    print("Message successfully written!")
                    self.updateMessenger(messengerId: messengerId, message: record)
                    resolve(true)
                }
            }
        }
    }
    
    func updateMessageState(messengerId: String, messageId: String) {
        let messageRef = db.collection("messages")
        messageRef.document(messengerId).collection("contents").document(messageId).updateData([
            "isRead": true
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
//                print("Message is read state!")
            }
        }
    }
    
    func savePhoto(with uploadData: Data) -> Promise<String> {
        return Promise<String>(in: .background) { (resolve, reject, _) in
            let filename = NSUUID().uuidString
            let storagePhotoName = self.storage.reference().child("message_images").child(filename)
            storagePhotoName.putData(uploadData, metadata: nil) { (metadata, err) in
                if let err = err {
                    print("Failed to upload profile photo \(err)")
                    resolve("")
                }
                storagePhotoName.downloadURL(completion: { (downloadURL, err) in
                    guard err == nil else{
                        print("failed to upload image")
                        resolve("")
                        return
                    }
                    guard let url = downloadURL else {
                        print("failed to get download URL")
                        resolve("")
                        return
                    }
                    let urlString = url.absoluteString
                    resolve(urlString)
                })
            }
        }
    }
    
    private func updateMessenger(messengerId: String, message: iMessage) {
        let messengerRef = db.collection("messengers")
        messengerRef.document(messengerId).updateData([
            "isEmpty": false,
            "recent": message.toJSON()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
//                print("Messenger is updated successfully!")
            }
        }
    }
    
    private func getContent(message: Message) -> String {
        var content = ""
        switch message.kind {
        case .text(let messageText):
            content = messageText
        case .attributedText(_):
            break
        case .photo(let mediaItem):
            content = mediaItem.url!.absoluteString
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        return content
    }
    
}
