//
//  ConversationsSection.swift
//  iChat
//
//  Created by Oleg Chebotarev on 07.11.2020.
//


enum ConversationsSection: Int, CaseIterable {
    case waitingChats, activeChats
    
    func description() -> String {
        switch self {
        case .waitingChats:
            return "Waiting chats"
        case .activeChats:
            return "Active chats"
        }
    }
}
