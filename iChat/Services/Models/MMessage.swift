//
//  MMessage.swift
//  iChat
//
//  Created by Oleg Chebotarev on 24.10.2020.
//

import UIKit
import FirebaseFirestore
import MessageKit

struct ImageItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct MMessage: Hashable, MessageType {
    
    let content: String
    var sender: SenderType
    var sentDate: Date
    let id: String?
    
    var messageId: String {
        return id ?? UUID().uuidString
    }
    
    var kind: MessageKind {
        if let image = image {
            let mediaItem = ImageItem(url: nil, image: nil, placeholderImage: image, size: image.size)
            return .photo(mediaItem)
        } else {
            return .text(content)
        }
    }
    
    var image: UIImage? = nil
    var downloadURL: URL? = nil
    
    init(user: MUser, content: String) {
        self.content = content
//        self.sender = Sender(senderId: user.id, displayName: user.userName)
        self.sender = user
        self.sentDate = Date()
        self.id = nil
    }
    
    init(user: MUser, image: UIImage) {
//        self.sender = Sender(senderId: user.id, displayName: user.userName)
        self.sender = user
        self.image = image
        self.content = ""
        self.sentDate = Date()
        self.id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let sentData = data["created"] as? Timestamp,
              let senderId = data["senderID"] as? String,
              let senderName = data["senderName"] as? String else { return nil }
        
        self.id = document.documentID
        self.sentDate = sentData.dateValue()
        self.sender = Sender(senderId: senderId, displayName: senderName)
        
        if let content = data["content"] as? String {
            self.content = content
            downloadURL = nil
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            downloadURL = url
            self.content = ""
        } else {
            return nil
        }
    }
    
    var representation: [String : Any] {
        var representation: [String : Any] = [
            "created": sentDate,
            "senderID": sender.senderId,
            "senderName": sender.displayName
        ]
        
        if let url = downloadURL {
            representation["url"] = url.absoluteString
        } else {
            representation["content"] = content
        }
        return representation
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(messageId)
    }
    
    static func == (lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.messageId == rhs.messageId
    }
    
}

extension MMessage: Comparable {
    
    static func < (lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
}
