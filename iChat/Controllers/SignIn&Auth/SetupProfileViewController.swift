//
//  SetupProfileViewController.swift
//  iChat
//
//  Created by Oleg Chebotarev on 15.10.2020.
//

import UIKit
import FirebaseAuth
import SDWebImage

class SetupProfileViewController: UIViewController {
    
    let loadIndicatorView = UIActivityIndicatorView()
    
    let welcomeLabel = UILabel(text: "Set up profile!", font: .avenir26)
    
    let fullImageView = AddPhotoView()
    
    let fullNameLabel = UILabel(text: "Full name")
    let fullNameTextField = OneLineTextField(font: .avenir20)
    
    let aboutMeLabel = UILabel(text: "About me")
    let aboutMeTextField = OneLineTextField(font: .avenir20)
    
    let sexLabel = UILabel(text: "Sex")
    let sexSegmentedControl = UISegmentedControl(first: "Male", second: "Female")
    
    let goToChatsButton = UIButton(title: "Go to chats!", titleColor: .white, backgroundColor: .buttonDark, cornerRadius: 4)
    
    private let currentUser: User
    
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        
        if let userName = currentUser.displayName {
            fullNameTextField.text = userName
        }
        if let photoURL = currentUser.photoURL {
            fullImageView.circleImageView.sd_setImage(with: photoURL, completed: nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupConstraints()
        setupViews()
        
        goToChatsButton.addTarget(self, action: #selector(goToChatsButtonTapped), for: .touchUpInside)
        fullImageView.plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    @objc private func plusButtonTapped() {
        loadIndicatorView.startAnimating()
        let imagePickerController = UIImagePickerController()
        imagePickerController.modalPresentationStyle = .fullScreen
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }
    
    @objc private func goToChatsButtonTapped() {
        loadIndicatorView.startAnimating()
        FirestoreService.shared.saveProfileWith(id: currentUser.uid,
                                                email: currentUser.email!,
                                                userName: fullNameTextField.text,
                                                avatarImage: fullImageView.circleImageView.image,
                                                description: aboutMeTextField.text,
                                                sex: sexSegmentedControl.titleForSegment(at: sexSegmentedControl.selectedSegmentIndex)) { (result) in
            switch result {
            case .success(let chatUser):
                FirestoreService.shared.currentUser = chatUser
                self.showAlert(with: "Success", and: "Have a great chat!") {
                    let mainTabBarController = MainTabBarController(currentUser: chatUser)
                    mainTabBarController.modalPresentationStyle = .fullScreen
                    self.present(mainTabBarController, animated: true, completion: nil)
                }
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
            self.loadIndicatorView.stopAnimating()
        }
    }
    
}

//MARK: - Setup constraints
private extension SetupProfileViewController {
    
    func setupConstraints() {
        
        let fullNameStackView = UIStackView(arrangedSubviews: [fullNameLabel, fullNameTextField], axis: .vertical, spacing: 0)
        let aboutMeStackView = UIStackView(arrangedSubviews: [aboutMeLabel, aboutMeTextField], axis: .vertical, spacing: 0)
        let sexStackView = UIStackView(arrangedSubviews: [sexLabel, sexSegmentedControl], axis: .vertical, spacing: 12)
        
        NSLayoutConstraint.activate([
            goToChatsButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        
        let stackView = UIStackView(arrangedSubviews: [
            fullNameStackView,
            aboutMeStackView,
            sexStackView,
            goToChatsButton
        ], axis: .vertical, spacing: 40)
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        fullImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        goToChatsButton.translatesAutoresizingMaskIntoConstraints = false
        loadIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(welcomeLabel)
        view.addSubview(fullImageView)
        view.addSubview(stackView)
        view.addSubview(loadIndicatorView)
        
        NSLayoutConstraint.activate([
            welcomeLabel.bottomAnchor.constraint(lessThanOrEqualTo: fullImageView.topAnchor, constant: -30),
            welcomeLabel.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor, constant: 160),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            fullImageView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -40),
            fullImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            loadIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }
    
}

// MARK: - Setup views
private extension SetupProfileViewController {
    
    func setupViews() {
        fullNameTextField.autocapitalizationType = .none
        fullNameTextField.autocorrectionType = .no
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension SetupProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) {
            self.loadIndicatorView.stopAnimating()
        }
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        fullImageView.circleImageView.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.loadIndicatorView.stopAnimating()
        }
    }
    
}
