//
//  UIImageView+Extension.swift
//  iChat
//
//  Created by Oleg Chebotarev on 15.10.2020.
//

import UIKit

extension UIImageView {
    
    convenience init(image: UIImage? = nil, contentMode: UIView.ContentMode) {
        self.init()
        
        self.image = image
        self.contentMode = contentMode
    }
    
    func setupColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
    
}
