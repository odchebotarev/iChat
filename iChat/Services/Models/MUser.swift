//
//  MUser.swift
//  iChat
//
//  Created by Oleg Chebotarev on 18.10.2020.
//

import FirebaseFirestore
import MessageKit

struct MUser: Hashable, Decodable {
    var userName: String
    var email: String
    var avatarStringURL: String
    var description: String
    var sex: String
    var id: String
    
    init(userName: String,
         email: String,
         avatarStringURL: String,
         description: String,
         sex: String,
         id: String) {
        self.userName = userName
        self.email = email
        self.avatarStringURL = avatarStringURL
        self.description = description
        self.sex = sex
        self.id = id
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        guard let userName = data["userName"] as? String,
              let email = data["email"] as? String,
              let avatarStringURL = data["avatarStringURL"] as? String,
              let description = data["description"] as? String,
              let sex = data["sex"] as? String,
              let id = data["uid"] as? String
        else { return nil }
        
        self.userName = userName
        self.email = email
        self.avatarStringURL = avatarStringURL
        self.description = description
        self.sex = sex
        self.id = id
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let userName = data["userName"] as? String,
              let email = data["email"] as? String,
              let avatarStringURL = data["avatarStringURL"] as? String,
              let description = data["description"] as? String,
              let sex = data["sex"] as? String,
              let id = data["uid"] as? String
        else { return nil }
        
        self.userName = userName
        self.email = email
        self.avatarStringURL = avatarStringURL
        self.description = description
        self.sex = sex
        self.id = id
    }
    
    var representation: [String: Any] {
        var rep = [String : Any]()
        rep["userName"] = userName
        rep["sex"] = sex
        rep["email"] = email
        rep["avatarStringURL"] = avatarStringURL
        rep["description"] = description
        rep["uid"] = id
        return rep
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: MUser, rhs: MUser) -> Bool {
        return lhs.id == rhs.id
    }
    
    func contains(substring: String?) -> Bool {
        guard let substring = substring else { return true }
        
        if substring.isEmpty { return true }
        
        return userName.lowercased().contains(substring.lowercased())
    }
}

// MARK: - SenderType
extension MUser: SenderType {
    
    var senderId: String {
        return self.id
    }
    
    var displayName: String {
        return self.userName
    }
    
}
