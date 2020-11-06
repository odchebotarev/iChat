//
//  UploadError.swift
//  iChat
//
//  Created by Oleg Chebotarev on 05.11.2020.
//

import Foundation

enum UploadError {
    case noCurrentUserId
}

extension UploadError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .noCurrentUserId:
            return NSLocalizedString("Can not get current user id", comment: "")
        }
    }
}
