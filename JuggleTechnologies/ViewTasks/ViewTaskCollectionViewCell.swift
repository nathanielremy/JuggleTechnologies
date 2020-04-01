//
//  ViewTaskCollectionViewCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-24.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

protocol ViewTaskCollectionViewCellDelegate {
    func likeTask(_ task: Task, completion: @escaping (Bool) -> Void)
    func unLikeTask(_ task: Task, completion: @escaping (Bool) -> Void)
}

class ViewTaskCollectionViewCell: UICollectionViewCell {
    //MARK: Stored properties
    var delegate: ViewTaskCollectionViewCellDelegate?
    var onGoingDelegate: OnGoingTaskCellDelegate?
    
    func fetchUser(withUserId userId: String) {
        Database.fetchUserFromUserID(userId: userId) { (usr) in
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
            
            postedTimeagoLabel.text = task.creationDate.timeAgoDisplay()
            
            taskTitleLabel.text = task.title
            taskLocationLabel.text = task.isOnline ? "Internet/Teléfono" : task.stringLocation
            taskCategoryImageView.image = setTaskCategory(forCategory: task.category)
            taskDurationLabel.text = String(task.duration) + (task.duration > 1 ? " hrs" : " hr")
            taskBudgetLabel.text = "€\(task.budget)"
            onGoingDelegate?.addJugglerOnGoingTaskToDictionary(forTask: task)
            likeTaskButton.setImage((likedTasksCache[task.id] == nil) ? #imageLiteral(resourceName: "taskUnLiked").withTintColor(UIColor.mainBlue()) : #imageLiteral(resourceName: "taskLiked").withTintColor(UIColor.mainBlue()), for: .normal)
        }
    }
    
    var taskId: String? {
        didSet {
            guard let taskId = self.taskId else {
                return
            }
            
            let taskRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).child(taskId)
            taskRef.observeSingleEvent(of: .value, with: { (taskSnapshot) in
                
                guard let taskDictionary = taskSnapshot.value as? [String : Any] else {
                    return
                }
                
                let task = Task(id: taskSnapshot.key, dictionary: taskDictionary)
                self.task = task
                
            }) { (error) in
                print("Error fetching task from taskId for Juggler onGoing tasks: \(error)")
            }
        }
    }
    
    fileprivate func setTaskCategory(forCategory category: String) -> UIImage {
        var categoryImage = #imageLiteral(resourceName: "anythingCategory")
        taskCategoryLabel.text = Constants.TaskCategories.anything
        
        if category == Constants.TaskCategories.cleaning {
            taskCategoryLabel.text = Constants.TaskCategories.cleaning
            categoryImage =  #imageLiteral(resourceName: "cleaningCategory")
        } else if category == Constants.TaskCategories.handyMan {
            taskCategoryLabel.text = Constants.TaskCategories.handyMan
            categoryImage = #imageLiteral(resourceName: "handymanCategory")
        } else if category == Constants.TaskCategories.computerIT {
            taskCategoryLabel.text = Constants.TaskCategories.computerIT
            categoryImage = #imageLiteral(resourceName: "computerITCategory")
        } else if category == Constants.TaskCategories.photoVideo {
            taskCategoryLabel.text = Constants.TaskCategories.photoVideo
            categoryImage = #imageLiteral(resourceName: "photoVideoCategory")
        }  else if category == Constants.TaskCategories.assembly {
            taskCategoryLabel.text = Constants.TaskCategories.assembly
            categoryImage = #imageLiteral(resourceName: "assemblyCategory")
        } else if category == Constants.TaskCategories.delivery {
            taskCategoryLabel.text = Constants.TaskCategories.delivery
            categoryImage = #imageLiteral(resourceName: "deliveryCategory")
        } else if category == Constants.TaskCategories.moving {
            taskCategoryLabel.text = Constants.TaskCategories.moving
            categoryImage = #imageLiteral(resourceName: "movingCategory")
        } else if category == Constants.TaskCategories.pets {
            taskCategoryLabel.text = Constants.TaskCategories.pets
            categoryImage = #imageLiteral(resourceName: "petsCategory")
        }
        
        return categoryImage.withTintColor(UIColor.gray)
    }
    
    lazy var likeTaskButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.mainBlue()
        button.addTarget(self, action: #selector(handleSaveTaskButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleSaveTaskButton() {
        guard let task = self.task else {
            return
        }
        
        if likedTasksCache[task.id] == nil {
            delegate?.likeTask(task, completion: { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.likeTaskButton.setImage(#imageLiteral(resourceName: "taskLiked").withTintColor(UIColor.mainBlue()), for: .normal)
                        return
                    }
                } else {
                    DispatchQueue.main.async {
                        self.likeTaskButton.setImage(#imageLiteral(resourceName: "taskUnLiked").withTintColor(UIColor.mainBlue()), for: .normal)
                        return
                    }
                }
            })
        } else {
            self.delegate?.unLikeTask(task, completion: { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.likeTaskButton.setImage(#imageLiteral(resourceName: "taskUnLiked").withTintColor(UIColor.mainBlue()), for: .normal)
                        return
                    }
                } else {
                    DispatchQueue.main.async {
                        self.likeTaskButton.setImage(#imageLiteral(resourceName: "taskLiked").withTintColor(UIColor.mainBlue()), for: .normal)
                        return
                    }
                }
            })
        }
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
    
    let postedTimeagoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.textColor = .gray
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
    
    let taskLocationPin: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "locationPin")
        
        return iv
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
        iv.tintColor = UIColor.gray
        
        return iv
    }()
    
    let taskCategoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor.darkText
        label.textAlignment = .center
        
        return label
    }()
    
    let taskDurationImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "taskDuration").withTintColor(UIColor.gray)
        
        
        return iv
    }()
    
    let taskDurationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor.darkText
        label.textAlignment = .center
        
        return label
    }()
    
    let taskBudgetLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = UIColor.mainBlue()
        label.textAlignment = .center
        label.numberOfLines = 0
        
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
        
        addSubview(postedTimeagoLabel)
        postedTimeagoLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 14)
        
        addSubview(taskTitleLabel)
        taskTitleLabel.anchor(top: postedTimeagoLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: -47, width: nil, height: nil)
        
        addSubview(taskLocationPin)
        taskLocationPin.anchor(top: taskTitleLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 14, height: 14)
        
        addSubview(taskLocationLabel)
        taskLocationLabel.anchor(top: taskTitleLabel.bottomAnchor, left: taskLocationPin.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 4, paddingBottom: 0, paddingRight: -20, width: nil, height: 14)
        
        addSubview(likeTaskButton)
        likeTaskButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: -20, width: 27, height: 27)
        
        let taskDetailIconsStackView = UIStackView(arrangedSubviews: [taskCategoryImageView, taskDurationImageView])
        taskDetailIconsStackView.axis = .horizontal
        taskDetailIconsStackView.distribution = .fillEqually
        taskDetailIconsStackView.spacing = 58
        
        addSubview(taskDetailIconsStackView)
        taskDetailIconsStackView.anchor(top: profileImageView.bottomAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 50, paddingBottom: -28, paddingRight: 0, width: frame.width * 0.25, height: nil)
        
        addSubview(taskCategoryLabel)
        taskCategoryLabel.anchor(top: nil, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -7, paddingRight: 0, width: nil, height: 13)
        taskCategoryLabel.centerXAnchor.constraint(equalTo: taskCategoryImageView.centerXAnchor).isActive = true
        
        addSubview(taskDurationLabel)
        taskDurationLabel.anchor(top: nil, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -7, paddingRight: 0, width: nil, height: 13)
        taskDurationLabel.centerXAnchor.constraint(equalTo: taskDurationImageView.centerXAnchor).isActive = true
        
        addSubview(taskBudgetLabel)
        taskBudgetLabel.anchor(top: taskDetailIconsStackView.topAnchor, left: taskDurationImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: -8, paddingRight: -10, width: nil, height: nil)
        
        let bottomSeperatorView = UIView()
        bottomSeperatorView.backgroundColor = .lightGray
        bottomSeperatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bottomSeperatorView)
        bottomSeperatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
    }
}
