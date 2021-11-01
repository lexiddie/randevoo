//
//  AccountsProvider.swift
//  randevoo
//
//  Created by Lex on 10/01/2021.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Hydra
import ObjectMapper
import SwiftyJSON

class AccountsProvider {
    
    private let db = Firestore.firestore()
    
    func findBusinessAccounts(userId: String) -> Promise<[Account]> {
        let businessRef = db.collection("businesses")
        return Promise<[Account]>(in: .background) { (resolve, reject, _) in
            businessRef.whereField("userId", isEqualTo: userId)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    reject(err)
                } else {
                    guard let documents = querySnapshot?.documents else {
                        resolve([])
                        return
                    }
                    var tempList: [Account] = []
                    for document in documents {
                        let businessAccount = Mapper<BusinessAccount>().map(JSONObject: document.data())!
                        let current = Account(id: businessAccount.id, username: businessAccount.username, profileUrl: businessAccount.profileUrl, isPersonal: false)
                        tempList.append(current)
//                        let businessesJson = Mapper().toJSONString(businessAccount, prettyPrint: true)!
//                        print("Print Json Business: \(businessesJson)")
                    }
                    resolve(tempList)
                }
            }
        }
    }
    
    func fetchBizAccountIntoCache(businessId: String) -> Promise<Bool> {
        let businessRef = db.collection("businesses")
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            businessRef.document(businessId).getDocument { (document, error) in
                if let document = document, document.exists {
                    let record = Mapper<BusinessAccount>().map(JSONObject: document.data())!
                    businessAccount = record
                    FCache.set(record, key: "business")
                    print("Added Business Account Into Cache In Switch Account")
                    resolve(true)
                } else {
                    print("Document does not exist")
                    resolve(false)
                }
            }
        }
    }
}

