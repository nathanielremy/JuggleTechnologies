//
//  ViewTasksHeaderCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-24.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit

protocol ViewTasksHeaderCellDelegate {
    func didChangeCategory(to category: String)
}

class ViewTasksHeaderCell: UICollectionViewCell {
    //MARK: Stored properties
    var currentCategory = Constants.TaskCategories.all
    var delegate: ViewTasksHeaderCellDelegate?
    
    var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.bounces = true
        sv.backgroundColor = .white
        sv.showsHorizontalScrollIndicator = true
        
        return sv
    }()
    
    // UIButtons for task categories
    
    lazy var allCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.TaskCategories.all, for: .normal)
        button.tintColor = UIColor.mainBlue()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(changeTaskCategory(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var cleaningCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.TaskCategories.cleaning, for: .normal)
        button.tintColor = UIColor.lightGray
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(changeTaskCategory(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var handyManCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.TaskCategories.handyMan, for: .normal)
        button.tintColor = UIColor.lightGray
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(changeTaskCategory(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var computerITCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.TaskCategories.computerIT, for: .normal)
        button.tintColor = UIColor.lightGray
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(changeTaskCategory(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var photoVideoCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.TaskCategories.photoVideo, for: .normal)
        button.tintColor = UIColor.lightGray
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(changeTaskCategory(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var assemblyCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.TaskCategories.assembly, for: .normal)
        button.tintColor = UIColor.lightGray
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(changeTaskCategory(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var deliveryCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.TaskCategories.delivery, for: .normal)
        button.tintColor = UIColor.lightGray
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(changeTaskCategory(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var movingCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.TaskCategories.moving, for: .normal)
        button.tintColor = UIColor.lightGray
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(changeTaskCategory(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var petsCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.TaskCategories.pets, for: .normal)
        button.tintColor = UIColor.lightGray
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(changeTaskCategory(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var anythingCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.TaskCategories.anything, for: .normal)
        button.tintColor = UIColor.lightGray
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(changeTaskCategory(_:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func changeTaskCategory(_ button: UIButton) {
        if button.titleLabel?.text == self.currentCategory {
            return
        }

        allCategoryButton.tintColor = UIColor.lightGray
        cleaningCategoryButton.tintColor = UIColor.lightGray
        handyManCategoryButton.tintColor = UIColor.lightGray
        computerITCategoryButton.tintColor = UIColor.lightGray
        photoVideoCategoryButton.tintColor = UIColor.lightGray
        assemblyCategoryButton.tintColor = UIColor.lightGray
        deliveryCategoryButton.tintColor = UIColor.lightGray
        movingCategoryButton.tintColor = UIColor.lightGray
        petsCategoryButton.tintColor = UIColor.lightGray
        anythingCategoryButton.tintColor = UIColor.lightGray

        if button.titleLabel?.text == Constants.TaskCategories.all {
            allCategoryButton.tintColor = UIColor.mainBlue()
            delegate?.didChangeCategory(to: Constants.TaskCategories.all)
            self.currentCategory = Constants.TaskCategories.all

            return
        } else if button.titleLabel?.text == Constants.TaskCategories.cleaning {
            cleaningCategoryButton.tintColor = UIColor.mainBlue()
            delegate?.didChangeCategory(to: Constants.TaskCategories.cleaning)
            self.currentCategory = Constants.TaskCategories.cleaning

            return
        } else if button.titleLabel?.text == Constants.TaskCategories.handyMan {
            handyManCategoryButton.tintColor = UIColor.mainBlue()
            delegate?.didChangeCategory(to: Constants.TaskCategories.handyMan)
            self.currentCategory = Constants.TaskCategories.handyMan

            return
        } else if button.titleLabel?.text == Constants.TaskCategories.computerIT {
            computerITCategoryButton.tintColor = UIColor.mainBlue()
            delegate?.didChangeCategory(to: Constants.TaskCategories.computerIT)
            self.currentCategory = Constants.TaskCategories.computerIT

            return
        } else if button.titleLabel?.text == Constants.TaskCategories.photoVideo {
            photoVideoCategoryButton.tintColor = UIColor.mainBlue()
            delegate?.didChangeCategory(to: Constants.TaskCategories.photoVideo)
            self.currentCategory = Constants.TaskCategories.photoVideo

            return
        } else if button.titleLabel?.text == Constants.TaskCategories.assembly {
            assemblyCategoryButton.tintColor = UIColor.mainBlue()
            delegate?.didChangeCategory(to: Constants.TaskCategories.assembly)
            self.currentCategory = Constants.TaskCategories.assembly

            return
        } else if button.titleLabel?.text == Constants.TaskCategories.delivery {
            deliveryCategoryButton.tintColor = UIColor.mainBlue()
            delegate?.didChangeCategory(to: Constants.TaskCategories.delivery)
            self.currentCategory = Constants.TaskCategories.delivery

            return
        } else if button.titleLabel?.text == Constants.TaskCategories.moving {
            movingCategoryButton.tintColor = UIColor.mainBlue()
            delegate?.didChangeCategory(to: Constants.TaskCategories.moving)
            self.currentCategory = Constants.TaskCategories.moving

            return
        } else if button.titleLabel?.text == Constants.TaskCategories.pets {
            petsCategoryButton.tintColor = UIColor.mainBlue()
            delegate?.didChangeCategory(to: Constants.TaskCategories.pets)
            self.currentCategory = Constants.TaskCategories.pets

            return
        } else if button.titleLabel?.text == Constants.TaskCategories.anything {
            anythingCategoryButton.tintColor = UIColor.mainBlue()
            delegate?.didChangeCategory(to: Constants.TaskCategories.anything)
            self.currentCategory = Constants.TaskCategories.anything

            return
        }
    }
    
    lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("|||", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.tintColor = UIColor.mainBlue()
        button.addTarget(self, action: #selector(handleFilterButton), for: .touchUpInside)
        
        return button
    }()
    
    
    @objc fileprivate func handleFilterButton() {
        print("Handeling filterButton")
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
        addSubview(scrollView)
        scrollView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 50)
        scrollView.contentSize = CGSize(width: 900, height: 50)
        
        let stackView = UIStackView(arrangedSubviews: [allCategoryButton, cleaningCategoryButton, handyManCategoryButton, computerITCategoryButton, photoVideoCategoryButton, assemblyCategoryButton, deliveryCategoryButton, movingCategoryButton, petsCategoryButton, anythingCategoryButton])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        scrollView.addSubview(stackView)
        stackView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 50)
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = UIColor.mainBlue()
        
        addSubview(seperatorView)
        seperatorView.anchor(top: nil, left: leftAnchor, bottom: scrollView.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 3)
        
        addSubview(filterButton)
        filterButton.anchor(top: seperatorView.bottomAnchor, left: leftAnchor
            , bottom: bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 17, paddingBottom: -8, paddingRight: 0, width: 50, height: nil)
        
        let bottomSeperatorView = UIView()
        bottomSeperatorView.backgroundColor = .lightGray
        bottomSeperatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bottomSeperatorView)
        bottomSeperatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 1.5)
    }
}
