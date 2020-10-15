//
//  UserProfileHeaderCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-21.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

protocol UserProfileHeaderCellDelegate {
    func switchuserMode(forMode mode: Int)
    func dispalayBecomeAJugglerAlert()
    func handleProfileImageView()
}

class UserProfileHeaderCell: UICollectionViewCell {
    
    //MARK: Stored properties
    var delegate: UserProfileHeaderCellDelegate?
    
    var user: User? {
        didSet {
            guard let user = self.user else {
                return
            }
            
            profileImageView.loadImage(from: user.profileImageURLString)
            fullNameLabel.text = user.firstName + " " + user.lastName
            
            if user.userId == Auth.auth().currentUser?.uid  { // Add button to allow users to edit their profile pictures.
                let button = UIButton()
                addSubview(button)
                button.anchor(top: profileImageView.topAnchor, left: profileImageView.leftAnchor, bottom: profileImageView.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
                button.addTarget(self, action: #selector(handleProfileImageView), for: .touchUpInside)
            }
        }
    }
    
    let profileImageView: CustomImageView = {
        let image = CustomImageView()
        image.backgroundColor = .lightGray
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.layer.borderColor = UIColor.mainBlue().cgColor
        image.layer.borderWidth = 1.5
        
        return image
    }()
    
    @objc fileprivate func handleProfileImageView() {
        delegate?.handleProfileImageView()
    }
    
    let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var userSwitchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Modo Usuario", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(UIColor.mainBlue(), for: .normal)
        button.layer.borderColor = UIColor.mainBlue().cgColor
        button.layer.borderWidth = 1.5
        button.isEnabled = false
        button.tag = 0
        button.addTarget(self, action: #selector(handleSwitchButtons(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var jugglerSwitchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Modo Juggler", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.lightGray, for: .normal)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1.5
        button.tag = 1
        button.addTarget(self, action: #selector(handleSwitchButtons(_:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleSwitchButtons(_ button: UIButton) {
        if button.tag == 0 { //User button
            userSwitchButton.isEnabled = false
            userSwitchButton.setTitleColor(UIColor.mainBlue(), for: .normal)
            userSwitchButton.layer.borderColor = UIColor.mainBlue().cgColor
            
            jugglerSwitchButton.isEnabled = true
            jugglerSwitchButton.setTitleColor(.lightGray, for: .normal)
            jugglerSwitchButton.layer.borderColor = UIColor.lightGray.cgColor
        } else if button.tag == 1 { //Juggler button
            if let user = self.user, user.userId == Auth.auth().currentUser?.uid, !user.isJuggler {
                self.delegate?.dispalayBecomeAJugglerAlert()
                return
            }
            userSwitchButton.isEnabled = true
            userSwitchButton.setTitleColor(.lightGray, for: .normal)
            userSwitchButton.layer.borderColor = UIColor.lightGray.cgColor
            
            jugglerSwitchButton.isEnabled = false
            jugglerSwitchButton.setTitleColor(UIColor.mainBlue(), for: .normal)
            jugglerSwitchButton.layer.borderColor = UIColor.mainBlue().cgColor
        }
        
        self.delegate?.switchuserMode(forMode: button.tag)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        profileImageView.layer.cornerRadius = 100/2
        
        addSubview(fullNameLabel)
        fullNameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        let switchButtonsStackView = UIStackView(arrangedSubviews: [userSwitchButton, jugglerSwitchButton])
        switchButtonsStackView.axis = .horizontal
        switchButtonsStackView.distribution = .fillEqually
        switchButtonsStackView.spacing = 8
        
        addSubview(switchButtonsStackView)
        switchButtonsStackView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 35)
        
        userSwitchButton.layer.cornerRadius = 5
        jugglerSwitchButton.layer.cornerRadius = 5
    }
}
