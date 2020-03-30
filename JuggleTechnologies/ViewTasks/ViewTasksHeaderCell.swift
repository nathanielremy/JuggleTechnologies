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
    func handleMapViewUIOption()
    func handleSortButton()
}

class ViewTasksHeaderCell: UICollectionViewCell {
    //MARK: Stored properties
    var currentCategory = Constants.TaskCategories.all
    var delegate: ViewTasksHeaderCellDelegate?
    
    var selectedSortOption: Int? {
        didSet {
            guard let option = self.selectedSortOption else {
                return
            }
            
            if option == 0 {
                self.sortOptionLabel.text = "Más reciente al más antiguo"
            } else if option == 1 {
                self.sortOptionLabel.text = "Más antiguo al más reciente"
            } else if option == 2 {
                self.sortOptionLabel.text = "Presupuesto de mayor a menor"
            } else if option == 3 {
                self.sortOptionLabel.text = "Presupuesto de menor a mayor"
            }
        }
    }
    
    var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.bounces = true
        sv.backgroundColor = .white
        sv.showsHorizontalScrollIndicator = false
        
        return sv
    }()
    
    // UIButtons for task categories
    lazy var allCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.TaskCategories.all, for: .normal)
        button.tintColor = UIColor.darkText
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
    
    let categorySeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkText
        
        return view
    }()
    
    fileprivate func setupCategorySeperatorView(forButton button: UIButton) {
        categorySeperatorView.removeFromSuperview()
        button.addSubview(categorySeperatorView)
        categorySeperatorView.anchor(top: nil, left: button.leftAnchor, bottom: button.bottomAnchor, right: button.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 0, width: nil, height: 1)
    }
    
    @objc fileprivate func changeTaskCategory(_ button: UIButton) {
        if button.titleLabel?.text == self.currentCategory {
            return
        }
        
        self.setupCategorySeperatorView(forButton: button)

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
        
        button.tintColor = UIColor.darkText

        if button.titleLabel?.text == Constants.TaskCategories.all {
            delegate?.didChangeCategory(to: Constants.TaskCategories.all)
            self.currentCategory = Constants.TaskCategories.all

            return
        } else if button.titleLabel?.text == Constants.TaskCategories.cleaning {
            delegate?.didChangeCategory(to: Constants.TaskCategories.cleaning)
            self.currentCategory = Constants.TaskCategories.cleaning

            return
        } else if button.titleLabel?.text == Constants.TaskCategories.handyMan {
            delegate?.didChangeCategory(to: Constants.TaskCategories.handyMan)
            self.currentCategory = Constants.TaskCategories.handyMan

            return
        } else if button.titleLabel?.text == Constants.TaskCategories.computerIT {
            delegate?.didChangeCategory(to: Constants.TaskCategories.computerIT)
            self.currentCategory = Constants.TaskCategories.computerIT

            return
        } else if button.titleLabel?.text == Constants.TaskCategories.photoVideo {
            delegate?.didChangeCategory(to: Constants.TaskCategories.photoVideo)
            self.currentCategory = Constants.TaskCategories.photoVideo

            return
        } else if button.titleLabel?.text == Constants.TaskCategories.assembly {
            delegate?.didChangeCategory(to: Constants.TaskCategories.assembly)
            self.currentCategory = Constants.TaskCategories.assembly

            return
        } else if button.titleLabel?.text == Constants.TaskCategories.delivery {
            delegate?.didChangeCategory(to: Constants.TaskCategories.delivery)
            self.currentCategory = Constants.TaskCategories.delivery

            return
        } else if button.titleLabel?.text == Constants.TaskCategories.moving {
            delegate?.didChangeCategory(to: Constants.TaskCategories.moving)
            self.currentCategory = Constants.TaskCategories.moving

            return
        } else if button.titleLabel?.text == Constants.TaskCategories.pets {
            delegate?.didChangeCategory(to: Constants.TaskCategories.pets)
            self.currentCategory = Constants.TaskCategories.pets

            return
        } else if button.titleLabel?.text == Constants.TaskCategories.anything {
            delegate?.didChangeCategory(to: Constants.TaskCategories.anything)
            self.currentCategory = Constants.TaskCategories.anything

            return
        }
    }
    
    lazy var sortButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "sortTask"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.tintColor = UIColor.darkText
        button.addTarget(self, action: #selector(handleSortButton), for: .touchUpInside)
        
        return button
    }()
    
    
    @objc fileprivate func handleSortButton() {
        self.delegate?.handleSortButton()
    }
    
    lazy var listViewUIOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.isUserInteractionEnabled = false
        button.setTitle("Lista", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.darkText.cgColor
        button.layer.borderWidth = 0.5
        button.backgroundColor = .darkText
        button.tag = 0
        button.addTarget(self, action: #selector(handleUIOptionButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var mapViewUIOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Mapa", for: .normal)
        button.tintColor = .darkText
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.darkText.cgColor
        button.layer.borderWidth = 0.5
        button.backgroundColor = .white
        button.tag = 1
        button.addTarget(self, action: #selector(handleUIOptionButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleUIOptionButton(_ button: UIButton) {
        delegate?.handleMapViewUIOption()
    }
    
    let sortOptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .left
        label.textColor = UIColor.gray
        
        return label
    }()
    
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
        stackView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 50)
        
        addSubview(sortButton)
        sortButton.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 30, height: 27)
        sortButton.centerYAnchor.constraint(equalTo: bottomAnchor, constant: -25).isActive = true
        
        let UIOptionButtonStackView = UIStackView(arrangedSubviews: [listViewUIOptionButton, mapViewUIOptionButton])
        UIOptionButtonStackView.axis = .horizontal
        UIOptionButtonStackView.distribution = .fillEqually
        UIOptionButtonStackView.spacing = 0
        
        addSubview(UIOptionButtonStackView)
        UIOptionButtonStackView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: -20, width: 130, height: 27)
        UIOptionButtonStackView.centerYAnchor.constraint(equalTo: bottomAnchor, constant: -25).isActive = true
        
        setupCategorySeperatorView(forButton: allCategoryButton)
        
        addSubview(sortOptionLabel)
        sortOptionLabel.anchor(top: nil, left: sortButton.rightAnchor, bottom: nil, right: UIOptionButtonStackView.leftAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: -8, width: nil, height: nil)
        sortOptionLabel.centerYAnchor.constraint(equalTo: sortButton.centerYAnchor).isActive = true
        
        let bottomSeperatorView = UIView()
        bottomSeperatorView.backgroundColor = UIColor.darkText
        bottomSeperatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bottomSeperatorView)
        bottomSeperatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 1)
    }
}
