//
//  UIStackView+Extension.swift
//  iChat
//
//  Created by Oleg Chebotarev on 15.10.2020.
//

import UIKit

extension UIStackView {
    
    convenience init(arrangedSubviews: [UIView], axis: NSLayoutConstraint.Axis, spacing: CGFloat) {
        self.init(arrangedSubviews: arrangedSubviews)
        
        self.axis = axis
        self.spacing = spacing
    }
    
}
