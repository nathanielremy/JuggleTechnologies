//
//  TaskDetailsVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-29.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class TaskDetailsVC: UIViewController {
    //MARK: Stored properties
    var previousTaskInteractionVC: TaskInteractionVC?
    var previousOnGoingTaskInteractionVC: OnGoingTaskInteractionsVC?
    var didEditTask: Bool? {
        didSet {
            if self.didEditTask ?? false {
                if previousTaskInteractionVC != nil {
                    previousTaskInteractionVC?.task = self.task
                } else if previousOnGoingTaskInteractionVC != nil {
                    previousOnGoingTaskInteractionVC?.task = self.task
                }
            }
        }
    }
    
    var task: Task? {
        didSet {
            guard let task = self.task else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            
            if task.userId == Auth.auth().currentUser?.uid {
                let editTaskBarButton = UIBarButtonItem(title: "Editar", style: .plain, target: self, action: #selector(handleEditNavBarButton))
                self.navigationItem.rightBarButtonItem = editTaskBarButton
            }
            
            self.navigationItem.title = task.title
            self.taskTitleLabel.attributedText = setupAttributedText(withTitle: "Titulo", value: task.title)
            self.taskDescriptionTextView.text = task.description
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.locale = Locale(identifier: "es_ES")
            dateFormatterPrint.dateFormat = "dd, MMM, yyyy"
            
            self.timePostedLabel.attributedText = setupAttributedText(withTitle: "Publicado ", value: "\(task.creationDate.timeAgoDisplay()) el \(dateFormatterPrint.string(from: task.creationDate))")
            
            taskDurationLabel.attributedText = setupAttributedText(withTitle: "Duración Estimada", value: "\(task.duration)\(task.duration > 1 ? " hrs" : " hr")")
            taskBudgetLabel.attributedText = setupAttributedText(withTitle: "Presupuesto", value: "€\(task.budget)")
            taskLocationLabel.attributedText = setupAttributedText(withTitle: "Ubicación de la Tarea", value: task.isOnline ? "Por internet o teléfono" : "\(task.stringLocation ?? "")")
            
            if !task.isOnline {
                view.addSubview(verMapaButton)
                verMapaButton.anchor(top: taskLocationLabel.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: -8, paddingLeft: 0, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
            } else {
                verMapaButton.removeFromSuperview()
            }
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
        image.layer.borderColor = UIColor.mainBlue().cgColor
        image.layer.borderWidth = 1.5
        
        return image
    }()
    
    @objc fileprivate func handleProfileImageView() {
        guard let user = self.user, user.userId != Auth.auth().currentUser?.uid else {
            return
        }
        
        let profileVC = ProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        profileVC.user = user
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
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
    
    let taskBudgetLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()
    
    let taskLocationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var verMapaButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor.mainBlue(), for: .normal)
        button.setTitle("Ver mapa", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.addTarget(self, action: #selector(handleVerMapaButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleVerMapaButton() {
        guard let task = self.task, let longitude = task.longitude, let latitude = task.latitude else {
            let alert = UIView.okayAlert(title: "Error al Grabar", message: "Sal e intente nuevamente.")
            self.present(alert, animated: true, completion: nil)
            return
        }

        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        let mapView = TaskLocationMapViewVC()
        mapView.coordinnate = coordinate
        mapView.addressString = task.stringLocation
        
        let mapNavController = UINavigationController(rootViewController: mapView)
        self.present(mapNavController, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleEditNavBarButton() {
        guard let task = self.task, task.status == 0 else {
            let statusString = self.task?.status == 1 ? "aceptada" : "completada"
            let alert = UIView.okayAlert(title: "No se Puede Editar su Tarea", message: "Su tarea ya esta \(statusString).")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let editTaskVC = EditTaskVC()
        editTaskVC.task = task
        editTaskVC.previousViewController = self
        self.navigationController?.pushViewController(editTaskVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .darkText
        setupViews()
    }
    
    fileprivate func setupViews() {
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        scrollView.contentSize = CGSize(width: view.frame.width, height: 615)
        
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
        
        scrollView.addSubview(taskBudgetLabel)
        taskBudgetLabel.anchor(top: taskDurationLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        scrollView.addSubview(taskLocationLabel)
        taskLocationLabel.anchor(top: taskBudgetLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        //Add button over profileImageView to view user's profile
        let button = UIButton()
        button.backgroundColor = nil
        scrollView.addSubview(button)
        button.anchor(top: profileImageView.topAnchor, left: profileImageView.leftAnchor, bottom: profileImageView.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        button.addTarget(self, action: #selector(handleProfileImageView), for: .touchUpInside)
    }
}
