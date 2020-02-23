//
//  AcceptTaskVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-17.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class AcceptTaskVC: UIViewController {
    //MARK: Stored properties
    var user: User? {
        didSet {
            guard let user = self.user else {
                self.dismiss(animated: false, completion: nil)
                return
            }
            
            profileImageView.loadImage(from: user.profileImageURLString)
            firstNameLabel.text = user.firstName
        }
    }
    
    var task: Task? {
        didSet {
            guard let task = self.task else {
                self.dismiss(animated: false, completion: nil)
                return
            }
            
            taskTitleLabel.text = task.title
            budgetLabel.text = "€\(task.budget)"
        }
    }
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = UIColor.mainBlue()
        ai.translatesAutoresizingMaskIntoConstraints = false
        
        return ai
    }()
    
    fileprivate func animateAndDisableViews(_ bool: Bool) {
        if bool {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        acceptButton.isEnabled = !bool
        navigationController?.navigationBar.isUserInteractionEnabled = !bool
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.borderColor = UIColor.mainBlue().cgColor
        iv.layer.borderWidth = 1.5
        
        return iv
    }()
    
    @objc fileprivate func handleProfileImageView() {
        guard let user = self.user, user.userId != Auth.auth().currentUser?.uid else {
            return
        }
        
        let profileVC = ProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        profileVC.user = user
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    let firstNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        label.textAlignment = .center
        
        return label
    }()
    
    let taskTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = .darkText
        label.numberOfLines = 2
        
        return label
    }()
    
    let budgetLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.mainBlue()
        
        return label
    }()
    
    lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("¡Aceptar Precio!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.backgroundColor = UIColor.mainBlue()
        button.addTarget(self, action: #selector(handleAcceptButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleAcceptButton() {
        self.animateAndDisableViews(true)
        guard let offerValues = getOfferValues(), let task = self.task, let currentUserId = Auth.auth().currentUser?.uid else {
            //Simply return, AlertControllers get presented from within above function
            self.animateAndDisableViews(false)
            return
        }
        
        let taskOffersRef = Database.database().reference().child(Constants.FirebaseDatabase.taskOffersRef).child(task.id).child(currentUserId)
        taskOffersRef.updateChildValues(offerValues) { (err, _) in
            if let error = err {
                print("Error accepting task price for task: \(error)")
                DispatchQueue.main.async {
                    let alert = UIView.okayAlert(title: "No se Puede Aceptar Esta Tarea", message: "No podemos publicar en este momento. Por favor intente nuevamente más tarde.")
                    self.present(alert, animated: true, completion: nil)
                    self.animateAndDisableViews(false)
                }
                return
            }
            
            let offerCompleteVC = OfferCompleteVC()
            offerCompleteVC.offer = ("\(task.budget)", task.title, true)
            self.navigationController?.pushViewController(offerCompleteVC, animated: true)
        }
    }
    
    fileprivate func getOfferValues() -> [String : Any]? {
        var offerValues = [String : Any]()
        
        guard let task = self.task, let currentUserId = Auth.auth().currentUser?.uid else {
            let alert = UIView.okayAlert(title: "No se Puede Publicar Esta Oferta", message: "No podemos publicar en este momento. Por favor intente nuevamente más tarde.")
            present(alert, animated: true, completion: nil)
            return nil
        }
        
        offerValues[Constants.FirebaseDatabase.offerPrice] = task.budget
        offerValues[Constants.FirebaseDatabase.isAcceptingBudget] = true
        offerValues[Constants.FirebaseDatabase.creationDate] = Date().timeIntervalSince1970
        offerValues[Constants.FirebaseDatabase.isOfferAccepted] = false
        offerValues[Constants.FirebaseDatabase.isOfferRejected] = false
        offerValues[Constants.FirebaseDatabase.taskId] = task.id
        offerValues[Constants.FirebaseDatabase.offerOwnerId] = currentUserId
        
        return offerValues
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationItemsAndActivityIndicator()
        setupViews()
    }
    
    fileprivate func setupNavigationItemsAndActivityIndicator() {
        navigationItem.title = "Aceptar Tarea"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancelBarButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "¡Aceptar!", style: .done, target: self, action: #selector(handleAcceptButton))
        navigationController?.navigationBar.tintColor = .darkText
        navigationItem.rightBarButtonItem?.tintColor = UIColor.mainBlue()
        
        view.addSubview(activityIndicator)
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc fileprivate func handleCancelBarButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setupViews() {
        view.addSubview(profileImageView)
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.layer.cornerRadius = 100/2
        
        view.addSubview(firstNameLabel)
        firstNameLabel.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        view.addSubview(taskTitleLabel)
        taskTitleLabel.anchor(top: firstNameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        view.addSubview(budgetLabel)
        budgetLabel.anchor(top: taskTitleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        view.addSubview(acceptButton)
        acceptButton.anchor(top: budgetLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 50)
        acceptButton.layer.cornerRadius = 5
        
        //Add button over profileImageView to view user's profile
        let button = UIButton()
        button.backgroundColor = nil
        view.addSubview(button)
        button.anchor(top: profileImageView.topAnchor, left: profileImageView.leftAnchor, bottom: profileImageView.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        button.addTarget(self, action: #selector(handleProfileImageView), for: .touchUpInside)
    }
}
