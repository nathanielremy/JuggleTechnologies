
//
//  TaskOfferVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-08.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class TaskOfferVC: UIViewController {
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
            initialBudgetValueLabel.text = "€\(task.budget)"
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
        
        newOfferTextField.isUserInteractionEnabled = !bool
        doneButton.isEnabled = !bool
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
    
    let initialBudgetValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let initalBudgetLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkText
        label.text = "Presupuesto Inicial:"
        
        return label
    }()
    
    lazy var newOfferTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "€€€"
        tf.textAlignment = .center
        tf.keyboardType = .numberPad
        tf.font = UIFont.boldSystemFont(ofSize: 17)
        tf.borderStyle = .none
        tf.tintColor = UIColor.mainBlue()
        tf.textColor = UIColor.mainBlue()
        tf.delegate = self
        tf.inputAccessoryView = makeTextFieldToolBar()
        
        return tf
    }()
    
    let newOfferLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.mainBlue()
        label.text = "Su Oferta Aquí:"
        
        return label
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("¡Haz Oferta!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.backgroundColor = UIColor.mainBlue()
        button.addTarget(self, action: #selector(handleDoneButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleDoneButton() {
        self.animateAndDisableViews(true)
        guard let offerValues = getOfferValues(), let task = self.task, let currentUserId = Auth.auth().currentUser?.uid else {
            //Simply return, AlertControllers get presented from within above function
            self.animateAndDisableViews(false)
            return
        }
        
        let taskOffersRef = Database.database().reference().child(Constants.FirebaseDatabase.taskOffersRef).child(task.id).child(currentUserId)
        taskOffersRef.updateChildValues(offerValues) { (err, _) in
            if let error = err {
                print("Error adding offer for task: \(error)")
                DispatchQueue.main.async {
                    let alert = UIView.okayAlert(title: "No se Puede Publicar Esta Oferta", message: "No podemos publicar en este momento. Por favor intente nuevamente más tarde.")
                    self.present(alert, animated: true, completion: nil)
                    self.animateAndDisableViews(false)
                }
                return
            }
            
            let jugglerTasksValues = [
                Constants.FirebaseDatabase.creationDate : Date().timeIntervalSince1970,
                Constants.FirebaseDatabase.taskStatus : 0
            ]
            //Update Juggler's task at location jugglerTasks/offer.taskId
            let jugglerTasksRef = Database.database().reference().child(Constants.FirebaseDatabase.jugglerTasksRef).child(currentUserId).child(task.id)
            jugglerTasksRef.updateChildValues(jugglerTasksValues) { (err, _) in
                if let error = err {
                    print("Error accepting offer: \(error)")
                    let alert = UIView.okayAlert(title: "No se Puede aceptar Esta Oferta", message: "Sal e intente nuevamente")
                    self.present(alert, animated: true, completion: nil)
                    self.animateAndDisableViews(false)
                    return
                }
                
                let offerCompleteVC = OfferCompleteVC()
                offerCompleteVC.offer = ("\(offerValues[Constants.FirebaseDatabase.offerPrice] ?? 0)", task.title, offerValues[Constants.FirebaseDatabase.isAcceptingBudget] as? Bool)
                self.navigationController?.pushViewController(offerCompleteVC, animated: true)
            }
        }
    }
    
    fileprivate func getOfferValues() -> [String : Any]? {
        var offerValues = [String : Any]()
        guard let offerString = newOfferTextField.text, let offerPrice = Int(offerString) else {
            let alert = UIView.okayAlert(title: "Error con Oferta", message: "Indique cual es su oferta para esta tarea.")
            present(alert, animated: true, completion: nil)
            return nil
        }
        
        guard let task = self.task, let currentUserId = Auth.auth().currentUser?.uid else {
            let alert = UIView.okayAlert(title: "No se Puede Publicar Esta Oferta", message: "No podemos publicar en este momento. Por favor intente nuevamente más tarde.")
            present(alert, animated: true, completion: nil)
            return nil
        }
        
        offerValues[Constants.FirebaseDatabase.isAcceptingBudget] = ((offerPrice == task.budget) ? true : false)
        offerValues[Constants.FirebaseDatabase.offerPrice] = offerPrice
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
        
        setupNavigationItems()
        setupViews()
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.title = "Haz Oferta"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancelBarButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "¡Haz Oferta!", style: .done, target: self, action: #selector(handleDoneButton))
        navigationController?.navigationBar.tintColor = .darkText
        navigationItem.rightBarButtonItem?.tintColor = UIColor.mainBlue()
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
        
        let currentPriceStackView = UIStackView(arrangedSubviews: [initalBudgetLabel, initialBudgetValueLabel])
        currentPriceStackView.axis = .horizontal
        currentPriceStackView.distribution = .fillEqually
        currentPriceStackView.spacing = 20
        
        let offerStackView = UIStackView(arrangedSubviews: [newOfferLabel, newOfferTextField])
        currentPriceStackView.axis = .horizontal
        currentPriceStackView.distribution = .fillEqually
        offerStackView.spacing = 20
        
        let stack = UIStackView(arrangedSubviews: [currentPriceStackView, offerStackView])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        stack.anchor(top: taskTitleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 50, paddingBottom: 0, paddingRight: -50, width: nil, height: 100)
        
        newOfferTextField.translatesAutoresizingMaskIntoConstraints = false
        newOfferTextField.centerXAnchor.constraint(equalTo: initialBudgetValueLabel.centerXAnchor).isActive = true
        
        let offerSeperatorView = UIView()
        offerSeperatorView.backgroundColor = UIColor.mainBlue()
        
        view.addSubview(offerSeperatorView)
        offerSeperatorView.anchor(top: nil, left: newOfferTextField.leftAnchor, bottom: newOfferTextField.bottomAnchor, right: newOfferTextField.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 1)
        
        view.addSubview(doneButton)
        doneButton.anchor(top: stack.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 50)
        doneButton.layer.cornerRadius = 5
        
        view.addSubview(activityIndicator)
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let button = UIButton()
        button.backgroundColor = nil
        view.addSubview(button)
        button.anchor(top: profileImageView.topAnchor, left: profileImageView.leftAnchor, bottom: profileImageView.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        button.addTarget(self, action: #selector(handleProfileImageView), for: .touchUpInside)
    }
    
    fileprivate func makeTextFieldToolBar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(handleTextFieldDoneButton))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        return toolBar
    }
}

extension TaskOfferVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    // When done button is clicked on keyboard input accessory view
    @objc func handleTextFieldDoneButton() {
        view.endEditing(true)
    }
}
