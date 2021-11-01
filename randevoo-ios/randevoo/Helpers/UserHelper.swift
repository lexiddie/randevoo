//
//  UserHelper.swift
//  randevoo
//
//  Created by Xell on 7/3/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Hydra
import ObjectMapper

class UserHelper {
    
    let db = Firestore.firestore()
    
    
    func retrievePersonalAcc(id: String) -> Promise<PersonalAccount>{
        let prodList = db.collection("users")
        var personalAcc: PersonalAccount!
        return Promise<PersonalAccount>(in: .background) { (resolve, reject, _) in
            prodList.whereField("id", isEqualTo: id).getDocuments() { (querySnapshot, err) in
                if err != nil {
                    print("Fail to Personal ACC")
                    resolve(personalAcc)
                } else {
                    for document in querySnapshot!.documents {
                        let currentData = Mapper<PersonalAccount>().map(JSONObject: document.data())
                        personalAcc = currentData
                    }
                    resolve(personalAcc)
                }
            }
        }
    }
    
    func retrieveBusinessAcc(id: String) -> Promise<BusinessAccount>{
        let prodList = db.collection("businesses")
        var bizAcc: BusinessAccount!
        return Promise<BusinessAccount>(in: .background) { (resolve, reject, _) in
            prodList.whereField("id", isEqualTo: id).getDocuments() { (querySnapshot, err) in
                if err != nil {
                    print("Fail to Biz Acc")
                    resolve(bizAcc)
                } else {
                    for document in querySnapshot!.documents {
                        let currentData = Mapper<BusinessAccount>().map(JSONObject: document.data())
                        bizAcc = currentData
                    }
                    resolve(bizAcc)
                }
            }
        }
    }
}
