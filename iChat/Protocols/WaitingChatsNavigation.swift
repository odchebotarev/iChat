//
//  WaitingChatsNavigation.swift
//  iChat
//
//  Created by Oleg Chebotarev on 24.10.2020.
//

protocol WaitingChatsNavigation: class {
    func removeWaitingChat(chat: Chat)
    func chatToActive(chat: Chat)
}
