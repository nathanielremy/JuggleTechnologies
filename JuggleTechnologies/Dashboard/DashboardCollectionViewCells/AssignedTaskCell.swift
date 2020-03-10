//
//  AssignedTaskCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-04.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

protocol AssignedTaskCellDelegate {
    func cancelOrShowDetails(forTask task: Task?, taskPartner: User?)
    func completeOrReviewTask(task: Task?, taskPartner: User?, index: Int?)
    func addAssignedTaskToDictionary(forTask task: Task)
    func loadProfile(forUser user: User)
}

class AssignedTaskCell: UICollectionViewCell {
    //MARK: Stored properties
    var delegate: AssignedTaskCellDelegate?
    var acceptedIndex: Int?
    
    var taskPartner: User? {
        didSet {
            guard let user = self.taskPartner else {
                self.profileImageView.image = nil
                return
            }
            
            self.profileImageView.image = nil
            self.firstNameLabel.text = user.firstName
            
            guard let task = self.task else {
                return
            }
            
            if task.assignedJugglerId == Auth.auth().currentUser?.uid {
                self.setupCompleteOrReviewButton(forTask: task, isTaskOwner: false)
                if task.status == 1 { // Current user accepted for other user's task
                    
                    let attributedText = NSMutableAttributedString(string: "Estas aceptado para\n\n", attributes: [.font : UIFont.boldSystemFont(ofSize: 12), .foregroundColor : UIColor.gray])
                    
                    attributedText.append(NSAttributedString(string: task.title, attributes: [.font : UIFont.boldSystemFont(ofSize: 17), .foregroundColor : UIColor.darkText]))
                    attributedText.append(NSAttributedString(string: "\n\nPor ", attributes: [.font : UIFont.boldSystemFont(ofSize: 12), .foregroundColor : UIColor.gray]))
                    attributedText.append(NSAttributedString(string: "€\(task.acceptedBudget ?? task.budget)", attributes: [.font : UIFont.boldSystemFont(ofSize: 17), .foregroundColor : UIColor.mainBlue()]))
                    
                    self.detailsLabel.attributedText = attributedText
                    
                } else if task.status == 2 { // Current user completed other user's task
                    
                    let attributedText = NSMutableAttributedString(string: "Has completado\n\n", attributes: [.font : UIFont.boldSystemFont(ofSize: 12), .foregroundColor : UIColor.gray])
                    
                    attributedText.append(NSAttributedString(string: task.title, attributes: [.font : UIFont.boldSystemFont(ofSize: 17), .foregroundColor : UIColor.darkText]))
                    attributedText.append(NSAttributedString(string: "\n\nPor ", attributes: [.font : UIFont.boldSystemFont(ofSize: 12), .foregroundColor : UIColor.gray]))
                    attributedText.append(NSAttributedString(string: "€\(task.acceptedBudget ?? task.budget)", attributes: [.font : UIFont.boldSystemFont(ofSize: 17), .foregroundColor : UIColor.mainBlue()]))
                    
                    self.detailsLabel.attributedText = attributedText
                }
            } else {
                self.setupCompleteOrReviewButton(forTask: task, isTaskOwner: true)
                if task.status == 1 { // Current user's task accepted another Juggler
                    
                    let attributedText = NSMutableAttributedString(string: user.firstName + " esta aceptado para\n\n", attributes: [.font : UIFont.boldSystemFont(ofSize: 12), .foregroundColor : UIColor.gray])
                    attributedText.append(NSAttributedString(string: task.title, attributes: [.font : UIFont.boldSystemFont(ofSize: 17), .foregroundColor : UIColor.darkText]))
                    attributedText.append(NSAttributedString(string: "\n\nPor ", attributes: [.font : UIFont.boldSystemFont(ofSize: 12), .foregroundColor : UIColor.gray]))
                    attributedText.append(NSAttributedString(string: "€\(task.acceptedBudget ?? task.budget)", attributes: [.font : UIFont.boldSystemFont(ofSize: 17), .foregroundColor : UIColor.mainBlue()]))
                    
                    self.detailsLabel.attributedText = attributedText
                    
                } else if task.status == 2 { // Current user's task completed another Juggler
                    
                    let attributedText = NSMutableAttributedString(string: user.firstName + " ha completado\n\n", attributes: [.font : UIFont.boldSystemFont(ofSize: 12), .foregroundColor : UIColor.gray])
                    attributedText.append(NSAttributedString(string: task.title, attributes: [.font : UIFont.boldSystemFont(ofSize: 17), .foregroundColor : UIColor.darkText]))
                    attributedText.append(NSAttributedString(string: "\n\nPor ", attributes: [.font : UIFont.boldSystemFont(ofSize: 12), .foregroundColor : UIColor.gray]))
                    attributedText.append(NSAttributedString(string: "€\(task.acceptedBudget ?? task.budget)", attributes: [.font : UIFont.boldSystemFont(ofSize: 17), .foregroundColor : UIColor.mainBlue()]))
                    
                    self.detailsLabel.attributedText = attributedText
                }
            }
            
            self.profileImageView.loadImage(from: user.profileImageURLString)
        }
    }
    
    fileprivate func fetchTaskPartner(forUserId userId: String) {
        Database.fetchUserFromUserID(userID: userId) { (user) in
            self.taskPartner = user
        }
    }
    
    var task: Task? {
        didSet {
            guard let task = task, let currentuserId = Auth.auth().currentUser?.uid else {
                return
            }
            
            self.delegate?.addAssignedTaskToDictionary(forTask: task)
            self.fetchTaskPartner(forUserId: task.userId == currentuserId ? (task.assignedJugglerId ?? "SINUSERID") : (task.userId))
            self.postedTimeAgoLabel.text = task.status == 1 ? task.acceptedDate.timeAgoDisplay() : task.completionDate.timeAgoDisplay()
            
            if task.status == 1 {
                self.cancelOrDetailsButton.setTitle("Cancelar", for: .normal)
                self.cancelOrDetailsButton.tintColor = UIColor.lightGray
            } else {
                self.cancelOrDetailsButton.setTitle("Detalles", for: .normal)
                self.cancelOrDetailsButton.tintColor = UIColor.mainBlue()
            }
        }
    }
    
    var taskId: String? {
        didSet {
            guard let taskId = self.taskId else {
                return
            }
            
            self.detailsLabel.attributedText = NSAttributedString(string: "")
            self.completeOrReviewButton.removeFromSuperview()
            
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
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    @objc fileprivate func handleProfileImageView() {
        guard let user = self.taskPartner, user.userId != Auth.auth().currentUser?.uid else {
            return
        }
        
        delegate?.loadProfile(forUser: user)
    }
    
    let firstNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = .darkText
        label.numberOfLines = 0
        
        return label
    }()
    
    let postedTimeAgoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.textColor = .lightGray
        label.numberOfLines = 1
        
        return label
    }()
    
    let detailsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var cancelOrDetailsButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.addTarget(self, action: #selector(handleCancelOrDetailsButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleCancelOrDetailsButton() {
        self.delegate?.cancelOrShowDetails(forTask: self.task, taskPartner: self.taskPartner)
    }
    
    lazy var completeOrReviewButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.textAlignment = .center
        button.tintColor = UIColor.mainBlue()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.addTarget(self, action: #selector(handleCompleteOrReviewButton), for: .touchUpInside)
        
        return button
    }()
    
    fileprivate func setupCompleteOrReviewButton(forTask task: Task, isTaskOwner: Bool) {
        if !isTaskOwner {
            if task.status == 1 {
                completeOrReviewButton.setTitle("Completar", for: .normal)
                completeOrReviewButton.layer.borderColor = UIColor.mainBlue().cgColor
                completeOrReviewButton.layer.borderWidth = 1.5
                completeOrReviewButton.isUserInteractionEnabled = true
            } else if task.status == 2 {
                if task.isJugglerReviewed {
                    completeOrReviewButton.setTitle("Evaluado", for: .normal)
                    completeOrReviewButton.layer.borderColor = nil
                    completeOrReviewButton.layer.borderWidth = 0
                    completeOrReviewButton.isUserInteractionEnabled = false
                } else {
                    completeOrReviewButton.setTitle("Evaluar", for: .normal)
                    completeOrReviewButton.layer.borderColor = UIColor.mainBlue().cgColor
                    completeOrReviewButton.layer.borderWidth = 1.5
                    completeOrReviewButton.isUserInteractionEnabled = true
                }
            }
        } else {
            if task.status == 1 {
                self.completeOrReviewButton.removeFromSuperview()
                return
            } else if task.status == 2 {
                if task.isUserReviewed {
                    completeOrReviewButton.setTitle("Evaluado", for: .normal)
                    completeOrReviewButton.layer.borderColor = nil
                    completeOrReviewButton.layer.borderWidth = 0
                    completeOrReviewButton.isUserInteractionEnabled = false
                } else {
                    completeOrReviewButton.setTitle("Evaluar", for: .normal)
                    completeOrReviewButton.layer.borderColor = UIColor.mainBlue().cgColor
                    completeOrReviewButton.layer.borderWidth = 1.5
                    completeOrReviewButton.isUserInteractionEnabled = true
                }
            }
        }
        
        addSubview(completeOrReviewButton)
        completeOrReviewButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: -20, width: 100, height: 20)
        completeOrReviewButton.layer.cornerRadius = 5
    }
    
    @objc fileprivate func handleCompleteOrReviewButton() {
        delegate?.completeOrReviewTask(task: self.task, taskPartner: self.taskPartner, index: self.acceptedIndex ?? 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        self.profileImageView.image = nil
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
        
        addSubview(postedTimeAgoLabel)
        postedTimeAgoLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 14)
        
        addSubview(cancelOrDetailsButton)
        cancelOrDetailsButton.anchor(top: nil, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        addSubview(detailsLabel)
        detailsLabel.anchor(top: postedTimeAgoLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: cancelOrDetailsButton.leftAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: -8, width: nil, height: nil)
        
        let profileImageButton = UIButton(type: .system)
        profileImageButton.addTarget(self, action: #selector(handleProfileImageView), for: .touchUpInside)
        addSubview(profileImageButton)
        profileImageButton.anchor(top: profileImageView.topAnchor, left: profileImageView.leftAnchor, bottom: profileImageView.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        
        let bottomSeperatorView = UIView()
        bottomSeperatorView.backgroundColor = .lightGray
        bottomSeperatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bottomSeperatorView)
        bottomSeperatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
    }
}
