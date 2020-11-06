//
//  ActiveChatCell.swift
//  iChat
//
//  Created by Oleg Chebotarev on 18.10.2020.
//

import UIKit

class ActiveChatCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseId = "ActiveChatCell"
    
    let friendImageView = UIImageView()
    let friendName = UILabel(text: "User name", font: .laoSangamMN20)
    let lastMessage = UILabel(text: "How are you?", font: .laoSangamMN18)
    let gradientView = GradientView(from: .topTrailing, to: .bottomLeading, startColor: .lightPink, endColor: .lightBlue)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        setupConstraints()
        
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure<U: Hashable>(with value: U) {
        guard let chat = value as? Chat else { return }
        friendImageView.sd_setImage(with: URL(string: chat.friendAvatarStringURL), completed: nil)
        friendName.text = chat.friendUserName
        lastMessage.text = chat.lastMessageContent
    }
    
}

//MARK: - Setup constraints
private extension ActiveChatCell {
    
    func setupConstraints() {
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        friendName.translatesAutoresizingMaskIntoConstraints = false
        lastMessage.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        friendImageView.backgroundColor = .systemBlue
        gradientView.backgroundColor = .black
        
        addSubview(friendImageView)
        addSubview(friendName)
        addSubview(lastMessage)
        addSubview(gradientView)
        
        NSLayoutConstraint.activate([
            friendImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            friendImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            friendImageView.heightAnchor.constraint(equalToConstant: 78),
            friendImageView.widthAnchor.constraint(equalToConstant: 78)
        ])
        
        NSLayoutConstraint.activate([
            friendName.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            friendName.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16),
            friendName.trailingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            lastMessage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -14),
            lastMessage.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16),
            lastMessage.trailingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            gradientView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            gradientView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            gradientView.widthAnchor.constraint(equalToConstant: 8),
            gradientView.heightAnchor.constraint(equalToConstant: 78)
        ])
    }
    
}
