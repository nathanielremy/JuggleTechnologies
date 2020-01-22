//
//  UserProfileHeaderCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-21.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit

class UserProfileHeaderCell: UICollectionViewCell {
    
    //MARK: Stored properties
    var user: User? {
        didSet {
            guard let user = self.user else {
                return
            }
            
            profileImageView.loadImage(from: user.profileImageURLString)
            fullNameLabel.text = user.firstName + " " + user.lastName
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.locale = Locale(identifier: "es_ES")
            dateFormatterPrint.dateFormat = "dd, MMM, yyyy"
            
            memberSinceLabel.text = "Miembro desde el " + dateFormatterPrint.string(from: user.creationDate)
        }
    }
    
    let profileImageView: CustomImageView = {
        let image = CustomImageView()
        image.backgroundColor = .lightGray
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.layer.borderColor = UIColor.darkText.cgColor
        image.layer.borderWidth = 1.5
        
        return image
    }()
    
    let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        label.textAlignment = .center
        
        return label
    }()
    
    let memberSinceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var userSwitchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Como Usador", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.darkText
        button.isEnabled = false
        button.tag = 0
        button.addTarget(self, action: #selector(handleSwitchButtons(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var jugglerSwitchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Como Juggler", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.darkText.withAlphaComponent(0.3)
        button.tag = 1
        button.addTarget(self, action: #selector(handleSwitchButtons(_:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleSwitchButtons(_ button: UIButton) {
        if button.tag == 0 { //User button
            userSwitchButton.isEnabled = false
            jugglerSwitchButton.isEnabled = true
            userSwitchButton.backgroundColor = UIColor.darkText.withAlphaComponent(1)
            jugglerSwitchButton.backgroundColor = UIColor.darkText.withAlphaComponent(0.3)
        } else { //Juggler button
            userSwitchButton.isEnabled = true
            jugglerSwitchButton.isEnabled = false
            userSwitchButton.backgroundColor = UIColor.darkText.withAlphaComponent(0.3)
            jugglerSwitchButton.backgroundColor = UIColor.darkText.withAlphaComponent(1)
        }
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
        
        addSubview(memberSinceLabel)
        memberSinceLabel.anchor(top: fullNameLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        let switchButtonsStackView = UIStackView(arrangedSubviews: [userSwitchButton, jugglerSwitchButton])
        switchButtonsStackView.axis = .horizontal
        switchButtonsStackView.distribution = .fillEqually
        switchButtonsStackView.spacing = -5
        
        addSubview(switchButtonsStackView)
        switchButtonsStackView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 35)
        
        userSwitchButton.layer.cornerRadius = 5
        jugglerSwitchButton.layer.cornerRadius = 5
        
        let switchButtonSeperatorView = UIView()
        switchButtonSeperatorView.backgroundColor = .white
        
        addSubview(switchButtonSeperatorView)
        switchButtonSeperatorView.anchor(top: switchButtonsStackView.topAnchor, left: nil, bottom: switchButtonsStackView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 5, height: nil)
        switchButtonSeperatorView.centerXAnchor.constraint(equalTo: switchButtonsStackView.centerXAnchor).isActive = true
    }
}
