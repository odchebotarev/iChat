//
//  UserError.swift
//  iChat
//
//  Created by Oleg Chebotarev on 22.10.2020.
//

import Foundation

enum UserError {
    case notFilled
    case photoNotExist
    case cannotGetUserInfo
    case cannotUnwrapToChatUser
}

extension UserError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .notFilled:
            return NSLocalizedString("Please fill all fields", comment: "")
        case .photoNotExist:
            return NSLocalizedString("Please set your photo", comment: "")
        case .cannotGetUserInfo:
            return NSLocalizedString("Can not get user info from Firebase", comment: "")
        case .cannotUnwrapToChatUser:
            return NSLocalizedString("Can not convert to user structure", comment: "")
        }
    }
    
}
