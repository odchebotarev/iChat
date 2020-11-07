//
//  LoginViewController.swift
//  iChat
//
//  Created by Oleg Chebotarev on 15.10.2020.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    let loadIndicatorView = UIActivityIndicatorView()
    
    let welcomeLabel = UILabel(text: "Welcome back!", font: .avenir26)
    
    let loginWithLabel = UILabel(text: "Login with")
    let googleButton = UIButton(title: "Google", titleColor: .black, backgroundColor: .white, imageName: "googleLogo", isShadow: true)

    let orLabel = UILabel(text: "or")
    
    let emailLabel = UILabel(text: "Email")
    let emailTextField = OneLineTextField(font: .avenir20)

    let passwordLabel = UILabel(text: "Password")
    let passwordTextField = OneLineTextField(font: .avenir20)

    let loginButton = UIButton(title: "Login", titleColor: .white, backgroundColor: .buttonDark)
        
    let needAnAccountLabel = UILabel(text: "Need an account?")
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.buttonRed, for: .normal)
        button.titleLabel?.font = .avenir20
        button.contentHorizontalAlignment = .leading
        return button
    }()
    
    weak var delegate: AuthNavigatingDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupConstraints()
        setupViews()
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleButtonTapped), for: .touchUpInside)
        
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    @objc private func loginButtonTapped() {
        loadIndicatorView.startAnimating()
        AuthService.shared.login(email: emailTextField.text, password: passwordTextField.text) { (result) in
            switch result {
            case .success(let user):
                self.showAlert(with: "Success", and: "You have been authorized.") {
                    FirestoreService.shared.getUserData(user: user) { (result) in
                        switch result {
                        case .success(let chatUser):
                            let mainTabBarController = MainTabBarController(currentUser: chatUser)
                            mainTabBarController.modalPresentationStyle = .fullScreen
                            self.present(mainTabBarController, animated: true, completion: nil)
                        case .failure(_):
                            self.present(SetupProfileViewController(currentUser: user), animated: true, completion: nil)
                        }
                    }
                }
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
            self.loadIndicatorView.stopAnimating()
        }
    }
    
    @objc private func signUpButtonTapped() {
        dismiss(animated: true) {
            self.delegate?.toSignUpViewController()
        }
    }
    
    @objc private func googleButtonTapped() {
        loadIndicatorView.startAnimating()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
}

//MARK: - Setup constraints
private extension LoginViewController {
    func setupConstraints() {
        
        let loginWithView = ButtonFormView(label: loginWithLabel, button: googleButton)
        let emailStackView = UIStackView(arrangedSubviews: [emailLabel, emailTextField], axis: .vertical, spacing: 0)
        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel, passwordTextField], axis: .vertical, spacing: 0)
        
        NSLayoutConstraint.activate([
            loginButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        let stackView = UIStackView(arrangedSubviews: [
            loginWithView,
            orLabel,
            emailStackView,
            passwordStackView,
            loginButton
        ], axis: .vertical, spacing: 40)
        
        signUpButton.contentHorizontalAlignment = .leading
        let bottomStackView = UIStackView(arrangedSubviews: [needAnAccountLabel, signUpButton], axis: .horizontal, spacing: 10)
        bottomStackView.alignment = .firstBaseline
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        loadIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(welcomeLabel)
        view.addSubview(stackView)
        view.addSubview(bottomStackView)
        view.addSubview(loadIndicatorView)
                
        NSLayoutConstraint.activate([
            welcomeLabel.bottomAnchor.constraint(lessThanOrEqualTo: stackView.topAnchor, constant: -30),
            welcomeLabel.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor, constant: 160),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: bottomStackView.topAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: bottomStackView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: bottomStackView.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            bottomStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            loadIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }
}

// MARK: - Setup views
private extension LoginViewController {
    
    func setupViews() {
        passwordTextField.isSecureTextEntry = true
    }
    
}

// MARK: - GIDSignInDelegate
extension LoginViewController: GIDSignInDelegate {
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
