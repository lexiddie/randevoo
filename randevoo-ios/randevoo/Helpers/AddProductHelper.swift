//
//  AddProductHelper.swift
//  randevoo
//
//  Created by Xell on 2/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage
import Hydra

class AddProductHelper {
    
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
    func uploadPhotos(photos: [UIImage]) -> Promise<[String]> {
        var photoUrls: [String] = []
        return Promise<[String]>(in: .background) { (resolve, reject, _) in
            for imageView in photos {
                let compressData = imageView.jpegData(compressionQuality: 0.3)
                let imageData = compressData!
                let filename = NSUUID().uuidString
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                let storagePhotoName = self.storage.child("product_images").child(filename)
                storagePhotoName.putData(imageData, metadata: nil, completion: { metadata, error in
                    if (metadata != nil) {
                        print("successfully upload images")
                        storagePhotoName.downloadURL(completion: { downloadURL, error in
                            guard let url = downloadURL else {
                                print("failed to get download URL")
                                return
                            }
                            let urlString = url.absoluteString
                            if !photoUrls.contains(urlString) {
                                photoUrls.append(urlString)
                            }
                            if photos.count == photoUrls.count {
                                resolve(photoUrls)
                            }
                            
                        })
                    } else {
                        print("failed to upload image")
                        resolve(photoUrls)
                    }
                })
            }
        }
    }
    
    func saveProductToDb(products: Product) -> Promise<Bool>{
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            let product = self.db.collection("products")
            let genID = product.document().documentID
            products.id = genID
            product.document(genID).setData(products.toJSON()) { err in
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
    
}


