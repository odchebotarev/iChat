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
        return db.collection(FirestoreCollection.users.rawValue)
    }
    
    private var waitingChatsRef: CollectionReference {
        return db.collection([
            FirestoreCollection.users.rawValue,
            currentUser.id,
            UserCollection.waitingChats.rawValue
        ].joined(separator: "/"))
    }
    
    private var activeChatsRef: CollectionReference {
        return db.collection([
            FirestoreCollection.users.rawValue,
            currentUser.id,
            UserCollection.activeChats.rawValue
        ].joined(separator: "/"))
    }
    
    var currentUser: ChatUser!
    
    func getUserData(user: User, completion: @escaping (Result<ChatUser, Error>) -> Void) {
        let docRef = usersRef.document(user.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let chatUser = ChatUser(document: document) else {
                    completion(.failure(UserError.cannotUnwrapToChatUser))
                    return
                }
                self.currentUser = chatUser
                completion(.success(chatUser))
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
                         completion: @escaping (Result<ChatUser, Error>) -> Void) {
        
        guard Validator.isFilled(userName: userName, description: description, sex: sex) else {
            completion(.failure(UserError.notFilled))
            return
        }
        
        guard avatarImage != UIImage(named: "avatar") else {
            completion(.failure(UserError.photoNotExist))
            return
        }
        
        var chatUser = ChatUser(userName: userName!,
                          email: email,
                          avatarStringURL: "not exist",
                          description: description!,
                          sex: sex!,
                          id: id)
        
        StorageService.shared.upload(photo: avatarImage!) { (result) in
            switch result {
            case .success(let url):
                chatUser.avatarStringURL = url.absoluteString
                self.usersRef.document(chatUser.id).setData(chatUser.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(chatUser))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createWaitingChat(message: String, receiver: ChatUser, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let reference = db.collection([
            FirestoreCollection.users.rawValue,
            receiver.id,
            UserCollection.waitingChats.rawValue
        ].joined(separator: "/"))
        let messageReference = reference.document(self.currentUser.id).collection(ChatCollection.messages.rawValue)
        
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
        
        let reference = waitingChatsRef.document(chat.friendId).collection(ChatCollection.messages.rawValue)
        
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
        
        let reference = waitingChatsRef.document(chat.friendId).collection(ChatCollection.messages.rawValue)
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
        
        let messageReference = activeChatsRef.document(chat.friendId).collection(ChatCollection.messages.rawValue)
        
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
        
        let friendReference = usersRef.document(chat.friendId).collection(UserCollection.activeChats.rawValue).document(currentUser.id)
        let friendMessageReference = friendReference.collection(ChatCollection.messages.rawValue)
        let myMessageReference = usersRef.document(currentUser.id).collection(UserCollection.activeChats.rawValue).document(chat.friendId).collection(ChatCollection.messages.rawValue)
        
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
