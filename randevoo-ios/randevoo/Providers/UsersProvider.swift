//
//  UsersProvider.swift
//  randevoo
//
//  Created by Lex on 13/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Hydra

class UsersProvider {
    
    private let db = Firestore.firestore()
    private let concatenationHelper = ConcatenationHelper()
    
    func findUsernameViaEmail(email: String) -> Promise<String> {
        var firstCheck = false
        var secondCheck = false
        let currentUsername = concatenationHelper.getUsernameViaEmail(email: email)
        var username = currentUsername
        return Promise<String>(in: .background) { (resolve, reject, _) in
            for i in 0...100 {
                let number = Int.random(in: 0..<200)
                if i != 0 {
                    username = currentUsername + String(number)
                }
                let (first, second) = try await(zip(self.findUsernameFromUsers(username: username), self.findUsernameFromBusinesses(username: username)))
                firstCheck = first
                secondCheck = second
                if !firstCheck && !secondCheck {
                    print("This is the main username \(username)")
                    resolve(username)
                    return
                }
            }
            resolve("undefined")
        }
    }
    
    func findUsernameViaName(name: String) -> Promise<String> {
        var firstCheck = false
        var secondCheck = false
        let currentUsername = concatenationHelper.getUsernameViaName(name: name)
        var username = currentUsername
        return Promise<String>(in: .background) { (resolve, reject, _) in
            for i in 0...100 {
                let number = Int.random(in: 0..<200)
                if i != 0 {
                    username = currentUsername + String(number)
                }
                let (first, second) = try await(zip(self.findUsernameFromUsers(username: username), self.findUsernameFromBusinesses(username: username)))
                firstCheck = first
                secondCheck = second
                if !firstCheck && !secondCheck {
                    print("This is the main username \(username)")
                    resolve(username)
                    return
                }
            }
            resolve("undefined")
        }
    }
    
    func checkAvailability(username: String) -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            let (first, second) = try await(zip(self.findUsernameFromUsers(username: username), self.findUsernameFromBusinesses(username: username)))
            if !first && !second {
                resolve(false)
            } else {
                resolve(true)
            }
        }
    }
    
    func findUsernameFromUsers(username: String) -> Promise<Bool> {
        let userRef = db.collection("users")
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            userRef.whereField("username", isEqualTo: username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    resolve(false)
                } else {
                    if querySnapshot!.documents.count == 0 {
                        print("This username doesn't existed in users")
                        resolve(false)
                    } else {
                        resolve(true)
                    }
                }
            }
        }
    }
    
    func findUsernameFromBusinesses(username: String) -> Promise<Bool> {
        let businessRef = db.collection("businesses")
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            businessRef.whereField("username", isEqualTo: username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    resolve(true)
                } else {
                    if querySnapshot!.documents.count == 0 {
                        print("This username doesn't existed in businesses")
                        resolve(false)
                    } else {
                        resolve(true)
                    }
                }
            }
        }
    }
}
