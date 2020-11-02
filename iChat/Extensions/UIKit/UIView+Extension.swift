//
//  UIView+Extension.swift
//  iChat
//
//  Created by Oleg Chebotarev on 18.10.2020.
//

import UIKit

extension UIView {
    
    func applyGradients(cornerRadius: CGFloat) {
        
        self.backgroundColor = nil
        self.layoutIfNeeded()
        let gradientView = GradientView(from: .topTrailing, to: .bottomLeading, startColor: .lightPink, endColor: .lightBlue)
        guard let gradientLayer = gradientView.layer.sublayers?.first as? CAGradientLayer else { return }
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = cornerRadius
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
}
