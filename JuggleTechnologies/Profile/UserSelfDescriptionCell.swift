//
//  UserSelfDescriptionCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-22.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class UserSelfDescriptionCell: UICollectionViewCell {
    
    var user: User? {
        didSet {
            guard let user = self.user else {
                return
            }
            
            if user.userId == Auth.auth().currentUser?.uid {
                userDescriptionLabel.text = "Descripción de mi mismo"
            } else {
                userDescriptionLabel.text = "Descripción de \(user.firstName) + \(user.lastName)"
            }
        }
    }
    
    let userDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var userDescriptionTextView: UITextView = {
        let tv = UITextView()
        tv.textColor = UIColor.lightGray
        tv.text = "No hay descripción"
        tv.tintColor = .darkText
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.isScrollEnabled = true
        tv.bounces = true
        
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
    }
}

extension UserSelfDescriptionCell: UITextViewDelegate {
    // When done button is clicked on keyboard input accessory view
    @objc func handleTextFieldDoneButton() {
        endEditing(true)
    }
}
