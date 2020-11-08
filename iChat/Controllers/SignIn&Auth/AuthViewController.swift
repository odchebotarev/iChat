//
//  ViewController.swift
//  iChat
//
//  Created by Oleg Chebotarev on 15.10.2020.
//

import UIKit
import GoogleSignIn

class AuthViewController: UIViewController {
    
    let loadIndicatorView = UIActivityIndicatorView()
    
    let logoImageView = UIImageView(image: UIImage(named: "Logo"), contentMode: .scaleAspectFit)
    
    let googleLabel = UILabel(text: "Get started with")
    let googleButton = UIButton(title: "Google",
                                titleColor: .black,
                                backgroundColor: .white,
                                imageName: "googleLogo",
                                isShadow: true)

    let emailLabel = UILabel(text: "Or sign up with")
    let emailButton = UIButton(title: "Email",
                               titleColor: .white,
                               backgroundColor: .buttonDark)

    let alreadyOnBoardLabel = UILabel(text: "Already onboard?")
    let loginButton = UIButton(title: "Login",
                               titleColor: .buttonRed,
                               backgroundColor: .white,
                               isShadow: true)
    
    let signUpVC = SignUpViewController()
    let loginVC = LoginViewController()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupConstraints()
        
        emailButton.addTarget(self, action: #selector(emailButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleButtonTapped), for: .touchUpInside)
        
        signUpVC.delegate = self
        loginVC.delegate = self
        
        GIDSignIn.sharedInstance()?.delegate = self
        
    }
    
    @objc private func emailButtonTapped() {
        self.present(signUpVC, animated: true, completion: nil)
    }
    
    @objc private func loginButtonTapped() {
        self.present(loginVC, animated: true, completion: nil)
    }
    
    @objc private func googleButtonTapped() {
        loadIndicatorView.startAnimating()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
}

//MARK: - Setup constraints
private extension AuthViewController {
    
    func setupConstraints() {
        
        let googleView = ButtonFormView(label: googleLabel, button: googleButton)
        let emailView = ButtonFormView(label: emailLabel, button: emailButton)
        let loginView = ButtonFormView(label: alreadyOnBoardLabel, button: loginButton)
        
        let stackView = UIStackView(arrangedSubviews: [googleView, emailView, loginView], axis: .vertical, spacing: 40)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        loadIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logoImageView)
        view.addSubview(stackView)
        view.addSubview(loadIndicatorView)
        
        NSLayoutConstraint.activate([
            logoImageView.bottomAnchor.constraint(lessThanOrEqualTo: stackView.topAnchor, constant: -80),
            logoImageView.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor, constant: 160),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            loadIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }
    
}

extension AuthViewController: AuthNavigatingDelegate {
    
    func toLoginViewController() {
        present(loginVC, animated: true, completion: nil)
    }
    
    func toSignUpViewController() {
        present(signUpVC, animated: true, completion: nil)
    }
    
}

// MARK: - GIDSignInDelegate
extension AuthViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        AuthService.shared.googleLogin(user: user, error: error) { (result) in
            switch result {
            case .success(let user):
                FirestoreService.shared.getUserData(user: user) { (result) in
                    switch result {
                    case .success(let chatUser):
                        UIApplication.getTopViewController()?.showAlert(with: "Success", and: "You have been authorized.") {
                            let mainTabBarController = MainTabBarController(currentUser: chatUser)
                            mainTabBarController.modalPresentationStyle = .fullScreen
                            UIApplication.getTopViewController()?.present(mainTabBarController, animated: true, completion: nil)
                        }
                    case .failure(_):
                        UIApplication.getTopViewController()?.showAlert(with: "Success", and: "You have been registered.") {
                            UIApplication.getTopViewController()?.present(SetupProfileViewController(currentUser: user), animated: true, completion: nil)
                        }
                    }
                }
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
            self.loadIndicatorView.stopAnimating()
        }
    }
}
