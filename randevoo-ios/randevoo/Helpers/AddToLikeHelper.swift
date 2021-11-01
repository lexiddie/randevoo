//
//  AddToLikeHelper.swift
//  randevoo
//
//  Created by Xell on 18/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import Foundation
import FirebaseFirestore
import ObjectMapper

class AddToLikeHelper {
    
    let db = Firestore.firestore()
    
    func saveLikeToDb(like: Save){
        let likeCollection = self.db.collection("saves")
        likeCollection.document(like.id).setData(like.toJSON()) { err in
            if err != nil {
                print("Faild to add to Saves")
            } else {
                print("Successfully add to Saves")
            }
        }
    }
    
    func removeLikeFromDb(id: String) {
        db.collection("saves").document(id).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }

}

