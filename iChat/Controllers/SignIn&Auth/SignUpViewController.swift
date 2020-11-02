//
//  SignUpViewController.swift
//  iChat
//
//  Created by Oleg Chebotarev on 15.10.2020.
//

import UIKit

class SignUpViewController: UIViewController {
    
    let welcomeLabel = UILabel(text: "Good to see you!", font: .avenir26)
    
    let emailLabel = UILabel(text: "Email")
    let emailTextField = OneLineTextField(font: .avenir20)
    
    let passwordLabel = UILabel(text: "Password")
    let passwordTextField = OneLineTextField(font: .avenir20)
    
    let confirmPasswordLabel = UILabel(text: "Confirm password")
    let confirmPasswordTextField = OneLineTextField(font: .avenir20)
    
    let signUpButton = UIButton(title: "Sign Up", titleColor: .white, backgroundColor: .buttonDark, cornerRadius: 4)
    
    let alreadyOnBoardLabel = UILabel(text: "Already onboard?")
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
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
        
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    @objc private func signUpButtonTapped() {
        print(#function)
        AuthService.shared.register(email: emailTextField.text, password: passwordTextField.text, confirmPassword: confirmPasswordTextField.text) { (result) in
            switch result {
            case .success(let user):
                self.showAlert(with: "Success", and: "You have been registered.") {
                    self.present(SetupProfileViewController(currentUser: user), animated: true, completion: nil)
                }
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
    }
    
    @objc private func loginButtonTapped() {
        dismiss(animated: true) {
            self.delegate?.toLoginViewController()
        }
    }
    
}

//MARK: - Setup constraints
private extension SignUpViewController {
    
    func setupConstraints() {
        let emailStackView = UIStackView(arrangedSubviews: [emailLabel, emailTextField], axis: .vertical, spacing: 0)
        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel, passwordTextField], axis: .vertical, spacing: 0)
        let confirmPasswordStackView = UIStackView(arrangedSubviews: [confirmPasswordLabel, confirmPasswordTextField], axis: .vertical, spacing: 0)
        
        NSLayoutConstraint.activate([
            signUpButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        let stackView = UIStackView(arrangedSubviews: [
            emailStackView,
            passwordStackView,
            confirmPasswordStackView,
            signUpButton
        ], axis: .vertical, spacing: 40)
        
        let bottomStackView = UIStackView(arrangedSubviews: [alreadyOnBoardLabel, loginButton], axis: .horizontal, spacing: 10)
        bottomStackView.alignment = .firstBaseline
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(welcomeLabel)
        view.addSubview(stackView)
        view.addSubview(bottomStackView)
        
        NSLayoutConstraint.activate([
            welcomeLabel.bottomAnchor.constraint(lessThanOrEqualTo: stackView.topAnchor, constant: -30),
            welcomeLabel.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor, constant: 160),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: bottomStackView.topAnchor, constant: -40),
            stackView.leadingAnchor.constraint(equalTo: bottomStackView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: bottomStackView.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            bottomStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
    }
    
}
