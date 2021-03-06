//
//  MainTabBarController.swift
//  iChat
//
//  Created by Oleg Chebotarev on 16.10.2020.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    private let currentUser: ChatUser
    
    init(currentUser: ChatUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = .violet
        
        let conversationsViewController = ConversationsViewController(currentUser: currentUser)
        let peopleViewController = PeopleViewController(currentUser: currentUser)
        
        let boldConfig = UIImage.SymbolConfiguration(weight: .medium)
        let conversationImage = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: boldConfig)
        let peopleImage = UIImage(systemName: "person.2", withConfiguration: boldConfig)
        
        viewControllers = [
            generateNavigationController(rootViewController: peopleViewController, title: peopleViewController.name, image: peopleImage),
            generateNavigationController(rootViewController: conversationsViewController, title: conversationsViewController.name, image: conversationImage)
        ]
    }
    
    private func generateNavigationController(rootViewController: UIViewController, title: String, image: UIImage?) -> UIViewController {
        let navigationViewController = UINavigationController(rootViewController: rootViewController)
        navigationViewController.tabBarItem.title = title
        navigationViewController.tabBarItem.image = image
        return navigationViewController
    }
    
}
