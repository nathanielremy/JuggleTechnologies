//
//  DashboardHeaderCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-02.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit

protocol DashboardHeaderCellDelegate {
    func changeFilterOptions(forFilterValue filterValue: Int, isUserMode: Bool)
}

class DashboardHeaderCell: UICollectionViewCell {
    
    //MARK: Stored properties
    var isUserMode: Bool = true
    var delegate: DashboardHeaderCellDelegate?
    
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
            isUserMode = true
            userSwitchButton.isEnabled = false
            jugglerSwitchButton.isEnabled = true
            userSwitchButton.backgroundColor = UIColor.darkText.withAlphaComponent(1)
            jugglerSwitchButton.backgroundColor = UIColor.darkText.withAlphaComponent(0.3)
            delegate?.changeFilterOptions(forFilterValue: 1, isUserMode: true) // Fetch userTasks and filter for onGoing
        } else if button.tag == 1 { //Juggler button
            isUserMode = false
            userSwitchButton.isEnabled = true
            jugglerSwitchButton.isEnabled = false
            userSwitchButton.backgroundColor = UIColor.darkText.withAlphaComponent(0.3)
            jugglerSwitchButton.backgroundColor = UIColor.darkText.withAlphaComponent(1)
            delegate?.changeFilterOptions(forFilterValue: 2, isUserMode: false) // Fetch jugglerTasks and filter for accepted
        }
        
        setupFilterOptionsStackView(forMode: button.tag)
    }
    
    
    fileprivate func setupFilterOptionsStackView(forMode mode: Int) {
        if mode == 0 {
            filterOptionsStackView.removeArrangedSubview(savedFilterOptionButton)
            savedFilterOptionButton.isHidden = true
            onGoingFilterOptionButton.isHidden = false
            
            filterOptionsStackView.addArrangedSubview(onGoingFilterOptionButton)
            filterOptionsStackView.addArrangedSubview(acceptedFilterOptionButton)
            filterOptionsStackView.addArrangedSubview(completedFilterOptionButton)
            
            addSubview(filterOptionsStackView)
            filterOptionsStackView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
            
            addSubview(filterOptionButtonSeperatorView)
            filterOptionButtonSeperatorView.anchor(top: nil, left: onGoingFilterOptionButton.leftAnchor, bottom: bottomAnchor, right: onGoingFilterOptionButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 1)
            
            self.filterOptionButtonSeperatorView.removeFromSuperview()
            addSubview(filterOptionButtonSeperatorView)
            filterOptionButtonSeperatorView.anchor(top: nil, left: onGoingFilterOptionButton.leftAnchor, bottom: bottomAnchor, right: onGoingFilterOptionButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 1)
        } else if mode == 1 {
            filterOptionsStackView.removeArrangedSubview(onGoingFilterOptionButton)
            onGoingFilterOptionButton.isHidden = true
            savedFilterOptionButton.isHidden = false
            
            filterOptionsStackView.addArrangedSubview(acceptedFilterOptionButton)
            filterOptionsStackView.addArrangedSubview(completedFilterOptionButton)
            filterOptionsStackView.addArrangedSubview(savedFilterOptionButton)
            
            addSubview(filterOptionsStackView)
            filterOptionsStackView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
            
            addSubview(filterOptionButtonSeperatorView)
            filterOptionButtonSeperatorView.anchor(top: nil, left: onGoingFilterOptionButton.leftAnchor, bottom: bottomAnchor, right: onGoingFilterOptionButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 1)
            
            self.filterOptionButtonSeperatorView.removeFromSuperview()
            addSubview(filterOptionButtonSeperatorView)
            filterOptionButtonSeperatorView.anchor(top: nil, left: acceptedFilterOptionButton.leftAnchor, bottom: bottomAnchor, right: acceptedFilterOptionButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 1)
        }
    }
    
    //MARK: User filrer option buttons below until initializer method
    lazy var onGoingFilterOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("On Going", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.titleLabel?.textAlignment = .center
        button.tintColor = .darkText
        button.addTarget(self, action: #selector(handleUserFilterOptionButton), for: .touchUpInside)
        button.tag = 1 //Used later in action call to identify selected filter option
        
        return button
    }()
    
    lazy var acceptedFilterOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Aceptada", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.titleLabel?.textAlignment = .center
        button.tintColor = .darkText
        button.addTarget(self, action: #selector(handleUserFilterOptionButton), for: .touchUpInside)
        button.tag = 2 //Used later in action call to identify selected filter option
        
        return button
    }()
    
    lazy var completedFilterOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Completada", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.titleLabel?.textAlignment = .center
        button.tintColor = .darkText
        button.addTarget(self, action: #selector(handleUserFilterOptionButton), for: .touchUpInside)
        button.tag = 3 //Used later in action call to identify selected filter option
        
        return button
    }()
    
    lazy var savedFilterOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Guardada", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.titleLabel?.textAlignment = .center
        button.tintColor = .darkText
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
    
    let filterOptionButtonSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkText
        
        return view
    }()

    @objc fileprivate func handleUserFilterOptionButton(forButton button: UIButton) {
        self.filterOptionButtonSeperatorView.removeFromSuperview()
        addSubview(filterOptionButtonSeperatorView)
        filterOptionButtonSeperatorView.anchor(top: nil, left: button.leftAnchor, bottom: bottomAnchor, right: button.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 1)
        
        delegate?.changeFilterOptions(forFilterValue: button.tag, isUserMode: self.isUserMode)
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
        let switchButtonsStackView = UIStackView(arrangedSubviews: [userSwitchButton, jugglerSwitchButton])
        switchButtonsStackView.axis = .horizontal
        switchButtonsStackView.distribution = .fillEqually
        switchButtonsStackView.spacing = -5
        
        addSubview(switchButtonsStackView)
        switchButtonsStackView.anchor(top: nil, left: leftAnchor, bottom: topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 55, paddingRight: -20, width: nil, height: 35)
        
        userSwitchButton.layer.cornerRadius = 5
        jugglerSwitchButton.layer.cornerRadius = 5
        
        let switchButtonSeperatorView = UIView()
        switchButtonSeperatorView.backgroundColor = .white
        
        addSubview(switchButtonSeperatorView)
        switchButtonSeperatorView.anchor(top: switchButtonsStackView.topAnchor, left: nil, bottom: switchButtonsStackView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 5, height: nil)
        switchButtonSeperatorView.centerXAnchor.constraint(equalTo: switchButtonsStackView.centerXAnchor).isActive = true
        
        self.setupFilterOptionsStackView(forMode: 0)
    }
}
