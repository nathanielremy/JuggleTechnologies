//
//  DashboardHeaderCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-02.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import  Firebase

protocol DashboardHeaderCellDelegate {
    func changeFilterOptions(forFilterValue filterValue: Int, isUserMode: Bool)
    func dispalayBecomeAJugglerAlert()
}

class DashboardHeaderCell: UICollectionViewCell {
    
    //MARK: Stored properties
    var isUserMode: Bool = true
    var delegate: DashboardHeaderCellDelegate?
    var currentUser: User?
    
    lazy var userSwitchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Modo Usuario", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(UIColor.mainBlue(), for: .normal)
        button.layer.borderColor = UIColor.mainBlue().cgColor
        button.layer.borderWidth = 1
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
        button.layer.borderWidth = 1
        button.tag = 1
        button.addTarget(self, action: #selector(handleSwitchButtons(_:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleSwitchButtons(_ button: UIButton) {
        if button.tag == 0 { //User button
            isUserMode = true
            userSwitchButton.setTitleColor(UIColor.mainBlue(), for: .normal)
            userSwitchButton.layer.borderColor = UIColor.mainBlue().cgColor
            
            jugglerSwitchButton.isEnabled = true
            jugglerSwitchButton.setTitleColor(.lightGray, for: .normal)
            jugglerSwitchButton.layer.borderColor = UIColor.lightGray.cgColor
        } else if button.tag == 1 { //Juggler button
            guard let user = self.currentUser, user.isJuggler else {
                self.delegate?.dispalayBecomeAJugglerAlert()
                return
            }
            isUserMode = false
            userSwitchButton.isEnabled = true
            userSwitchButton.setTitleColor(.lightGray, for: .normal)
            userSwitchButton.layer.borderColor = UIColor.lightGray.cgColor
            
            jugglerSwitchButton.isEnabled = false
            jugglerSwitchButton.setTitleColor(UIColor.mainBlue(), for: .normal)
            jugglerSwitchButton.layer.borderColor = UIColor.mainBlue().cgColor
        }
        
        setupFilterOptionsStackView(forMode: button.tag)
    }
    
    
    fileprivate func setupFilterOptionsStackView(forMode mode: Int) {
        if mode == 0 {
            //Rearrange UIStackView with the correct filter options
            filterOptionsStackView.removeArrangedSubview(savedFilterOptionButton)
            savedFilterOptionButton.isHidden = true
            onGoingFilterOptionButton.isHidden = false
            
            filterOptionsStackView.addArrangedSubview(onGoingFilterOptionButton)
            filterOptionsStackView.addArrangedSubview(acceptedFilterOptionButton)
            filterOptionsStackView.addArrangedSubview(completedFilterOptionButton)
            
            addSubview(filterOptionsStackView)
            filterOptionsStackView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
            
            self.handleUserFilterOptionButton(forButton: onGoingFilterOptionButton)
        } else if mode == 1 {
            //Rearrange UIStackView with the correct filter options
            filterOptionsStackView.removeArrangedSubview(onGoingFilterOptionButton)
            onGoingFilterOptionButton.isHidden = true
            savedFilterOptionButton.isHidden = false
            
            filterOptionsStackView.addArrangedSubview(acceptedFilterOptionButton)
            filterOptionsStackView.addArrangedSubview(completedFilterOptionButton)
            filterOptionsStackView.addArrangedSubview(savedFilterOptionButton)
            
            addSubview(filterOptionsStackView)
            filterOptionsStackView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
            
            self.handleUserFilterOptionButton(forButton: acceptedFilterOptionButton)
        }
    }
    
    //MARK: User filrer option buttons below until initializer method
    lazy var onGoingFilterOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pendientes", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.titleLabel?.textAlignment = .center
        button.tintColor = .darkText
        button.addTarget(self, action: #selector(handleUserFilterOptionButton), for: .touchUpInside)
        button.tag = 1 //Used later in action call to identify selected filter option
        
        return button
    }()
    
    lazy var acceptedFilterOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Aceptadas", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.titleLabel?.textAlignment = .center
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(handleUserFilterOptionButton), for: .touchUpInside)
        button.tag = 2 //Used later in action call to identify selected filter option
        
        return button
    }()
    
    lazy var completedFilterOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Completadas", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.titleLabel?.textAlignment = .center
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(handleUserFilterOptionButton), for: .touchUpInside)
        button.tag = 3 //Used later in action call to identify selected filter option
        
        return button
    }()
    
    lazy var savedFilterOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Guardadas", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.titleLabel?.textAlignment = .center
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(handleUserFilterOptionButton), for: .touchUpInside)
        button.tag = 4 //Used later in action call to identify selected filter option
        
        return button
    }()
    
    let filterOptionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    let filterOptionButtonBottomSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkText
        
        return view
    }()

    @objc fileprivate func handleUserFilterOptionButton(forButton button: UIButton) {
        onGoingFilterOptionButton.tintColor = .lightGray
        acceptedFilterOptionButton.tintColor = .lightGray
        completedFilterOptionButton.tintColor = .lightGray
        savedFilterOptionButton.tintColor = .lightGray
        
        button.tintColor = .darkText
        
        self.filterOptionButtonBottomSeperatorView.removeFromSuperview()
        addSubview(filterOptionButtonBottomSeperatorView)
        filterOptionButtonBottomSeperatorView.anchor(top: nil, left: button.leftAnchor, bottom: bottomAnchor, right: button.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 1)
        
        delegate?.changeFilterOptions(forFilterValue: button.tag, isUserMode: self.isUserMode)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        fetchCurrentUser()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func fetchCurrentUser() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        Database.fetchUserFromUserID(userID: currentUserId) { (user) in
            if let currentUser = user {
                self.currentUser = currentUser
            }
        }
    }
    
    fileprivate func setupViews() {
        let switchButtonsStackView = UIStackView(arrangedSubviews: [userSwitchButton, jugglerSwitchButton])
        switchButtonsStackView.axis = .horizontal
        switchButtonsStackView.distribution = .fillEqually
        switchButtonsStackView.spacing = 8
        
        addSubview(switchButtonsStackView)
        switchButtonsStackView.anchor(top: nil, left: leftAnchor, bottom: topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 55, paddingRight: -20, width: nil, height: 35)
        
        userSwitchButton.layer.cornerRadius = 5
        jugglerSwitchButton.layer.cornerRadius = 5
        
        self.setupFilterOptionsStackView(forMode: 0)
    }
}
