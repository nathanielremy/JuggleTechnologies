//
//  TaskCategoryPickerVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-18.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit

class TaskCategoryPickerVC: UIViewController {
    
    let mainLabel: UILabel = {
        let label = UILabel()
        label.text = "¿Con qué podemos ayudarle hoy?"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .darkText
        label.textAlignment = .center
        
        return label
    }()
    
    let cleaningCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "cleaningCategory"), for: .normal)
        button.tintColor = UIColor.gray

        //Set button.tag to match index of category string in Constants/taskCategoriesArray
        button.tag = 0
        button.addTarget(self, action: #selector(didSelectCategory(button:)), for: .touchUpInside)

        return button
    }()
    
    let cleaningCategoryLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.TaskCategories.cleaning
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        
        return label
    }()
    
    let computerITCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "computerITCategory"), for: .normal)
        button.tintColor = UIColor.gray
        
        //Set button.tag to match index of category string in Constants/taskCategoriesArray
        button.tag = 2
        button.addTarget(self, action: #selector(didSelectCategory(button:)), for: .touchUpInside)
        
        return button
    }()
    
    let computerITCategoryLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.TaskCategories.computerIT
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        
        return label
    }()
    
    let assemblyCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "assemblyCategory"), for: .normal)
        button.tintColor = UIColor.gray
        
        //Set button.tag to match index of category string in Constants/taskCategoriesArray
        button.tag = 4
        button.addTarget(self, action: #selector(didSelectCategory(button:)), for: .touchUpInside)
        
        return button
    }()
    
    let  assemblyCategoryLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.TaskCategories.assembly
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        
        return label
    }()
    
    let movingCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "movingCategory"), for: .normal)
        button.tintColor = UIColor.gray
        
        //Set button.tag to match index of category string in Constants/taskCategoriesArray
        button.tag = 6
        button.addTarget(self, action: #selector(didSelectCategory(button:)), for: .touchUpInside)
        
        return button
    }()
    
    let movingCategoryLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.TaskCategories.moving
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        
        return label
    }()
    
    let handyManCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "handymanCategory"), for: .normal)
        button.tintColor = UIColor.gray
        
        //Set button.tag to match index of category string in Constants/taskCategoriesArray
        button.tag = 1
        button.addTarget(self, action: #selector(didSelectCategory(button:)), for: .touchUpInside)
        
        return button
    }()
    
    let handymanCategoryLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.TaskCategories.handyMan
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        
        return label
    }()
    
    let videoPhotoCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "photoVideoCategory"), for: .normal)
        button.tintColor = UIColor.gray
        
        //Set button.tag to match index of category string in Constants/taskCategoriesArray
        button.tag = 3
        button.addTarget(self, action: #selector(didSelectCategory(button:)), for: .touchUpInside)
        
        return button
    }()
    
    let videoPhotoCategoryLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.TaskCategories.photoVideo
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        
        return label
    }()
    
    let deliveryCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "deliveryCategory"), for: .normal)
        button.tintColor = UIColor.gray
        
        //Set button.tag to match index of category string in Constants/taskCategoriesArray
        button.tag = 5
        button.addTarget(self, action: #selector(didSelectCategory(button:)), for: .touchUpInside)
        
        return button
    }()
    
    let deliveryCategoryLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.TaskCategories.delivery
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        
        return label
    }()
    
    let petsCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "petsCategory"), for: .normal)
        button.tintColor = UIColor.gray
        
        //Set button.tag to match index of category string in Constants/taskCategoriesArray
        button.tag = 7
        button.addTarget(self, action: #selector(didSelectCategory(button:)), for: .touchUpInside)
        
        return button
    }()
    
    let petsCategoryLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.TaskCategories.pets
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        
        return label
    }()
    
    let anythingCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "anythingCategory"), for: .normal)
        button.tintColor = UIColor.gray
        
        //Set button.tag to match index of category string in Constants/taskCategoriesArray
        button.tag = 8
        button.addTarget(self, action: #selector(didSelectCategory(button:)), for: .touchUpInside)
        
        return button
    }()
    
    let anythingCategoryLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.TaskCategories.anything
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        
        return label
    }()
    
    // The parameter "tag" represents the index of the category in the Utilities/Constants TaskCategories struct categoryArray
    @objc fileprivate func didSelectCategory(button: UIButton) {
        let taskSpecificationsVC = TaskSpecificationsVC()
        taskSpecificationsVC.taskCategory = Constants.TaskCategories.categoryArray()[button.tag]
        
        navigationController?.pushViewController(taskSpecificationsVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupTopNavigationBar()
        setupCategoryButtons()
    }
    
    fileprivate func setupTopNavigationBar() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "Elige una Categoría"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(handleCancel))
    }
    
    @objc fileprivate func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setupCategoryButtons() {
        view.addSubview(mainLabel)
        mainLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 30)
        
        // Setup the left stackView.
        let leftVerticalStackView = UIStackView(arrangedSubviews: [cleaningCategoryButton, computerITCategoryButton, assemblyCategoryButton, movingCategoryButton])
        leftVerticalStackView.axis = .vertical
        leftVerticalStackView.distribution = .fillEqually
        leftVerticalStackView.alignment = .center
        leftVerticalStackView.spacing = 40

        view.addSubview(leftVerticalStackView)
        leftVerticalStackView.anchor(top: nil, left: nil, bottom: nil, right: view.centerXAnchor, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: -40, width: 60, height: (60 * 4) + (40 * 3))
        leftVerticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Setup the right stackView
        let rightVerticalStackView = UIStackView(arrangedSubviews: [handyManCategoryButton, videoPhotoCategoryButton, deliveryCategoryButton, petsCategoryButton])
        rightVerticalStackView.axis = .vertical
        rightVerticalStackView.distribution = .fillEqually
        rightVerticalStackView.alignment = .center
        rightVerticalStackView.spacing = 40
        
        view.addSubview(rightVerticalStackView)
        rightVerticalStackView.anchor(top: nil, left: view.centerXAnchor, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 40, paddingBottom: 0, paddingRight: 0, width: 60, height: (60 * 4) + (40 * 3))
        rightVerticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(anythingCategoryButton)
        anythingCategoryButton.anchor(top: leftVerticalStackView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        anythingCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        anythingCategoryButton.widthAnchor.constraint(equalTo: deliveryCategoryButton.widthAnchor).isActive = true
        anythingCategoryButton.heightAnchor.constraint(equalTo: deliveryCategoryButton.heightAnchor).isActive = true
        
        setupTaskCategoryTitles()
    }
    
    fileprivate func setupTaskCategoryTitles() {
        view.addSubview(cleaningCategoryLabel)
        cleaningCategoryLabel.anchor(top: cleaningCategoryButton.centerYAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        cleaningCategoryLabel.centerXAnchor.constraint(equalTo: cleaningCategoryButton.centerXAnchor).isActive = true
        
        view.addSubview(computerITCategoryLabel)
        computerITCategoryLabel.anchor(top: computerITCategoryButton.centerYAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        computerITCategoryLabel.centerXAnchor.constraint(equalTo: computerITCategoryButton.centerXAnchor).isActive = true
        
        view.addSubview(assemblyCategoryLabel)
        assemblyCategoryLabel.anchor(top: assemblyCategoryButton.centerYAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        assemblyCategoryLabel.centerXAnchor.constraint(equalTo: assemblyCategoryButton.centerXAnchor).isActive = true
        
        view.addSubview(movingCategoryLabel)
        movingCategoryLabel.anchor(top: movingCategoryButton.centerYAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        movingCategoryLabel.centerXAnchor.constraint(equalTo: movingCategoryButton.centerXAnchor).isActive = true
        
        view.addSubview(handymanCategoryLabel)
        handymanCategoryLabel.anchor(top: handyManCategoryButton.centerYAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        handymanCategoryLabel.centerXAnchor.constraint(equalTo: handyManCategoryButton.centerXAnchor).isActive = true
        
        view.addSubview(videoPhotoCategoryLabel)
        videoPhotoCategoryLabel.anchor(top: videoPhotoCategoryButton.centerYAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        videoPhotoCategoryLabel.centerXAnchor.constraint(equalTo: videoPhotoCategoryButton.centerXAnchor).isActive = true
        
        view.addSubview(deliveryCategoryLabel)
        deliveryCategoryLabel.anchor(top: deliveryCategoryButton.centerYAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        deliveryCategoryLabel.centerXAnchor.constraint(equalTo: deliveryCategoryButton.centerXAnchor).isActive = true
        
        view.addSubview(petsCategoryLabel)
        petsCategoryLabel.anchor(top: petsCategoryButton.centerYAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        petsCategoryLabel.centerXAnchor.constraint(equalTo: petsCategoryButton.centerXAnchor).isActive = true
        
        view.addSubview(anythingCategoryLabel)
        anythingCategoryLabel.anchor(top: anythingCategoryButton.centerYAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        anythingCategoryLabel.centerXAnchor.constraint(equalTo: anythingCategoryButton.centerXAnchor).isActive = true
    }
}
