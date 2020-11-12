//
//  ChatsViewController.swift
//  iChat
//
//  Created by Oleg Chebotarev on 25.10.2020.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

class ChatViewController: MessagesViewController {
    
    private var messages = [ChatMessage]()
    private var messageListener: ListenerRegistration?
    
    private let user: ChatUser
    private let chat: Chat
    
    init(user: ChatUser, chat: Chat) {
        self.user = user
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
        
        title = chat.friendUserName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        messageListener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageInputBar()
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
        }
        
        messagesCollectionView.backgroundColor = .mainWhite
        
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messageListener = ListenerService.shared.messagesObserve(chat: chat, completion: { (result) in
            switch result {
            case .success(var message):
                if let url = message.downloadURL {
                    StorageService.shared.downloadImage(url: url) { [weak self] (result) in
                        switch result {
                        case .success(let image):
                            message.image = image
                            self?.insertNewMessage(message: message)
                        case .failure(let error):
                            self?.showAlert(with: "Error", and: error.localizedDescription)
                        }
                    }
                } else {
                    self.insertNewMessage(message: message)
                }
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        })
    }
    
    private func insertNewMessage(message: ChatMessage) {
        guard !messages.contains(message) else { return }
        messages.append(message)
        messages.sort()
        
        let isLatestMessage = messages.firstIndex(of: message) == messages.count - 1
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
        
        messagesCollectionView.reloadData()
        
        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    @objc private func cameraButtonTapped() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        
        present(picker, animated: true, completion: nil)
        
    }
    
    private func sendImage(image: UIImage) {
        
        StorageService.shared.uploadImageMessage(photo: image, to: chat) { (result) in
            switch result {
            case .success(let url):
                var message = ChatMessage(user: self.user, image: image)
                message.downloadURL = url
                FirestoreService.shared.sendMessage(chat: self.chat, message: message) { (result) in
                    switch result {
                    case .success:
                        self.messagesCollectionView.scrollToBottom()
                    case .failure(_):
                        self.showAlert(with: "Error", and: "Image was not sent")
                    }
                }
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
        
    }
    
}

// MARK: - ConfigureMessageInputBar
extension ChatViewController {
    
    func configureMessageInputBar() {
        
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.backgroundView.backgroundColor = .mainWhite
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.placeholderTextColor = .textViewGray
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 14, left: 30, bottom: 14, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 14, left: 36, bottom: 14, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor.textViewGray.cgColor
        messageInputBar.inputTextView.layer.borderWidth = 0.2
        messageInputBar.inputTextView.layer.cornerRadius = 18.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        
        messageInputBar.layer.shadowColor = UIColor.black.cgColor
        messageInputBar.layer.shadowRadius = 5
        messageInputBar.layer.shadowOpacity = 0.3
        messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        configureSendButton()
        configureCameraButton()
    }
    
    func configureSendButton() {
        
        messageInputBar.sendButton.setImage(UIImage(named: "Sent"), for: .normal)
        messageInputBar.sendButton.applyGradients(cornerRadius: 10)
        messageInputBar.setRightStackViewWidthConstant(to: 56, animated: false)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 6, right: 30)
        messageInputBar.sendButton.setSize(CGSize(width: 48, height: 48), animated: true)
        messageInputBar.middleContentViewPadding.right = -38
        
    }
    
    func configureCameraButton() {
        
        let cameraItem = InputBarButtonItem(type: .system)
        cameraItem.tintColor = .lightPink
        let cameraImage = UIImage(systemName: "camera")
        cameraItem.image = cameraImage
        
        cameraItem.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
        
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
        
    }
    
}

// MARK: - MessagesDataSource
extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return user
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.item]
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.item % 4 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                                      attributes: [
                                        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                                        NSAttributedString.Key.foregroundColor: UIColor.darkGray
                                      ])
        } else { return nil }
    }
    
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {
    
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return indexPath.item % 4 == 0 ? 30 : 0
    }
    
}

// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .lightPink
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .mainUserTextCell : .white
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    
    // func avatarSize
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubble
    }
    
}

// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = ChatMessage(user: user, content: text)
        FirestoreService.shared.sendMessage(chat: chat, message: message) { (result) in
            switch result {
            case .success:
                self.messagesCollectionView.scrollToBottom()
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
        inputBar.inputTextView.text = ""
    }
    
}

// MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension ChatViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        sendImage(image: image)
    }
    
}
