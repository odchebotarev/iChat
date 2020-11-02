//
//  OneLineTextField.swift
//  iChat
//
//  Created by Oleg Chebotarev on 15.10.2020.
//

import UIKit

class OneLineTextField: UITextField {
    
    convenience init(font: UIFont? = .avenir20) {
        self.init()
        
        self.font = font
        self.borderStyle = .none
        
        let bottomView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        bottomView.backgroundColor = .textFieldLight
        
        self.translatesAutoresizingMaskIntoConstraints = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(bottomView)
        
        NSLayoutConstraint.activate([
            bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
}
