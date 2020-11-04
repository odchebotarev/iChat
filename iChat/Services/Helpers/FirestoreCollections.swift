//
//  FirestoreCollections.swift
//  iChat
//
//  Created by Oleg Chebotarev on 05.11.2020.
//

enum FirestoreCollection: String {
    case users
}

enum UserCollection: String {
    case activeChats
    case waitingChats
}

enum ChatCollection: String {
    case messages
}
