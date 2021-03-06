//
//  ListenerService.swift
//  iChat
//
//  Created by Oleg Chebotarev on 24.10.2020.
//

import FirebaseAuth
import FirebaseFirestore

class ListenerService {
    
    static let shared = ListenerService()
    private init() {}
    
    private let db = Firestore.firestore()
    
    private var usersReference: CollectionReference {
        return db.collection(FirestoreCollection.users.rawValue)
    }
    
    private var currentUserId: String {
        return Auth.auth().currentUser!.uid
    }
    
    func usersObserve(users: [ChatUser], completion: @escaping (Result<[ChatUser], Error>) -> Void) -> ListenerRegistration {
        var users = users
        let usersListener = usersReference.addSnapshotListener { (querySnapshot, error) in
            guard error == nil, let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { (diff) in
                guard let chatUser = ChatUser(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    guard !users.contains(chatUser) else { return }
                    guard chatUser.id != self.currentUserId else { return }
                    users.append(chatUser)
                case .modified:
                    guard let index = users.firstIndex(of: chatUser) else { return }
                    users[index] = chatUser
                case .removed:
                    guard let index = users.firstIndex(of: chatUser) else { return }
                    users.remove(at: index)
                }
            }
            completion(.success(users))
        }
        
        return usersListener
    }
    
    func waitingChatsObserve(chats: [Chat], completion: @escaping (Result<[Chat], Error>) -> Void) -> ListenerRegistration {
        
        var chats = chats
        let chatsReference = db.collection([
            FirestoreCollection.users.rawValue,
            currentUserId,
            UserCollection.waitingChats.rawValue
        ].joined(separator: "/"))
        let chatsListener = chatsReference.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { (diff) in
                guard let chat = Chat(document: diff.document) else { return }
                
                switch diff.type {
                case .added:
                    guard !chats.contains(chat) else { return }
                    chats.append(chat)
                case .modified:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats[index] = chat
                case .removed:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats.remove(at: index)
                }
            }
            
            completion(.success(chats))
        }
        
        return chatsListener
    }
    
    func activeChatsObserve(chats: [Chat], completion: @escaping (Result<[Chat], Error>) -> Void) -> ListenerRegistration {
        
        var chats = chats
        let chatsReference = db.collection([FirestoreCollection.users.rawValue, currentUserId, UserCollection.activeChats.rawValue].joined(separator: "/"))
        let chatsListener = chatsReference.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { (diff) in
                guard let chat = Chat(document: diff.document) else { return }
                
                switch diff.type {
                case .added:
                    guard !chats.contains(chat) else { return }
                    chats.append(chat)
                case .modified:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats[index] = chat
                case .removed:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats.remove(at: index)
                }
            }
            
            completion(.success(chats))
        }
        
        return chatsListener
    }
    
    func messagesObserve(chat: Chat, completion: @escaping (Result<ChatMessage, Error>) -> Void) -> ListenerRegistration? {
        
        let reference = usersReference
            .document(currentUserId)
            .collection(UserCollection.activeChats.rawValue)
            .document(chat.friendId)
            .collection(ChatCollection.messages.rawValue)
        let messagesListener = reference.addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { (diff) in
                guard let message = ChatMessage(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    completion(.success(message))
                case .modified:
                    break
                case .removed:
                    break
                }
            }
            
        }
        
        return messagesListener
    }
    
}
