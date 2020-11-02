//
//  Validators.swift
//  iChat
//
//  Created by Oleg Chebotarev on 21.10.2020.
//

import Foundation

class Validator {
    
    static func isFilled(email: String?, password: String?, confirmPassword: String?) -> Bool {
        guard let password = password,
              password != "",
              let confirmPassword = confirmPassword,
              confirmPassword != "",
              let email = email,
              email != "" else { return false }
        
        return true
    }
    
    static func isFilled(userName: String?, description: String?, sex: String?) -> Bool {
        guard let description = description,
              let sex = sex,
              let userName = userName,
              description != "",
              sex != "",
              userName != "" else { return false }
        
        return true
    }
    
    static func isSimpleMail(_ email: String) -> Bool {
        let emailRegex = "^.+@.+\\..{2,}$"
        return check(text: email, regEx: emailRegex)
    }
    
    private static func check(text: String, regEx: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regEx)
        return predicate.evaluate(with: text)
    }
    
}
