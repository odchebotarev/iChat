//
//  PeopleSection.swift
//  iChat
//
//  Created by Oleg Chebotarev on 07.11.2020.
//


enum PeopleSection: Int, CaseIterable {
    case users
    
    func description(usersCount: Int) -> String {
        switch self {
        case .users:
            return usersCount == 1 ? "There is \(usersCount) person nearby" : "There are \(usersCount) people nearby"
        }
    }
}
