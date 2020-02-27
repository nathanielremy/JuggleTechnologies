//
//  OnGoingTaskCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-04.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

protocol OnGoingTaskCellDelegate {
    func addUserOnGoingTaskToDictionary(forTask task: Task)
    func addJugglerOnGoingTaskToDictionary(forTask task: Task)
}

class OnGoingTaskCell: UICollectionViewCell {
    //MARK: Stores properties
    var delegate: OnGoingTaskCellDelegate?
    var offers = [Offer]()
    var messages = [String : [String : Any]]()
    
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
            
            //fetchOffer function definition under init.
            self.fetchOffers(forTask: task)
            //fetchMessages function definition under fetchOffer.
            self.fetchMessages(forTask: task)
            
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
            delegate?.addUserOnGoingTaskToDictionary(forTask: task)
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
    
    let notificationsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.backgroundColor = UIColor.mainBlue()
        label.textColor = .darkText
        
        return label
    }()
    
    fileprivate func setupNotificationsLabel() {
        DispatchQueue.main.async {
            let offersCount = self.offers.count
            let messagesCount = self.messages.count
            
            var notificationsText = ""
            
            if offersCount > 0 {
                notificationsText += "\(offersCount) oferta\(offersCount > 1 ? "s" : "")"
            }
            
            if messagesCount > 0 {
                notificationsText += offersCount > 0 ? " y" : ""
                notificationsText += " \(messagesCount) mensaje\(messagesCount == 1 ? "" : "s")"
            }
            
            self.notificationsLabel.text = notificationsText
            
            if self.messages.count == 0 && self.offers.count == 0 {
                self.notificationsLabel.removeFromSuperview()
                return
            }
            
            self.addSubview(self.notificationsLabel)
            self.notificationsLabel.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        }
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
                self.offers.removeAll()
                self.setupNotificationsLabel()
                return
            }
            
            self.offers.removeAll()
            DispatchQueue.main.async {
                self.notificationsLabel.removeFromSuperview()
            }
            var offersCreated = 0
            offers.forEach { (key, value) in
                let offer = Offer(offerDictionary: value)
                offersCreated += 1
                
                if !offer.isOfferRejected && !offer.isOfferAccepted {
                    self.offers.append(offer)
                }
                
                self.offers.sort(by: { (offer1, offer2) -> Bool in
                    return offer1.creationDate.compare(offer2.creationDate) == .orderedDescending
                })
                
                if offersCreated == offers.count {
                    self.setupNotificationsLabel()
                }
            }
        }) { (error) in
            self.offers.removeAll()
            DispatchQueue.main.async {
                self.notificationsLabel.removeFromSuperview()
            }
            print("Error fetching offers for \(task.id): \(error)")
        }
    }
    
    fileprivate func fetchMessages(forTask task: Task) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.messages.removeAll()
            DispatchQueue.main.async {
                self.notificationsLabel.removeFromSuperview()
            }
            return
        }
        
        let messagesRef = Database.database().reference().child(Constants.FirebaseDatabase.userMessagesRef).child(currentUserId).child(task.id)
        messagesRef.observeSingleEvent(of: .value, with: { (messagesSnapshot) in
            guard let messagesDictionary = messagesSnapshot.value as? [String : [String : Int]] else {
                self.messages.removeAll()
                self.setupNotificationsLabel()
                return
            }
            
            self.messages.removeAll()
            DispatchQueue.main.async {
                self.notificationsLabel.removeFromSuperview()
            }
            var messagesCreated = 0
            messagesDictionary.forEach { (key, value) in
                self.messages[key] = value
                messagesCreated += 1
                
                if messagesCreated == messagesDictionary.count {
                    self.setupNotificationsLabel()
                }
            }
        }) { (error) in
            self.messages.removeAll()
            DispatchQueue.main.async {
                self.notificationsLabel.removeFromSuperview()
            }
            print("Error fetching messages for \(task.id): \(error)")
        }
    }
    
    fileprivate func setupViews() {
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 60, height: 60)
        profileImageView.layer.cornerRadius = 60 / 2
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20).isActive = true
        
        addSubview(firstNameLabel)
        firstNameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: profileImageView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 12, width: nil, height: nil)
        
        addSubview(postedDateLabel)
        postedDateLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 14)
        
        addSubview(taskTitleLabel)
        taskTitleLabel.anchor(top: postedDateLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        addSubview(taskLocationPin)
        taskLocationPin.anchor(top: taskTitleLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 14, height: 14)
        
        addSubview(taskLocationLabel)
        taskLocationLabel.anchor(top: taskTitleLabel.bottomAnchor, left: taskLocationPin.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 4, paddingBottom: 0, paddingRight: -20, width: nil, height: 14)
        
        let taskDetailIconsStackView = UIStackView(arrangedSubviews: [taskCategoryImageView, taskDurationImageView])
        taskDetailIconsStackView.axis = .horizontal
        taskDetailIconsStackView.distribution = .fillEqually
        taskDetailIconsStackView.spacing = 58
        
        addSubview(taskDetailIconsStackView)
        taskDetailIconsStackView.anchor(top: profileImageView.bottomAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 18, paddingLeft: 50, paddingBottom: -48, paddingRight: 0, width: frame.width * 0.25, height: nil)
        
        addSubview(taskCategoryLabel)
        taskCategoryLabel.anchor(top: nil, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -27, paddingRight: 0, width: nil, height: 13)
        taskCategoryLabel.centerXAnchor.constraint(equalTo: taskCategoryImageView.centerXAnchor).isActive = true
        
        addSubview(taskDurationLabel)
        taskDurationLabel.anchor(top: nil, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -27, paddingRight: 0, width: nil, height: 13)
        taskDurationLabel.centerXAnchor.constraint(equalTo: taskDurationImageView.centerXAnchor).isActive = true
        
        addSubview(taskBudgetLabel)
        taskBudgetLabel.anchor(top: taskDetailIconsStackView.topAnchor, left: taskDurationImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: -28, paddingRight: -10, width: nil, height: nil)
        
        let bottomSeperatorView = UIView()
        bottomSeperatorView.backgroundColor = .lightGray
        bottomSeperatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bottomSeperatorView)
        bottomSeperatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
    }
}
