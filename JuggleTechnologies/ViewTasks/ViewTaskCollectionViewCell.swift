//
//  ViewTaskCollectionViewCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-24.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit

class ViewTaskCollectionViewCell: UICollectionViewCell {
    
    //MARK: Stores properties
    lazy var saveTaskButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .red
//        button.setImage(#imageLiteral(resourceName: "NotificationsPH"), for: .normal)
//        button.clipsToBounds = true
//        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handleSaveTaskButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleSaveTaskButton() {
        print("Handeling saveTaskButton")
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    let firstNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = .darkText
        label.numberOfLines = 0
        
        label.text = "Nathaniel Remy"
        
        return label
    }()
    
    let postedDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.textColor = .lightGray
        
        label.text = "18, ene, 2020"
        
        return label
    }()
    
    let taskTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = .darkText
        label.numberOfLines = 2
        
        label.text = "I need someone to walk my dog to the park"
        
        return label
    }()
    
    let taskLocationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.textColor = .darkText
        
        label.text = "Carrer de Sant Miquel, 14, 08003, Barcelona, España"
        
        return label
    }()
    
    let taskCategoryImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "CleaningPH")
        
        return iv
    }()
    
    let taskCategoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        label.textAlignment = .center
        
        label.text = "Pets"
        
        return label
    }()
    
    let taskDurationImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "SettingsGearPH")
        
        return iv
    }()
    
    let taskDuracionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        label.textAlignment = .center
        
        label.text = "1hr"
        
        return label
    }()
    
    let taskBudgetImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "DeliveryPH")
        
        return iv
    }()
    
    let taskBudgetLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        label.textAlignment = .center
        
        label.text = "€32"
        
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
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 60, height: 60)
        profileImageView.layer.cornerRadius = 60 / 2
        
        addSubview(saveTaskButton)
        saveTaskButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: -8, width: 20, height: 20)
        
        addSubview(firstNameLabel)
        firstNameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: profileImageView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: -8, paddingRight: 12, width: nil, height: nil)
        
        addSubview(postedDateLabel)
        postedDateLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 12)
        
        addSubview(taskTitleLabel)
        taskTitleLabel.anchor(top: postedDateLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        addSubview(taskLocationLabel)
        taskLocationLabel.anchor(top: taskTitleLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 12)
        
        addSubview(saveTaskButton)
        saveTaskButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: -8, width: 35, height: 35)
        saveTaskButton.layer.cornerRadius = 10
        
        let taskDetailIconsStackView = UIStackView(arrangedSubviews: [taskCategoryImageView, taskDurationImageView, taskBudgetImageView])
        taskDetailIconsStackView.axis = .horizontal
        taskDetailIconsStackView.distribution = .fillEqually
        taskDetailIconsStackView.spacing = 50
        
        addSubview(taskDetailIconsStackView)
        taskDetailIconsStackView.anchor(top: taskLocationLabel.bottomAnchor
            , left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: -40, width: nil, height: 35)
        
        let bottomSeperatorView = UIView()
        bottomSeperatorView.backgroundColor = .lightGray
        bottomSeperatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bottomSeperatorView)
        bottomSeperatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
    }
}
