
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
    
    var task: Task? {
        didSet {
            guard let task = self.task else {
                self.dismiss(animated: false, completion: nil)
                return
            }
            
            taskTitleLabel.text = task.title
            initalBudgetValueLabel.text = "€\(task.budget)"
        }
    }
    
    let taskTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .darkText
        label.numberOfLines = 2
        
        return label
    }()
    
    let initalBudgetValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let initalBudgetLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkText
        label.text = "Presupuesto Inicial"
        
        return label
    }()
    
    lazy var newOfferTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "€€€"
        tf.keyboardType = .numberPad
        tf.font = UIFont.boldSystemFont(ofSize: 16)
        tf.borderStyle = .roundedRect
        tf.tintColor = UIColor.darkText
        tf.layer.borderColor = UIColor.black.cgColor
        tf.delegate = self
        tf.inputAccessoryView = makeTextFieldToolBar()
        
        return tf
    }()
    
    let newOfferLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkText
        label.text = "Escribe su Oferta Aquí"
        
        return label
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("¡Listo!", for: .normal)
        button.tintColor = UIColor.mainBlue()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.borderColor = UIColor.mainBlue().cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleDoneButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleDoneButton() {
        print("Handeling doneButton")
        self.dismiss(animated: true, completion: nil)
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "¡Listo!", style: .done, target: self, action: #selector(handleDoneButton))
        navigationController?.navigationBar.tintColor = .darkText
    }
    
    @objc fileprivate func handleCancelBarButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setupViews() {
        view.addSubview(taskTitleLabel)
        taskTitleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        let budgetInfoStackView = UIStackView(arrangedSubviews: [initalBudgetLabel, newOfferLabel])
        budgetInfoStackView.axis = .horizontal
        budgetInfoStackView.spacing = 8
        budgetInfoStackView.distribution = .fillEqually
        
        view.addSubview(budgetInfoStackView)
        budgetInfoStackView.anchor(top: taskTitleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 100, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        view.addSubview(newOfferTextField)
        newOfferTextField.anchor(top: nil, left: nil, bottom: budgetInfoStackView.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 0, width: view.frame.width * 0.2, height: 50)
        newOfferTextField.centerXAnchor.constraint(equalTo: newOfferLabel.centerXAnchor).isActive = true
        
        view.addSubview(initalBudgetValueLabel)
        initalBudgetValueLabel.centerYAnchor.constraint(equalTo: newOfferTextField.centerYAnchor).isActive = true
        initalBudgetValueLabel.centerXAnchor.constraint(equalTo: initalBudgetLabel.centerXAnchor).isActive = true
        
        view.addSubview(doneButton)
        doneButton.anchor(top: budgetInfoStackView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 50)
        doneButton.layer.cornerRadius = 5
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
