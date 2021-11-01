//
//  DatabaseManager.swift
//  randevoo
//
//  Created by Xell on 6/12/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import ObjectMapper

final class DatabaseManager {
    
    private let defaults = UserDefaults.standard
    private let db = Firestore.firestore()
    
    public typealias UploadPictureCompletion = (Result<String,Error>) -> Void
    
    func createNewMessage(with otherUserEmail: String, message: Message, completion: @escaping (Bool) -> Void) {
        let chatRef = db.collection("chats")
        var msg = ""
        switch  message.kind {
        case .text(let messageText):
            msg = messageText
        case .attributedText(_):
            break
        case .photo(let mediaItem):
            msg = mediaItem.url!.absoluteString
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
        let sendDate = message.sentDate.iso8601withFractionalSeconds
        let chat = Chat(id: message.messageId, type: message.kind.messageKindString, content: msg, createdAt: sendDate, senderId: message.sender.senderId, receiverId: otherUserEmail, isRead: false, isNotify: false)
        chatRef.document(message.messageId).setData(chat.toJSON()) { err in
            if let err = err {
                print("Error: \(err)")
                completion(false)
            } else {
                print("Success")
                completion(true)
            }
        }
    }
    
    func updateIsRead(id: String) {
        let chatRef = db.collection("chats")
        chatRef.document((id)).updateData(["isRead": true]) { err in
            if let err = err {
                print("Update isRead Error: \(err)")
            } else {
                print("Update isRead Complete")
            }
        }
    }
    
    func updateIsNotify(id: String) {
        let chatRef = db.collection("chats")
        chatRef.document((id)).updateData(["isNotify": true]) { err in
            if let err = err {
                print("Update isRead Error: \(err)")
            } else {
                print("Update isRead Complete")
            }
        }
    }
    
    func uploadPhotoToStorage(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let filename = NSUUID().uuidString
        let storage = Storage.storage().reference().child("message_images").child(filename)
        storage.putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else{
                print("failed to upload image")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            storage.downloadURL(completion: { downloadUrl, error in
                guard let url = downloadUrl else {
                    print("failed to get download URL")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("download url return: \(urlString)")
                completion(.success(urlString ))
            })
        })
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = Storage.storage().reference().child(path)
        reference.downloadURL(completion: {url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        })
    }
}
