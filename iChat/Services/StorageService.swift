//
//  StorageService.swift
//  iChat
//
//  Created by Oleg Chebotarev on 24.10.2020.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class StorageService {
    
    static let shared = StorageService()
    private init() {}
    
    private let storageReference = Storage.storage().reference()
    
    private var avatarsReference: StorageReference {
        return storageReference.child(StorageChild.avatars.rawValue)
    }
    
    private var chatsReference: StorageReference {
        return storageReference.child(StorageChild.chats.rawValue)
    }
    
    private var currentUserId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    private let contentType = "image/jpeg"
    
    func upload(photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        
        guard let currentUserId = currentUserId else {
            completion(.failure(UploadError.noCurrentUserId))
            return
        }
        
        guard let scaledImage = photo.scaledToSafeUploadSize,
              let imageData = scaledImage.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = self.contentType
        
        avatarsReference.child(currentUserId).putData(imageData, metadata: metadata) { (_, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let currentUserId = self.currentUserId else {
                completion(.failure(UploadError.noCurrentUserId))
                return
            }
            
            self.avatarsReference.child(currentUserId).downloadURL { (url, error) in
                guard let downloadURL = url else {
                    completion(.failure(error!))
                    return
                }
                
                completion(.success(downloadURL))
            }
        }
    }
    
    func uploadImageMessage(photo: UIImage, to chat: Chat, completion: @escaping (Result<URL, Error>) -> Void) {
        
        guard let scaledImage = photo.scaledToSafeUploadSize,
              let imageData = scaledImage.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = self.contentType
        
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        guard let uid: String = currentUserId else {
            completion(.failure(UploadError.noCurrentUserId))
            return
        }
        let chatName = [chat.friendUserName, uid].joined()
        self.chatsReference.child(chatName).child(imageName).putData(imageData, metadata: metadata) { (metadata, error) in
            guard metadata != nil else {
                completion(.failure(error!))
                return
            }
            
            self.chatsReference.child(chatName).child(imageName).downloadURL { (url, error) in
                guard let downloadURL = url else {
                    completion(.failure(error!))
                    return
                }
                
                completion(.success(downloadURL))
            }
        }
    }
    
    func downloadImage(url: URL, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        
        let reference = Storage.storage().reference(forURL: url.absoluteString)
        let megaByte = Int64(1 * 1024 * 1024)
        reference.getData(maxSize: megaByte) { (data, error) in
            guard let imageData = data else {
                completion(.failure(error!))
                return
            }
            
            completion(.success(UIImage(data: imageData)))
        }
    }
    
}
