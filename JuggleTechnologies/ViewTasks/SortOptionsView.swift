//
//  SortOptionsView.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-03-24.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit

protocol SortOptionsViewDelegate {
    func sort(forSortOption sortOption: Int)
}

class SortOptionsView: UIView {
    //MARK: Stored properties
    var delegate: SortOptionsViewDelegate?
    var headerDelegate: ViewTasksHeaderCellDelegate?
    
    var selectedSortOption: Int? {
        didSet {
            guard let option = self.selectedSortOption else {
                return
            }
            
            mostRecentSortOptionButton.tintColor = UIColor.darkText
            oldestSortOptionButton.tintColor = UIColor.darkText
            highestBudgetSortOptionButton.tintColor = UIColor.darkText
            lowestBudgetSortOptionButton.tintColor = UIColor.darkText
            
            if option == 0 {
                mostRecentSortOptionButton.tintColor = UIColor.mainBlue()
            } else if option == 1 {
                oldestSortOptionButton.tintColor = UIColor.mainBlue()
            } else if  option == 2 {
                highestBudgetSortOptionButton.tintColor = UIColor.mainBlue()
            } else if option == 3  {
                lowestBudgetSortOptionButton.tintColor = UIColor.mainBlue()
            }
        }
    }
    
    lazy var sortButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "sortTask"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.tintColor = UIColor.mainBlue()
        button.addTarget(self, action: #selector(handleSortButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func  handleSortButton() {
        headerDelegate?.handleSortButton()
    }
    
    lazy var mostRecentSortOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Más reciente al más antiguo", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.contentHorizontalAlignment = .left
        button.tintColor = .darkText
        button.tag = 0
        button.addTarget(self, action: #selector(handleSortOption(forButton:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var oldestSortOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Más antiguo al más reciente", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.contentHorizontalAlignment = .left
        button.tintColor = .darkText
        button.tag = 1
        button.addTarget(self, action: #selector(handleSortOption(forButton:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var highestBudgetSortOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Presupuesto de mayor a menor", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.contentHorizontalAlignment = .left
        button.tintColor = .darkText
        button.tag = 2
        button.addTarget(self, action: #selector(handleSortOption(forButton:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var lowestBudgetSortOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Presupuesto de menor a mayor", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.contentHorizontalAlignment = .left
        button.tintColor = .darkText
        button.tag = 3
        button.addTarget(self, action: #selector(handleSortOption(forButton:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleSortOption(forButton button: UIButton) {
        self.selectedSortOption = button.tag
        self.delegate?.sort(forSortOption: button.tag)
        self.headerDelegate?.handleSortButton()
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
        addSubview(sortButton)
        sortButton.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 30, height: 27)
        sortButton.centerYAnchor.constraint(equalTo: topAnchor, constant: 25).isActive = true
        
        let sortOptionsStackView = UIStackView(arrangedSubviews: [
            mostRecentSortOptionButton,
            oldestSortOptionButton,
            highestBudgetSortOptionButton,
            lowestBudgetSortOptionButton
        ])
        sortOptionsStackView.axis = .vertical
        sortOptionsStackView.distribution = .fillEqually
        sortOptionsStackView.spacing = 20
        
        addSubview(sortOptionsStackView)
        sortOptionsStackView.anchor(top: sortButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        let firstSeperatorView = UIView()
        firstSeperatorView.backgroundColor = .lightGray
        addSubview(firstSeperatorView)
        firstSeperatorView.anchor(top: nil, left: mostRecentSortOptionButton.leftAnchor, bottom: mostRecentSortOptionButton.bottomAnchor, right: mostRecentSortOptionButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 1)
        
        let secondSeperatorView = UIView()
        secondSeperatorView.backgroundColor = .lightGray
        addSubview(secondSeperatorView)
        secondSeperatorView.anchor(top: nil, left: oldestSortOptionButton.leftAnchor, bottom: oldestSortOptionButton.bottomAnchor, right: oldestSortOptionButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 1)
        
        let thirdSeperatorView = UIView()
        thirdSeperatorView.backgroundColor = .lightGray
        addSubview(thirdSeperatorView)
        thirdSeperatorView.anchor(top: nil, left: highestBudgetSortOptionButton.leftAnchor, bottom: highestBudgetSortOptionButton.bottomAnchor, right: highestBudgetSortOptionButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 1)
        
        let fourthSeperatorView = UIView()
        fourthSeperatorView.backgroundColor = .lightGray
        addSubview(fourthSeperatorView)
        fourthSeperatorView.anchor(top: nil, left: lowestBudgetSortOptionButton.leftAnchor, bottom: lowestBudgetSortOptionButton.bottomAnchor, right: lowestBudgetSortOptionButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 1)
    }
}
