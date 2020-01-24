//
//  UserSelfDescriptionCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-22.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

protocol UserSelfDescriptionCellDelegate {
    func saveUserDescription(description: String?, completion: @escaping (Bool, String) -> Void)
}

class UserSelfDescriptionCell: UICollectionViewCell {
    
    //MARK: Stored properties
    var delegate: UserSelfDescriptionCellDelegate?
    var user: User? {
        didSet {
            guard let user = self.user else {
                return
            }
            
            userDescriptionTextView.text = user.description != "" ? user.description : "No hay descripción"
            
            if user.userId == Auth.auth().currentUser?.uid {
                userDescriptionLabel.text = "Descripción de mi mismo"
                addEditButtonToView()
            } else {
                userDescriptionLabel.text = "Descripción de \(user.firstName) + \(user.lastName)"
            }
        }
    }
    
    fileprivate func addEditButtonToView() {
        addSubview(editButton)
        editButton.anchor(top: nil, left: nil, bottom: userDescriptionTextView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: -20, width: nil, height: 15)
    }
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = UIColor.darkText
        ai.translatesAutoresizingMaskIntoConstraints = false
        
        return ai
    }()
    
    let userDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var userDescriptionTextView: UITextView = {
        let tv = UITextView()
        tv.textColor = UIColor.darkText
        tv.tintColor = .darkText
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.isScrollEnabled = true
        tv.bounces = true
        tv.isEditable = false
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(handleTextFieldDoneButton))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        tv.inputAccessoryView = toolBar
        
        // Remove placeholder text when user enters text methods in delegate
        tv.delegate = self
        
        return tv
    }()
    
    lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Editar", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.titleLabel?.textAlignment = .center
        button.tintColor = .darkText
        button.addTarget(self, action: #selector(handleEditButton), for: .touchUpInside)
        
        return button
    }()
    
    var isEditingDescription = false
    @objc fileprivate func handleEditButton() {
        if !isEditingDescription {
            editButton.setTitle("Guardar", for: .normal)
            userDescriptionTextView.isEditable = true
            userDescriptionTextView.becomeFirstResponder()
            setupSaveAndCaracterCountViews(true)
            isEditingDescription = true
            userDescriptionTextView.text = userDescriptionTextView.text == "No hay descripción" ? "" : userDescriptionTextView.text
        } else {
            self.activityIndicator.startAnimating()
            self.editButton.isEnabled = false
            delegate?.saveUserDescription(description: userDescriptionTextView.text, completion: { (success, description) in
                self.activityIndicator.stopAnimating()
                self.editButton.isEnabled = true
                
                self.userDescriptionTextView.text = success ? description : (self.user?.description != "" ? self.user?.description : "No hay descripción")
                self.user?.description = success ? description : self.user?.description ?? ""
                
                self.editButton.setTitle("Editar", for: .normal)
                self.userDescriptionTextView.isEditable = false
                self.handleTextFieldDoneButton()
                self.setupSaveAndCaracterCountViews(false)
                self.isEditingDescription = false
            })
        }
    }
    
    fileprivate func setupSaveAndCaracterCountViews(_ bool: Bool) {
        if bool {
            addSubview(cancelEditDescriptionButton)
            cancelEditDescriptionButton.anchor(top: nil, left: nil, bottom: userDescriptionTextView.topAnchor, right: editButton.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: -8, width: nil, height: 15)
            
            addSubview(userDescriptionCaracterCountLabel)
            userDescriptionCaracterCountLabel.anchor(top: nil, left: nil, bottom: editButton.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: -20, width: nil, height: 15)
            
        } else {
            cancelEditDescriptionButton.removeFromSuperview()
            userDescriptionCaracterCountLabel.removeFromSuperview()
        }
    }
    
    lazy var cancelEditDescriptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancelar", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.titleLabel?.textAlignment = .center
        button.tintColor = .darkText
        button.addTarget(self, action: #selector(handleCancelButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleCancelButton() {
        userDescriptionTextView.text = user?.description != "" ? user?.description : "No hay descripción"
        self.activityIndicator.stopAnimating()
        self.editButton.isEnabled = true
        self.editButton.setTitle("Editar", for: .normal)
        self.userDescriptionTextView.isEditable = false
        self.handleTextFieldDoneButton()
        self.setupSaveAndCaracterCountViews(false)
        self.isEditingDescription = false
    }
    
    let userDescriptionCaracterCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "0/500"
        
        return label
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        addSubview(userDescriptionLabel)
        userDescriptionLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 15)
        
        addSubview(userDescriptionTextView)
        userDescriptionTextView.anchor(top: userDescriptionLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 20, paddingBottom: -20, paddingRight: -20, width: nil, height: nil)
        
        let topDescriptionSeperatorView = UIView()
        topDescriptionSeperatorView.backgroundColor = .lightGray
        
        addSubview(topDescriptionSeperatorView)
        topDescriptionSeperatorView.anchor(top: userDescriptionTextView.topAnchor, left: userDescriptionTextView.leftAnchor, bottom: nil, right: userDescriptionTextView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
        
        let bottomDescriptionSeperatorView = UIView()
        bottomDescriptionSeperatorView.backgroundColor = .lightGray
        
        addSubview(bottomDescriptionSeperatorView)
        bottomDescriptionSeperatorView.anchor(top: nil, left: userDescriptionTextView.leftAnchor, bottom: userDescriptionTextView.bottomAnchor, right: userDescriptionTextView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
        
        addSubview(activityIndicator)
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
}

extension UserSelfDescriptionCell: UITextViewDelegate {
    // When done button is clicked on keyboard input accessory view
    @objc func handleTextFieldDoneButton() {
        endEditing(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let userDescription = userDescriptionTextView.text, textView == userDescriptionTextView {
            userDescriptionCaracterCountLabel.text = userDescription.count == 1 ? "0/500" : "\(userDescription.count)/500"
            if userDescription.count > 499 {
                userDescriptionTextView.text.removeLast()
                userDescriptionCaracterCountLabel.text = "\(userDescription.count)/500"
            }
        }
    }
}
