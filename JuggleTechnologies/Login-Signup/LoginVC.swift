//
//  LoginVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-18.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    //MARK: Stored properties
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.bounces = true
        sv.backgroundColor = .white
        
        return sv
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = UIColor.mainBlue()
        
        return ai
    }()
    
    let logoContainerView: UIView = {
        let view = UIView()
        
        let logoLabel = UILabel()
        logoLabel.textAlignment = .center
        logoLabel.textColor = UIColor.mainBlue()
        logoLabel.font = UIFont.boldSystemFont(ofSize: 60)
        logoLabel.text = "Juggle"
        
        view.addSubview(logoLabel)
        logoLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = .lightGray
        
        view.addSubview(seperatorView)
        seperatorView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: -15, width: nil, height: 0.5)
        
        return view
    }()
    
    lazy var emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Correo Electrónico"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.tintColor = UIColor.darkText
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextInputChanges), for: .editingChanged)
        
        return tf
    }()
    
    lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Contraseña"
        tf.isSecureTextEntry = true
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.tintColor = UIColor.darkText
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextInputChanges), for: .editingChanged)
        
        return tf
    }()
    
    @objc fileprivate func handleTextInputChanges() {
        
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 5
        
        if isFormValid {
            loginButton.backgroundColor = UIColor.mainBlue().withAlphaComponent(1)
            loginButton.isEnabled = true
        } else {
            loginButton.backgroundColor = UIColor.mainBlue().withAlphaComponent(0.3)
            loginButton.isEnabled = false
        }
    }
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Iniciar Sesión", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.tintColor = .white
        button.backgroundColor = UIColor.mainBlue().withAlphaComponent(0.3)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleLogin() {
        disableAndAnimate(true)
        
        guard let email = emailTextField.text, let passcode = passwordTextField.text else {
            let alert = UIView.okayAlert(title: "Empty Forms", message: "Please fill out all forms to sign in.")
            self.display(alert: alert)
            self.disableAndAnimate(false)
            
            return
        }
        
        Auth.loginUser(withEmail: email, passcode: passcode) { (usr, err) in
            if let errorString = err {
                if errorString == Constants.ErrorDescriptions.invalidPassword {
                    let alert = UIView.okayAlert(title: "Invalid Password", message: "Please enter the correct password for this user.")
                    self.display(alert: alert)
                    
                } else if errorString == Constants.ErrorDescriptions.invalidEmailAddress {
                    let alert = UIView.okayAlert(title: "Invalid Email", message: "There are no users with this corresponding email address")
                    self.display(alert: alert)
                    
                } else if errorString == Constants.ErrorDescriptions.networkError {
                    let alert = UIView.okayAlert(title: "Network Connection Error", message: "Please try connectig to a better network.")
                    self.display(alert: alert)
                    
                } else {
                    let alert = UIView.okayAlert(title: "Error Logging In", message: "Please verify that you have entered the correct credentials.")
                    self.display(alert: alert)
                }
                
                self.disableAndAnimate(false)
                return
            }
            
            if usr != nil {
                DispatchQueue.main.async {
                    self.disableAndAnimate(false)
                    
                    // Delete and refresh info in mainTabBar controllers
                    guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { fatalError() }
                    mainTabBarController.setupViewControllers()
                    
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                do {
                    self.disableAndAnimate(false)
                    try Auth.auth().signOut()
                    let alert = UIView.okayAlert(title: "Unable to log in", message: "Please verify that you have entered the correct information.")
                    self.display(alert: alert)
                    
                } catch let signOutError {
                    fatalError("Unable to sign out: \(signOutError)")
                }
            }
        }
    }
    
    let switchToSignupButton: UIButton = {
        let button = UIButton(type: .system)

        let attributedTitle = NSMutableAttributedString(string: "No tienes cuenta?  ", attributes: [.font : UIFont.systemFont(ofSize: 14), .foregroundColor : UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Regístrate.", attributes: [.font : UIFont.boldSystemFont(ofSize: 14), .foregroundColor : UIColor.mainBlue()]))

        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleSwitchToSignup), for: .touchUpInside)

        return button
    }()
    
    @objc fileprivate func handleSwitchToSignup() {
        let signupVC = SignupVC()
        navigationController?.pushViewController(signupVC, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        navigationItem.hidesBackButton = true
        
        setupViews()
    }
    
    //Programmatically displaying the programmaticaly created views
    //anchor(top,left,bottom,right,paddingTop,paddingLeft,paddingBottom,paddingRight) func in Utilities/Extensions.swift
    fileprivate func setupViews() {
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 150)
        
        view.addSubview(scrollView)
        scrollView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height - 120)
        
        let stackView = UIStackView(arrangedSubviews: [
            emailTextField,
            passwordTextField,
            loginButton
            ])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        scrollView.addSubview(stackView)
        stackView.anchor(top: scrollView.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 40, paddingBottom: 0, paddingRight: -40, width: nil, height: 150)
        
        scrollView.addSubview(switchToSignupButton)
        switchToSignupButton.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 50)
    }
    
    func disableAndAnimate(_ bool: Bool) {
        DispatchQueue.main.async {
            if bool {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
        
        emailTextField.isEnabled = !bool
        passwordTextField.isEnabled = !bool
        loginButton.isEnabled = !bool
        switchToSignupButton.isEnabled = !bool
    }
    
    fileprivate func display(alert: UIAlertController) {
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: UITextFieldDelegate methods
extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        return true
    }
}
