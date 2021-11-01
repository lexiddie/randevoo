//
//  AddToListHelper.swift
//  randevoo
//
//  Created by Xell on 10/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Hydra
import ObjectMapper

class AddToListHelper {
    
    let db = Firestore.firestore()
    
    func addProductToList(list: ListModel) -> Promise<Bool>{
        let prodList = db.collection("bags")
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            prodList.document(list.id).setData(list.toJSON()) { err in
                if err != nil {
                    resolve(false)
                    print("Faild to add product")
                } else {
                    resolve(true)
                    print("Add product to db successfully")
                }
                
            }
        }
    }
    
    func deleteProductFromList(ids: [String]) {
        for id in ids {
            db.collection("bags").document(id).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
  
    }
    
    func retrieveSpecificProduct(id: String, userId: String) -> Promise<[ListModel]>{
        let prodList = db.collection("bags")
        var lists: [ListModel] = []
        return Promise<[ListModel]>(in: .background) { (resolve, reject, _) in
            prodList.whereField("productId", isEqualTo: id).whereField("userId", isEqualTo: userId).getDocuments() { (querySnapshot, err) in
                if err != nil {
                    print("Fail to Retrieve User Product List")
                    resolve(lists)
                } else {
                    for document in querySnapshot!.documents {
                        let currentData = Mapper<ListModel>().map(JSONObject: document.data())
                        lists.append(currentData!)
                    }
                    resolve(lists)
                }
            }
        }
    }
    
    func retrieveListOfProduct(userId: String, productId: String, size: String, color: String) -> Promise<[ListModel]>{
        let prodList = db.collection("bags")
        var lists: [ListModel] = []
        return Promise<[ListModel]>(in: .background) { (resolve, reject, _) in
            prodList.whereField("productId", isEqualTo: productId).whereField("userId", isEqualTo: userId).whereField("color", isEqualTo: color).whereField("size", isEqualTo: size).getDocuments() { (querySnapshot, err) in
                if err != nil {
                    print("Fail to Retrieve User Product List")
                    resolve(lists)
                } else {
                    for document in querySnapshot!.documents {
                        let currentData = Mapper<ListModel>().map(JSONObject: document.data())
                        lists.append(currentData!)
                    }
                    resolve(lists)
                }
            }
        }
    }
    

}
