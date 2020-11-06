//
//  ChatRequestViewController.swift
//  iChat
//
//  Created by Oleg Chebotarev on 19.10.2020.
//

import UIKit

class ChatRequestViewController: UIViewController {
    
    let containerView = UIView()
    let imageView = UIImageView(contentMode: .scaleAspectFill)
    let nameLabel = UILabel(font: .systemFont(ofSize: 20, weight: .light))
    let aboutMeLabel = UILabel(font: .systemFont(ofSize: 16, weight: .light))
    let acceptButton = UIButton(title: "ACCEPT", titleColor: .white, backgroundColor: .black, font: .laoSangamMN20, isShadow: false, cornerRadius: 10)
    let denyButton = UIButton(title: "DENY", titleColor: .denyRed, backgroundColor: .mainWhite, font: .laoSangamMN20, isShadow: false, cornerRadius: 10)
    
    weak var delegate: WaitingChatsNavigation?
    
    private var chat: Chat
    
    init(chat: Chat) {
        self.chat = chat
        nameLabel.text = chat.friendUserName
        imageView.sd_setImage(with: URL(string: chat.friendAvatarStringURL), completed: nil)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .mainWhite
        
        customizeElements()
        setupConstraints()
        denyButton.addTarget(self, action: #selector(denyButtonTapped), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
    }
    
    @objc private func denyButtonTapped() {
        self.dismiss(animated: true) {
            self.delegate?.removeWaitingChat(chat: self.chat)
        }
    }
    
    @objc private func acceptButtonTapped() {
        self.dismiss(animated: true) {
            self.delegate?.chatToActive(chat: self.chat)
        }
    }
    
    private func customizeElements() {
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutMeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        denyButton.layer.borderWidth = 1.2
        denyButton.layer.borderColor = UIColor.denyRed.cgColor
        
        containerView.backgroundColor = .mainWhite
        containerView.layer.cornerRadius = 30
                
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        acceptButton.applyGradients(cornerRadius: 10)
    }
    
}

private extension ChatRequestViewController {
    
    func setupConstraints() {
        
        view.addSubview(imageView)
        view.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(aboutMeLabel)
        
        let buttonsStackView = UIStackView(arrangedSubviews: [acceptButton, denyButton], axis: .horizontal, spacing: 7)
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.distribution = .fillEqually
        containerView.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: 30)
        ])
        
        NSLayoutConstraint.activate([
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 206)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 35),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24)
        ])
        
        NSLayoutConstraint.activate([
            aboutMeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            aboutMeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            aboutMeLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            buttonsStackView.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 24),
            buttonsStackView.leadingAnchor.constraint(equalTo: aboutMeLabel.leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: aboutMeLabel.trailingAnchor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 56)
        ])
        
    }
    
}
