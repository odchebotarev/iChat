//
//  Chat.swift
//  iChat
//
//  Created by Oleg Chebotarev on 18.10.2020.
//

import FirebaseFirestore

struct Chat: Hashable, Decodable {
    
    var friendUserName: String
    var friendAvatarStringURL: String
    var lastMessageContent: String
    var friendId: String
    
    var representation: [String : Any] {
        var representation = [String : Any]()
        representation["friendUserName"] = friendUserName
        representation["friendAvatarStringURL"] = friendAvatarStringURL
        representation["lastMessage"] = lastMessageContent
        representation["friendId"] = friendId
        
        return representation
    }
    
    init(friendUserName: String,
         friendAvatarStringURL: String,
         lastMessageContent: String,
         friendId: String) {
        self.friendUserName = friendUserName
        self.friendAvatarStringURL = friendAvatarStringURL
        self.lastMessageContent = lastMessageContent
        self.friendId = friendId
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let friendUserName = data["friendUserName"] as? String,
              let friendAvatarStringURL = data["friendAvatarStringURL"] as? String,
              let lastMessageContent = data["lastMessage"] as? String,
              let friendId = data["friendId"] as? String else { return nil }
        
        self.friendUserName = friendUserName
        self.friendAvatarStringURL = friendAvatarStringURL
        self.lastMessageContent = lastMessageContent
        self.friendId = friendId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(friendId)
    }
    
    static func ==(lhs: Chat, rhs: Chat) -> Bool {
        return lhs.friendId == rhs.friendId
    }
}
