//
//  TaskDetailsVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-29.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit

class TaskDetailsVC: UIViewController {
    //MARK: Stored properties
    var task: Task? {
        didSet {
            guard let task = self.task else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            
            self.navigationItem.title = task.title
            self.taskTitleLabel.attributedText = setupAttributedText(withTitle: "Titulo", value: task.title)
            self.taskDescriptionTextView.text = task.description
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.locale = Locale(identifier: "es_ES")
            dateFormatterPrint.dateFormat = "dd, MMM, yyyy"
            
            self.timePostedLabel.attributedText = setupAttributedText(withTitle: "Publicado Hace", value: "\(task.creationDate.timeAgoDisplay()) el \(dateFormatterPrint.string(from: task.creationDate))")
            
            taskDurationLabel.attributedText = setupAttributedText(withTitle: "Duración Estimada", value: "\(task.duration)\(task.duration > 1 ? " hrs" : " hr")")
        }
    }
    
    fileprivate func setupAttributedText(withTitle title: String, value: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: title, attributes: [.foregroundColor : UIColor.darkText, .font : UIFont.boldSystemFont(ofSize: 14)])
        attributedString.append(NSAttributedString(string: "\n" + value, attributes: [.foregroundColor : UIColor.darkText, .font : UIFont.systemFont(ofSize: 14)]))
        
        return attributedString
    }
    
    var user: User? {
        didSet {
            guard let user = user else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            
            self.profileImageView.loadImage(from: user.profileImageURLString)
            self.fullNameLabel.text = user.firstName + " " + user.lastName
        }
    }
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.backgroundColor = .white
        
        return sv
    }()
    
    let profileImageView: CustomImageView = {
        let image = CustomImageView()
        image.backgroundColor = .lightGray
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.layer.borderColor = UIColor.darkText.cgColor
        image.layer.borderWidth = 1.5
        
        return image
    }()
    
    let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        label.textAlignment = .center
        
        return label
    }()
    
    let taskTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()
    
    let taskDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Descripción"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        label.textAlignment = .left
        
        return label
    }()
    
    let taskDescriptionTextView: UITextView = {
        let tv = UITextView()
        tv.textColor = UIColor.darkText
        tv.tintColor = .darkText
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.isScrollEnabled = true
        tv.bounces = true
        tv.isEditable = false
        tv.layer.borderWidth = 0.5
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.masksToBounds = true
        
        return tv
    }()
    
    let timePostedLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()
    
    let taskDurationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
    }
    
    fileprivate func setupViews() {
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        scrollView.contentSize = CGSize(width: view.frame.width, height: 1110)
        
        scrollView.addSubview(profileImageView)
        profileImageView.anchor(top: scrollView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        profileImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        profileImageView.layer.cornerRadius = 100/2
        
        scrollView.addSubview(fullNameLabel)
        fullNameLabel.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        let sectionSeperatorView = UIView()
        sectionSeperatorView.backgroundColor = .lightGray
        scrollView.addSubview(sectionSeperatorView)
        sectionSeperatorView.anchor(top: fullNameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 0.5)
        
        scrollView.addSubview(taskTitleLabel)
        taskTitleLabel.anchor(top: sectionSeperatorView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        scrollView.addSubview(taskDescriptionLabel)
        taskDescriptionLabel.anchor(top: taskTitleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 14)
        
        scrollView.addSubview(taskDescriptionTextView)
        taskDescriptionTextView.anchor(top: taskDescriptionLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 4, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 100)
        taskDescriptionTextView.layer.cornerRadius = 5
        
        scrollView.addSubview(timePostedLabel)
        timePostedLabel.anchor(top: taskDescriptionTextView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        scrollView.addSubview(taskDurationLabel)
        taskDurationLabel.anchor(top: timePostedLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
    }
}
