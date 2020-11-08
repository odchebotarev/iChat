//
//  ConversationsViewController.swift
//  iChat
//
//  Created by Oleg Chebotarev on 16.10.2020.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ConversationsViewController: UIViewController {
    
    let name = "Conversations"
    private let currentUser: ChatUser
    
    var waitingChats = [Chat]()
    var activeChats = [Chat]()
    
    private var waitingChatsListener: ListenerRegistration?
    private var activeChatsListener: ListenerRegistration?
    
    var dataSource: UICollectionViewDiffableDataSource<ConversationsSection, Chat>?
    var collectionView: UICollectionView!
    
    init(currentUser: ChatUser) {
        self.currentUser = currentUser
        
        super.init(nibName: nil, bundle: nil)
        
        title = currentUser.userName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        waitingChatsListener?.remove()
        activeChatsListener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupCollectionView()
        createDataSource()
        reloadData()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(signOut))
        
        if UserDefaults.standard.object(forKey: "waitingChatsCount") as? Int == nil {
            UserDefaults.standard.set(0, forKey: "waitingChatsCount")
        }
        
        waitingChatsListener = ListenerService.shared.waitingChatsObserve(chats: waitingChats, completion: { (result) in
            switch result {
            case .success(let chats):
                let waitingChatsCount = UserDefaults.standard.object(forKey: "waitingChatsCount") as? Int ?? 0
                if waitingChatsCount < chats.count {
                    let chatRequestViewController = ChatRequestViewController(chat: chats.last!)
                    chatRequestViewController.delegate = self
                    self.present(chatRequestViewController, animated: true, completion: nil)
                }
                self.waitingChats = chats
                self.reloadData()
                UserDefaults.standard.set(chats.count, forKey: "waitingChatsCount")
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        })
        
        activeChatsListener = ListenerService.shared.activeChatsObserve(chats: activeChats, completion: { (result) in
            switch result {
            case .success(let chats):
                self.activeChats = chats
                self.reloadData()
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        })
    }
    
    @objc private func signOut() {
        let signOutAlertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
        signOutAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        signOutAlertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
//                UIApplication.shared.keyWindow?.rootViewController = AuthViewController()
                (UIApplication.shared.windows.first { $0.isKeyWindow })?.rootViewController = AuthViewController()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }))
        present(signOutAlertController, animated: true, completion: nil)
    }
    
    private func setupSearchBar() {
        navigationController?.navigationBar.barTintColor = .mainWhite
        navigationController?.navigationBar.shadowImage = UIImage()
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    private func setupCollectionView() {
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .mainWhite
        view.addSubview(collectionView)
        
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        
        collectionView.register(ActiveChatCell.self, forCellWithReuseIdentifier: ActiveChatCell.reuseId)
        collectionView.register(WaitingChatCell.self, forCellWithReuseIdentifier: WaitingChatCell.reuseId)
        
        collectionView.delegate = self
        
    }
    
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<ConversationsSection, Chat>()
        snapshot.appendSections([.waitingChats, .activeChats])
        snapshot.appendItems(waitingChats, toSection: .waitingChats)
        snapshot.appendItems(activeChats, toSection: .activeChats)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
}

// MARK: - Data source
private extension ConversationsViewController {
    
    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<ConversationsSection, Chat>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, chat) -> UICollectionViewCell? in
            guard let section = ConversationsSection(rawValue: indexPath.section) else {
                fatalError("Unknown section kind")
            }
            
            switch section {
            case .activeChats:
                return self.configure(collectionView: collectionView, cellType: ActiveChatCell.self, with: chat, for: indexPath)
            case .waitingChats:
                return self.configure(collectionView: collectionView, cellType: WaitingChatCell.self, with: chat, for: indexPath)
            }
        })
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else {
                fatalError("Can not create new section header")
            }
            
            guard let section = ConversationsSection(rawValue: indexPath.section) else {
                fatalError("Unknown section kind")
            }
            sectionHeader.configure(text: section.description(), font: .laoSangamMN20, textColor: .headerGray)
            
            return sectionHeader
        }
    }
    
}

// MARK: - Setup layout
private extension ConversationsViewController {
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let section = ConversationsSection(rawValue: sectionIndex) else {
                fatalError("Unknown section kind")
            }
            
            switch section {
            case .waitingChats:
                return self.createWaitingChats()
            case .activeChats:
                return self.createActiveChats()
            }
        }
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 20
        layout.configuration = configuration
        return layout
    }
    
    func createWaitingChats() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(88), heightDimension: .absolute(88))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
        section.orthogonalScrollingBehavior = .continuous
        
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    func createActiveChats() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(78))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
        
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        return sectionHeader
    }
    
}

// MARK: - UICollectionViewDelegate
extension ConversationsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let chat = self.dataSource?.itemIdentifier(for: indexPath) else { return }
        guard let section = ConversationsSection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .waitingChats:
            let chatRequestViewController = ChatRequestViewController(chat: chat)
            chatRequestViewController.delegate = self
            self.present(chatRequestViewController, animated: true, completion: nil)
        case .activeChats:
            let chatsViewController = ChatViewController(user: currentUser, chat: chat)
            navigationController?.pushViewController(chatsViewController, animated: true)
        }
    }
    
}
// MARK: - WaitingChatsNavigation
extension ConversationsViewController: WaitingChatsNavigation {
    
    func removeWaitingChat(chat: Chat) {
        FirestoreService.shared.delegateWaitingChat(chat: chat) { (result) in
            switch result {
            case .success:
                self.showAlert(with: "Success", and: "Chat with \(chat.friendUserName) has been deleted.")
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
    }
    
    func chatToActive(chat: Chat) {
        FirestoreService.shared.changeToActive(chat: chat) { (result) in
            switch result {
            case .success:
                self.showAlert(with: "Success", and: "Have a great talk with \(chat.friendUserName)!")
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
    }
    
}

// MARK: - UISearchBarDelegate
extension ConversationsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}
