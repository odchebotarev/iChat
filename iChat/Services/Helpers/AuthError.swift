//
//  AuthError.swift
//  iChat
//
//  Created by Oleg Chebotarev on 21.10.2020.
//

import Foundation

enum AuthError {
    case notFilled
    case invalidEmail
    case passwordsNotMatched
    case unknownError
    case serverError
}

extension AuthError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .notFilled:
            return NSLocalizedString("Please fill all fields", comment: "")
        case .invalidEmail:
            return NSLocalizedString("Email format is invalid", comment: "")
        case .passwordsNotMatched:
            return NSLocalizedString("Passwords are not matched", comment: "")
        case .unknownError:
            return NSLocalizedString("Unknown error", comment: "")
        case .serverError:
            return NSLocalizedString("Server error", comment: "")
        }
    }
    
}
