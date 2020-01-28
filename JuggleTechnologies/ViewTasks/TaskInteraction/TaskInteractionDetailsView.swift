//
//  TaskInteractionDetailsView.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-27.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit

class TaskInteractionDetailsView: UIView {
    //MARK: Stored properties
    var user: User? {
        didSet {
            guard let user = self.user else {
                self.profileImageView.image = #imageLiteral(resourceName: "DefaultProfileImage")
                self.firstNameLabel.text = "Sin nombre"
                return
            }
            
            self.profileImageView.loadImage(from: user.profileImageURLString)
            self.firstNameLabel.text = user.firstName
        }
    }
    
    var task: Task? {
        didSet {
            guard let task = task else {
                return
            }
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.locale = Locale(identifier: "es_ES")
            dateFormatterPrint.dateFormat = "dd, MMM, yyyy"
            postedDateLabel.text = dateFormatterPrint.string(from: task.creationDate)
            
            taskTitleLabel.text = task.title
            taskLocationLabel.text = task.isOnline ? "Internet/Teléfono" : task.stringLocation
            taskCategoryImageView.image = setTaskCategory(forCategory: task.category)
            
            let taskDurationAttributedText = NSMutableAttributedString(string: "Duración\n", attributes: [.foregroundColor : UIColor.lightGray, .font : UIFont.systemFont(ofSize: 12)])
            taskDurationAttributedText.append(NSAttributedString(string: String(task.duration) + (task.duration > 1 ? " hrs" : " hr"), attributes: [.foregroundColor : UIColor.darkText, .font : UIFont.boldSystemFont(ofSize: 16)]))
            
            let taskBudgetAttributedText = NSMutableAttributedString(string: "Gana\n", attributes: [.foregroundColor : UIColor.lightGray, .font : UIFont.systemFont(ofSize: 12)])
            taskBudgetAttributedText.append(NSAttributedString(string: "€\(task.budget)", attributes: [.foregroundColor : UIColor.darkText, .font : UIFont.boldSystemFont(ofSize: 16)]))
            
            taskDurationLabel.attributedText = taskDurationAttributedText
            taskBudgetLabel.attributedText = taskBudgetAttributedText
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
    
    lazy var moreDetailsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Más detalles", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.tintColor = .darkText
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.addTarget(self, action: #selector(handleMoreDetailsButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleMoreDetailsButton() {
        print("Handling moreDetailsButton")
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
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 60, height: 60)
        profileImageView.layer.cornerRadius = 60 / 2
        profileImageView.centerYAnchor.constraint(equalTo: topAnchor, constant: 175 / 2).isActive = true
        
        addSubview(firstNameLabel)
        firstNameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: profileImageView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 12, width: nil, height: nil)
        
        addSubview(postedDateLabel)
        postedDateLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 14)
        
        addSubview(taskTitleLabel)
        taskTitleLabel.anchor(top: postedDateLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        addSubview(taskLocationLabel)
        taskLocationLabel.anchor(top: taskTitleLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 14)
        
        let sectionSeperatorView = UIView()
        sectionSeperatorView.backgroundColor = .lightGray
        
        addSubview(sectionSeperatorView)
        sectionSeperatorView.anchor(top: nil, left: leftAnchor, bottom: topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 175, paddingRight: -20, width: nil, height: 0.5)
        
        addSubview(taskCategoryLabel)
        taskCategoryLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: sectionSeperatorView.topAnchor, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: -8, paddingRight: 0, width: nil, height: 12)
        
        addSubview(taskCategoryImageView)
        taskCategoryImageView.anchor(top: nil, left: nil, bottom: taskCategoryLabel.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 0, width: 30, height: 30)
        taskCategoryImageView.centerXAnchor.constraint(equalTo: taskCategoryLabel.centerXAnchor).isActive = true
        
        addSubview(moreDetailsButton)
        moreDetailsButton.anchor(top: nil, left: nil, bottom: sectionSeperatorView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: -20, width: nil, height: 12)
        
        setupBottomSectionViews()
    }
    
    let taskDurationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        
        return label
    }()
    
    let taskBudgetLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        
        return label
    }()
    
    lazy var makeOfferButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.darkText
        button.setTitle("Haz una Oferta", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(handleMakeOfferButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleMakeOfferButton() {
        print("Handling makeOfferButton")
    }
    
    lazy var acceptTaskButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.darkText
        button.setTitle("Aceptar Tarea", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(handleAcceptTaskButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleAcceptTaskButton() {
        print("Handling acceptTaskButton")
    }
    
    lazy var hideDetailsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ocultar los detalles", for: .normal)
        button.tintColor = UIColor.darkText
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(handleHideDetailsButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleHideDetailsButton() {
        print("handling hideDetailsButton")
    }
    
    fileprivate func setupBottomSectionViews() {
        let durationBudgetStackView = UIStackView(arrangedSubviews: [taskDurationLabel, taskBudgetLabel])
        durationBudgetStackView.axis = .horizontal
        durationBudgetStackView.distribution = .fillEqually
        durationBudgetStackView.spacing = 30
        
        addSubview(durationBudgetStackView)
        durationBudgetStackView.anchor(top: moreDetailsButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        durationBudgetStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        let offerAcceptStackView = UIStackView(arrangedSubviews: [makeOfferButton, acceptTaskButton])
        offerAcceptStackView.axis = .horizontal
        offerAcceptStackView.distribution = .fillEqually
        offerAcceptStackView.spacing = 8
        
        addSubview(offerAcceptStackView)
        offerAcceptStackView.anchor(top: durationBudgetStackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 35)
        
        makeOfferButton.layer.cornerRadius = 5
        acceptTaskButton.layer.cornerRadius = 5
        
        addSubview(hideDetailsButton)
        hideDetailsButton.anchor(top: nil, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: -20, width: nil, height: 12)
        
        let sectionEndingSeperatorView = UIView()
        sectionEndingSeperatorView.backgroundColor = .darkText
        
        addSubview(sectionEndingSeperatorView)
        sectionEndingSeperatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
    }
}
