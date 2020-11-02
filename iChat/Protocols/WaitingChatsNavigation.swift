//
//  WaitingChatsNavigation.swift
//  iChat
//
//  Created by Oleg Chebotarev on 24.10.2020.
//

protocol WaitingChatsNavigation: class {
    func removeWaitingChat(chat: MChat)
    func chatToActive(chat: MChat)
}
