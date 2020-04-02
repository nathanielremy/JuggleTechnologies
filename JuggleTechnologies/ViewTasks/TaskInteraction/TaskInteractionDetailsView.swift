//
//  TaskInteractionDetailsView.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-27.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit

protocol TaskInteractionDetailsViewDelegate {
    func showTaskDetailsVC(forUser user: User?)
    func hideTaskInteractionDetailsView(andScroll scroll: Bool, keyBoardHeight: CGFloat)
    func makeOffer()
    func acceptTask()
    func handleProfileImageView(forUser user: User)
    func editOffer(forTask task: Task?)
    func cancelOffer(forTask task: Task?)
}

class TaskInteractionDetailsView: UIView {
    //MARK: Stored properties
    var delegate: TaskInteractionDetailsViewDelegate?
    
    var currentJugglerOffer: Offer? {
        didSet {
            guard let offer = self.currentJugglerOffer else {
                DispatchQueue.main.async {
                    self.makeOfferButton.tintColor = UIColor.mainBlue()
                    self.makeOfferButton.layer.borderColor = UIColor.mainBlue().cgColor
                    self.makeOfferButton.setTitle("Haz Oferta", for: .normal)
                    
                    self.acceptTaskButton.tintColor = UIColor.mainBlue()
                    self.acceptTaskButton.layer.borderColor = UIColor.mainBlue().cgColor
                    self.acceptTaskButton.setTitle("Aceptar Tarea", for: .normal)
                }
                return
            }
            
            DispatchQueue.main.async {
                self.makeOfferButton.tintColor = UIColor.lightGray
                self.makeOfferButton.layer.borderColor = UIColor.lightGray.cgColor
                self.makeOfferButton.setTitle("Cancelar Oferta", for: .normal)
                
                self.acceptTaskButton.tintColor = UIColor.lightGray
                self.acceptTaskButton.layer.borderColor = UIColor.lightGray.cgColor
                self.acceptTaskButton.setTitle("Editar Oferta de €\(offer.offerPrice)", for: .normal)
            }
        }
    }
    
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
            
            postedTimeAgoLabel.text = task.creationDate.timeAgoDisplay()
            
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
    
    @objc fileprivate func handleProfileImageView() {
        guard let user = self.user else {
            return
        }
        
        delegate?.handleProfileImageView(forUser: user)
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
    
    lazy var moreDetailsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Más detalles", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.tintColor = UIColor.mainBlue()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.addTarget(self, action: #selector(handleMoreDetailsButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleMoreDetailsButton() {
        delegate?.showTaskDetailsVC(forUser: self.user)
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
        
        addSubview(postedTimeAgoLabel)
        postedTimeAgoLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 14)
        
        addSubview(taskTitleLabel)
        taskTitleLabel.anchor(top: postedTimeAgoLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        addSubview(taskLocationPin)
        taskLocationPin.anchor(top: taskTitleLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 14, height: 14)
        
        addSubview(taskLocationLabel)
        taskLocationLabel.anchor(top: taskTitleLabel.bottomAnchor, left: taskLocationPin.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 4, paddingBottom: 0, paddingRight: -20, width: nil, height: 14)
        
        let sectionSeperatorView = UIView()
        sectionSeperatorView.backgroundColor = .lightGray
        
        addSubview(sectionSeperatorView)
        sectionSeperatorView.anchor(top: nil, left: leftAnchor, bottom: topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 175, paddingRight: -20, width: nil, height: 0.5)
        
        addSubview(taskCategoryLabel)
        taskCategoryLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: sectionSeperatorView.topAnchor, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: -7, paddingRight: 0, width: nil, height: 13)
        
        addSubview(taskCategoryImageView)
        taskCategoryImageView.anchor(top: nil, left: nil, bottom: taskCategoryLabel.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 0, width: 20, height: 22)
        taskCategoryImageView.centerXAnchor.constraint(equalTo: taskCategoryLabel.centerXAnchor).isActive = true
        
        addSubview(moreDetailsButton)
        moreDetailsButton.anchor(top: nil, left: nil, bottom: sectionSeperatorView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        //Add button over profileImageView to view user's profile
        let button = UIButton()
        button.backgroundColor = nil
        addSubview(button)
        button.anchor(top: profileImageView.topAnchor, left: profileImageView.leftAnchor, bottom: profileImageView.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        button.addTarget(self, action: #selector(handleProfileImageView), for: .touchUpInside)
        
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
        button.setTitle("Haz Oferta", for: .normal)
        button.tintColor = UIColor.mainBlue()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.mainBlue().cgColor
        button.addTarget(self, action: #selector(handleMakeOfferButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleMakeOfferButton() {
        if self.currentJugglerOffer != nil {
            delegate?.cancelOffer(forTask: self.task)
        } else {
            delegate?.makeOffer()
        }
    }
    
    lazy var acceptTaskButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Aceptar Tarea", for: .normal)
        button.tintColor = UIColor.mainBlue()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.mainBlue().cgColor
        button.addTarget(self, action: #selector(handleAcceptTaskButton), for: .touchUpInside)
        button.titleLabel?.numberOfLines = 0
        
        return button
    }()
    
    @objc fileprivate func handleAcceptTaskButton() {
        if self.currentJugglerOffer != nil {
            delegate?.editOffer(forTask: self.task)
        } else {
            delegate?.acceptTask()
        }
    }
    
    lazy var hideDetailsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ocultar", for: .normal)
        button.tintColor = UIColor.lightGray
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(handleHideDetailsButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleHideDetailsButton() {
        delegate?.hideTaskInteractionDetailsView(andScroll: true, keyBoardHeight: 0)
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
        hideDetailsButton.anchor(top: nil, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        let sectionEndingSeperatorView = UIView()
        sectionEndingSeperatorView.backgroundColor = .darkText
        
        addSubview(sectionEndingSeperatorView)
        sectionEndingSeperatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
    }
}
