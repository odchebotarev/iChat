//
//  WaitingChatCell.swift
//  iChat
//
//  Created by Oleg Chebotarev on 18.10.2020.
//

import UIKit

class WaitingChatCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseId: String = "WaitingChatCell"
    
    let friendImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemYellow
        
        setupConstraints()
        
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
    }
    
    func configure<U: Hashable>(with value: U) {
        guard let chat = value as? MChat else { return }
        friendImageView.sd_setImage(with: URL(string: chat.friendAvatarStringURL), completed: nil)
    }
    
    private func setupConstraints() {
        
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(friendImageView)
        
        NSLayoutConstraint.activate([
            friendImageView.topAnchor.constraint(equalTo: self.topAnchor),
            friendImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            friendImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            friendImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
