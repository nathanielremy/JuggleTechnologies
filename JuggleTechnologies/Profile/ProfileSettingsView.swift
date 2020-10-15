//
//  ProfileSettingsView.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-09-20.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

protocol ProfileSettingsViewDelegete {
    func handleSettingsOption(option: Int)
}

class ProfileSettingsView: UIView {
    //MARK: Stored properties
    var delegate: ProfileSettingsViewDelegete?
    
    lazy var becomeAJugglerSettingsOption: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("¡Se un Juggler!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.contentHorizontalAlignment = .left
        button.tintColor = .darkText
        button.tag = 0
        button.addTarget(self, action: #selector(handleSettingsOption(forButton:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var termsAndConditionsSettingsOption: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Terms and conditons", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.contentHorizontalAlignment = .left
        button.tintColor = .darkText
        button.tag = 1
        button.addTarget(self, action: #selector(handleSettingsOption(forButton:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var logOutSettingsOption: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cerrar sesión", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.contentHorizontalAlignment = .left
        button.tintColor = .darkText
        button.tag = 2
        button.addTarget(self, action: #selector(handleSettingsOption(forButton:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleSettingsOption(forButton button: UIButton) {
        delegate?.handleSettingsOption(option: button.tag)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setUpViews() {
        let profileSettingsOptionsStackView = UIStackView(arrangedSubviews: [
            becomeAJugglerSettingsOption,
            termsAndConditionsSettingsOption,
            logOutSettingsOption
        ])
        profileSettingsOptionsStackView.axis = .vertical
        profileSettingsOptionsStackView.distribution = .fillEqually
        profileSettingsOptionsStackView.spacing = 20
        
        addSubview(profileSettingsOptionsStackView)
        profileSettingsOptionsStackView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        let firstSeperatorView = UIView()
        firstSeperatorView.backgroundColor = .lightGray
        addSubview(firstSeperatorView)
        firstSeperatorView.anchor(top: nil, left: becomeAJugglerSettingsOption.leftAnchor, bottom: becomeAJugglerSettingsOption.bottomAnchor, right: becomeAJugglerSettingsOption.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 1)
        
        let secondSeperatorView = UIView()
        secondSeperatorView.backgroundColor = .lightGray
        addSubview(secondSeperatorView)
        secondSeperatorView.anchor(top: nil, left: termsAndConditionsSettingsOption.leftAnchor, bottom: termsAndConditionsSettingsOption.bottomAnchor, right: termsAndConditionsSettingsOption.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 1)
        
        let thirdSeperatorView = UIView()
        thirdSeperatorView.backgroundColor = .lightGray
        addSubview(thirdSeperatorView)
        thirdSeperatorView.anchor(top: nil, left: logOutSettingsOption.leftAnchor, bottom: logOutSettingsOption.bottomAnchor, right: logOutSettingsOption.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 1)
    }
}
