//
//  UILabel+Extension.swift
//  iChat
//
//  Created by Oleg Chebotarev on 15.10.2020.
//

import UIKit

extension UILabel {
    
    convenience init(text: String? = nil, font: UIFont? = .avenir20) {
        self.init()
        
        self.text = text
        self.font = font
    }
}
