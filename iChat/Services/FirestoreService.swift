//
//  FirestoreService.swift
//  iChat
//
//  Created by Oleg Chebotarev on 22.10.2020.
//

import Firebase

class FirestoreService {
    
    static let shared = FirestoreService()
    private init() {}
    
    let db = Firestore.firestore()
    
    private var usersRef: CollectionReference {
        return db.collection("users")
    }
    
    private var waitingChatsRef: CollectionReference {
        return db.collection(["users", currentUser.id, "waitingChats"].joined(separator: "/"))
    }
    
    private var activeChatsRef: CollectionReference {
        return db.collection(["users", currentUser.id, "activeChats"].joined(separator: "/"))
    }
    
    var currentUser: MUser!
    
    func getUserData(user: User, completion: @escaping (Result<MUser, Error>) -> Void) {
        let docRef = usersRef.document(user.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let mUser = MUser(document: document) else {
                    completion(.failure(UserError.cannotUnwrapToMUser))
                    return
                }
                self.currentUser = mUser
                completion(.success(mUser))
            } else {
                completion(.failure(UserError.cannotGetUserInfo))
            }
        }
    }
    
    func saveProfileWith(id: String,
                         email: String,
                         userName: String?,
                         avatarImage: UIImage?,
                         description: String?,
                         sex: String?,
                         completion: @escaping (Result<MUser, Error>) -> Void) {
        
        guard Validator.isFilled(userName: userName, description: description, sex: sex) else {
            completion(.failure(UserError.notFilled))
            return
        }
        
        guard avatarImage != UIImage(named: "avatar") else {
            completion(.failure(UserError.photoNotExist))
            return
        }
        
        var mUser = MUser(userName: userName!,
                          email: email,
                          avatarStringURL: "not exist",
                          description: description!,
                          sex: sex!,
                          id: id)
        
        StorageService.shared.upload(photo: avatarImage!) { (result) in
            switch result {
            case .success(let url):
                mUser.avatarStringURL = url.absoluteString
                self.usersRef.document(mUser.id).setData(mUser.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(mUser))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createWaitingChat(message: String, receiver: MUser, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let reference = db.collection(["users", receiver.id, "waitingChats"].joined(separator: "/"))
        let messageReference = reference.document(self.currentUser.id).collection("messages")
        
        let message = MMessage(user: currentUser, content: message)
        let chat = MChat(friendUserName: currentUser.userName, friendAvatarStringURL: currentUser.avatarStringURL, lastMessageContent: message.content, friendId: currentUser.id)
        
        reference.document(currentUser.id).setData(chat.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            messageReference.addDocument(data: message.representation) { (error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(Void()))
            }
        }
    }
    
    func delegateWaitingChat(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        waitingChatsRef.document(chat.friendId).delete { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            self.deleteMessages(chat: chat, completion: completion)
        }
    }
    
    func deleteMessages(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")
        
        getWaitingChatMessages(chat: chat) { (result) in
            switch result {
            case .success(let messages):
                for message in messages {
                    guard let documentId = message.id else { return }
                    let messageReference = reference.document(documentId)
                    messageReference.delete { (error) in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        
                        completion(.success(()))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
    func getWaitingChatMessages(chat: MChat, completion: @escaping (Result<[MMessage], Error>) -> Void) {
        
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")
        var messages = [MMessage]()
        reference.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            for document in querySnapshot?.documents ?? [] {
                guard let message = MMessage(document: document) else { return }
                messages.append(message)
            }
            completion(.success(messages))
        }
    }
    
    func changeToActive(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        getWaitingChatMessages(chat: chat) { (result) in
            switch result {
            case .success(let messages):
                self.delegateWaitingChat(chat: chat) { (result) in
                    switch result {
                    case .success():
                        self.createActiveChat(chat: chat, messages: messages) { (result) in
                            switch result {
                            case .success:
                                completion(.success(()))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createActiveChat(chat: MChat, messages: [MMessage], completion: @escaping (Result<Void, Error>) -> Void) {
        
        let messageReference = activeChatsRef.document(chat.friendId).collection("messages")
        
        activeChatsRef.document(chat.friendId).setData(chat.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            for message in messages {
                messageReference.addDocument(data: message.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    completion(.success(()))
                }
            }
        }
        
    }
    
    func sendMessage(chat: MChat, message: MMessage, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let friendReference = usersRef.document(chat.friendId).collection("activeChats").document(currentUser.id)
        let friendMessageReference = friendReference.collection("messages")
        let myMessageReference = usersRef.document(currentUser.id).collection("activeChats").document(chat.friendId).collection("messages")
        
        let chatForFriend = MChat(friendUserName: currentUser.userName,
                                  friendAvatarStringURL: currentUser.avatarStringURL,
                                  lastMessageContent: message.content,
                                  friendId: currentUser.id)
        friendReference.setData(chatForFriend.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            friendMessageReference.addDocument(data: message.representation) { (error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                myMessageReference.addDocument(data: message.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                }
                
                completion(.success(()))
            }
        }
        
    }
    
}
