//
//  OnGoingTaskCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-04.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class OnGoingTaskCell: UICollectionViewCell {
    //MARK: Stores properties
    var messages = [Message]()
    var offers = [Offer]()
    
    func fetchUser(withUserId userId: String) {
        Database.fetchUserFromUserID(userID: userId) { (usr) in
            guard let user = usr else {
                return
            }
            self.profileImageView.loadImage(from: user.profileImageURLString)
            self.firstNameLabel.text = user.firstName
        }
    }
    
    var taskId: String? {
        didSet {
            guard let taskId = self.taskId else {
                return
            }
            
            self.notificationsLabel.removeFromSuperview()
            self.messages.removeAll()
            self.offers.removeAll()
            
            let taskRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).child(taskId)
            taskRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String : Any] else {
                    return
                }
                
                let task = Task(id: snapshot.key, dictionary: dictionary)
                self.task = task
                
            }) { (error) in
                print(error)
                return
            }
        }
    }
    
    var task: Task? {
        didSet {
            guard let task = task else {
                return
            }
            
            //fetchOffer function definition under init
            self.fetchOffers(forTask: task)
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.locale = Locale(identifier: "es_ES")
            dateFormatterPrint.dateFormat = "dd, MMM, yyyy"
            postedDateLabel.text = dateFormatterPrint.string(from: task.creationDate)
            
            fetchUser(withUserId: task.userId)
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
    
    let notificationsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor.mainBlue()
        
        return label
    }()
    
    fileprivate func setupNotificationsLabel() {
        addSubview(notificationsLabel)
        notificationsLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 15)
        notificationsLabel.backgroundColor = UIColor.darkText
        notificationsLabel.text = "\(self.offers.count) oferta\(self.offers.count > 1 ? "s" : "") y \(self.messages.count) mensaje\(self.messages.count == 1 ? "" : "s")"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func fetchOffers(forTask task: Task) {
        let taskOffersRef = Database.database().reference().child(Constants.FirebaseDatabase.taskOffersRef).child(task.id)
        taskOffersRef.observeSingleEvent(of: .value, with: { (offersSnapshot) in
            guard let offers = offersSnapshot.value as? [String : [String : Any]] else {
                return
            }
            
            var offersCreated = 0
            offers.forEach { (key, value) in
                let offer = Offer(offerDictionary: value)
                offersCreated += 1
                self.offers.append(offer)
                
                self.offers.sort(by: { (offer1, offer2) -> Bool in
                    return offer1.creationDate.compare(offer2.creationDate) == .orderedDescending
                })
                
                if offersCreated == offers.count {
                    self.setupNotificationsLabel()
                }
            }
        }) { (error) in
            print("Error fetching offers for \(task.id): \(error)")
        }
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
        
        let taskDetailIconsStackView = UIStackView(arrangedSubviews: [taskCategoryImageView, taskDurationImageView, taskBudgetImageView])
        taskDetailIconsStackView.axis = .horizontal
        taskDetailIconsStackView.distribution = .fillEqually
        taskDetailIconsStackView.spacing = 50
        
        addSubview(taskDetailIconsStackView)
        taskDetailIconsStackView.anchor(top: nil, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 50, paddingBottom: -43, paddingRight: -50, width: nil, height: 30)
        
        addSubview(taskCategoryLabel)
        taskCategoryLabel.anchor(top: nil, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -23, paddingRight: 0, width: nil, height: 12)
        taskCategoryLabel.centerXAnchor.constraint(equalTo: taskCategoryImageView.centerXAnchor).isActive = true
        
        addSubview(taskDurationLabel)
        taskDurationLabel.anchor(top: nil, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -23, paddingRight: 0, width: nil, height: 12)
        taskDurationLabel.centerXAnchor.constraint(equalTo: taskDurationImageView.centerXAnchor).isActive = true
        
        addSubview(taskBudgetLabel)
        taskBudgetLabel.anchor(top: nil, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -23, paddingRight: 0, width: nil, height: 12)
        taskBudgetLabel.centerXAnchor.constraint(equalTo: taskBudgetImageView.centerXAnchor).isActive = true
        
        let bottomSeperatorView = UIView()
        bottomSeperatorView.backgroundColor = .lightGray
        bottomSeperatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bottomSeperatorView)
        bottomSeperatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
    }
}
