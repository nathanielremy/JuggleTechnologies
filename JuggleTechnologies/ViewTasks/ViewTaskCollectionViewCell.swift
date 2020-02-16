//
//  ViewTaskCollectionViewCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-24.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class ViewTaskCollectionViewCell: UICollectionViewCell {
    
    //MARK: Stored properties
    func fetchUser(withUserId userId: String) {
        Database.fetchUserFromUserID(userID: userId) { (usr) in
            guard let user = usr else {
                return
            }
            
            self.firstNameLabel.text = user.firstName
            DispatchQueue.main.async {
                self.profileImageView.loadImage(from: user.profileImageURLString)
            }
        }
    }
    
    var task: Task? {
        didSet {
            guard let task = task else {
                return
            }
            fetchUser(withUserId: task.userId)
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.locale = Locale(identifier: "es_ES")
            dateFormatterPrint.dateFormat = "dd, MMM, yyyy"
            postedDateLabel.text = dateFormatterPrint.string(from: task.creationDate)
            
            taskTitleLabel.text = task.title
            taskLocationLabel.text = task.isOnline ? "Internet/Teléfono" : task.stringLocation
            taskCategoryImageView.image = setTaskCategory(forCategory: task.category)
            taskDurationLabel.text = String(task.duration) + (task.duration > 1 ? " hrs" : " hr")
            taskBudgetLabel.text = "€\(task.budget)"
        }
    }
    
    fileprivate func setTaskCategory(forCategory category: String) -> UIImage {
        if category == Constants.TaskCategories.cleaning {
            taskCategoryLabel.text = Constants.TaskCategories.cleaning
            return #imageLiteral(resourceName: "CleaningPH")
        } else if category == Constants.TaskCategories.handyMan {
            taskCategoryLabel.text = Constants.TaskCategories.handyMan
            return #imageLiteral(resourceName: "HandymanPH")
        } else if category == Constants.TaskCategories.computerIT {
            taskCategoryLabel.text = Constants.TaskCategories.computerIT
            return #imageLiteral(resourceName: "ComputerITPH")
        } else if category == Constants.TaskCategories.photoVideo {
            taskCategoryLabel.text = Constants.TaskCategories.photoVideo
            return #imageLiteral(resourceName: "PhotoVideoPH")
        }  else if category == Constants.TaskCategories.assembly {
            taskCategoryLabel.text = Constants.TaskCategories.assembly
            return #imageLiteral(resourceName: "AssemblyPH")
        } else if category == Constants.TaskCategories.delivery {
            taskCategoryLabel.text = Constants.TaskCategories.delivery
            return #imageLiteral(resourceName: "DeliveryPH")
        } else if category == Constants.TaskCategories.moving {
            taskCategoryLabel.text = Constants.TaskCategories.moving
            return #imageLiteral(resourceName: "MovingPH")
        } else if category == Constants.TaskCategories.pets {
            taskCategoryLabel.text = Constants.TaskCategories.pets
            return #imageLiteral(resourceName: "DeliveryPH")
        } else {
            taskCategoryLabel.text = Constants.TaskCategories.anything
            return #imageLiteral(resourceName: "AnythingPH")
        }
    }
    
    lazy var saveTaskButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .red
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
        
        return label
    }()
    
    let postedDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.textColor = .lightGray
        label.numberOfLines = 1
        
        return label
    }()
    
    let taskTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = .darkText
        label.numberOfLines = 2
        
        return label
    }()
    
    let taskLocationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.textColor = .darkText
        label.numberOfLines = 1
        
        return label
    }()
    
    let taskCategoryImageView: UIImageView = {
        let iv = UIImageView()
        
        return iv
    }()
    
    let taskCategoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkText
        label.textAlignment = .center
        
        return label
    }()
    
    let taskDurationImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "SettingsGearPH")
        
        return iv
    }()
    
    let taskDurationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkText
        label.textAlignment = .center
        
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
        label.textColor = UIColor.darkText
        label.textAlignment = .center
        
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
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 60, height: 60)
        profileImageView.layer.cornerRadius = 60 / 2
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(firstNameLabel)
        firstNameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: profileImageView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 12, width: nil, height: nil)
        
        addSubview(postedDateLabel)
        postedDateLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 14)
        
        addSubview(taskTitleLabel)
        taskTitleLabel.anchor(top: postedDateLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        addSubview(taskLocationLabel)
        taskLocationLabel.anchor(top: taskTitleLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 14)
        
        addSubview(saveTaskButton)
        saveTaskButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: -8, width: 20, height: 20)
        saveTaskButton.layer.cornerRadius = 10
        
        let taskDetailIconsStackView = UIStackView(arrangedSubviews: [taskCategoryImageView, taskDurationImageView, taskBudgetImageView])
        taskDetailIconsStackView.axis = .horizontal
        taskDetailIconsStackView.distribution = .fillEqually
        taskDetailIconsStackView.spacing = 50
        
        addSubview(taskDetailIconsStackView)
        taskDetailIconsStackView.anchor(top: nil, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 50, paddingBottom: -28, paddingRight: -50, width: nil, height: 30)
        
        addSubview(taskCategoryLabel)
        taskCategoryLabel.anchor(top: nil, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 0, width: nil, height: 12)
        taskCategoryLabel.centerXAnchor.constraint(equalTo: taskCategoryImageView.centerXAnchor).isActive = true
        
        addSubview(taskDurationLabel)
        taskDurationLabel.anchor(top: nil, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 0, width: nil, height: 12)
        taskDurationLabel.centerXAnchor.constraint(equalTo: taskDurationImageView.centerXAnchor).isActive = true
        
        addSubview(taskBudgetLabel)
        taskBudgetLabel.anchor(top: nil, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 0, width: nil, height: 12)
        taskBudgetLabel.centerXAnchor.constraint(equalTo: taskBudgetImageView.centerXAnchor).isActive = true
        
        let bottomSeperatorView = UIView()
        bottomSeperatorView.backgroundColor = .lightGray
        bottomSeperatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bottomSeperatorView)
        bottomSeperatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
    }
}
