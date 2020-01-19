//
//  TaskSpecificationsVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-19.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import MapKit

class TaskSpecificationsVC: UIViewController {
    
    //MARK: Stored prperties
    var taskCategory: String? {
        didSet {
            guard let category = taskCategory else {
                self.navigationController?.popViewController(animated: false)
                return
            }
            
            navigationItem.title = category + " Task"
        }
    }
    
    let postTaskActivityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = UIColor.darkText
        ai.translatesAutoresizingMaskIntoConstraints = false
        
        return ai
    }()
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.backgroundColor = .white
        sv.keyboardDismissMode = .interactive
        
        return sv
    }()
    
    let taskTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Titulo"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        label.textAlignment = .left
        
        
        return label
    }()
    
    lazy var taskTitleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Minimum 10 characters, max 40 characters"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.tintColor = .darkText
        tf.layer.borderColor = UIColor.black.cgColor
        tf.delegate = self
        
        return tf
    }()
    
    let taskDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Descripción"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var taskDescriptionTextView: UITextView = {
        let tv = UITextView()
        tv.textColor = UIColor.lightGray
        tv.text = "(Minimum 25 charcaters, max 250 characters)"
        tv.tintColor = .darkText
        tv.layer.borderWidth = 0.5
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.layer.masksToBounds = true
        tv.isScrollEnabled = true
        tv.bounces = true
        tv.inputAccessoryView = makeTextFieldToolBar()
        
        //Remove placeholder text when user enters text methods in delegate
        tv.delegate = self
        
        return tv
    }()
    
    let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "Duración Estimada"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        label.textAlignment = .left
        
        
        return label
    }()
    
    lazy var durationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "2.5"
        tf.keyboardType = .decimalPad
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.tintColor = UIColor.darkText
        tf.layer.borderColor = UIColor.black.cgColor
        tf.delegate = self
        tf.inputAccessoryView = makeTextFieldToolBar()
        
        return tf
    }()
    
    let budgetLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        
        let attributedText = NSMutableAttributedString(string: "Presupuesto € ", attributes: [.font : UIFont.boldSystemFont(ofSize: 14), .foregroundColor : UIColor.darkText])
        attributedText.append(NSAttributedString(string: "Cuanto le gustaría pagar por esta tarea?", attributes: [.font : UIFont.systemFont(ofSize: 12), .foregroundColor : UIColor.darkText]))
        
        label.attributedText = attributedText
        
        return label
    }()
    
    lazy var budgetTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "€€€"
        tf.keyboardType = .numberPad
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.tintColor = UIColor.darkText
        tf.layer.borderColor = UIColor.black.cgColor
        tf.delegate = self
        tf.inputAccessoryView = makeTextFieldToolBar()
        
        return tf
    }()
    
    let onlineTaskLabel: UILabel = {
        let label = UILabel()
        label.text = "¿Se puede realizar esta tarea por internet o por teléfono?"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var onlineSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false
        toggle.tintColor = UIColor.darkText
        toggle.onTintColor = UIColor.darkText
        toggle.addTarget(self, action: #selector(handleOnlineSwitch), for: .valueChanged)
        
        return toggle
    }()
    
    @objc fileprivate func handleOnlineSwitch() {
        if onlineSwitch.isOn {
//            isTaskOnline = true
            mapView.isUserInteractionEnabled = false
            mapView.alpha = 0.5
            streetLabel.textColor = UIColor.darkText.withAlphaComponent(0.3)
            streetTextField.isUserInteractionEnabled = false
            numberLabel.textColor = UIColor.darkText.withAlphaComponent(0.3)
            numberTextField.isUserInteractionEnabled = false
            cityLabel.textColor = UIColor.darkText.withAlphaComponent(0.3)
            cityTextField.isUserInteractionEnabled = false //Remains Barcelona
            cpLabel.textColor = UIColor.darkText.withAlphaComponent(0.3)
            cpTextField.isUserInteractionEnabled = false
            cityTextField.textColor = .lightGray
        } else {
//            isTaskOnline = false
            mapView.isUserInteractionEnabled = true
            mapView.alpha = 1
            streetLabel.textColor = UIColor.darkText.withAlphaComponent(1)
            streetTextField.isUserInteractionEnabled = true
            numberLabel.textColor = UIColor.darkText.withAlphaComponent(1)
            numberTextField.isUserInteractionEnabled = true
            cityLabel.textColor = UIColor.darkText.withAlphaComponent(1)
            cityTextField.isUserInteractionEnabled = false //Remains Barcelona
            cpLabel.textColor = UIColor.darkText.withAlphaComponent(1)
            cpTextField.isUserInteractionEnabled = true
            cityTextField.textColor = .darkText
        }
    }
    
    let oLabel: UILabel = {
        let label = UILabel()
        label.text = "o"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        label.textAlignment = .left
        
        return label
    }()
    
    let streetLabel: UILabel = {
        let label = UILabel()
        label.text = "Calle"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var streetTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Carrer de Sant Miquel"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.tintColor = .darkText
        tf.layer.borderColor = UIColor.black.cgColor
        tf.delegate = self
        
        return tf
    }()
    
    let numberLabel: UILabel = {
        let label = UILabel()
        label.text = "Número"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var numberTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "14"
        tf.keyboardType = .numberPad
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.tintColor = UIColor.darkText
        tf.layer.borderColor = UIColor.black.cgColor
        tf.delegate = self
        tf.inputAccessoryView = makeTextFieldToolBar()
        
        return tf
    }()
    
    let cityLabel: UILabel = {
        let label = UILabel()
        label.text = "Ciudad"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var cityTextField: UITextField = {
        let tf = UITextField()
        tf.text = "Barcelona, España"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.tintColor = .darkText
        tf.layer.borderColor = UIColor.black.cgColor
        tf.isUserInteractionEnabled = false
        
        return tf
    }()
    
    let cpLabel: UILabel = {
        let label = UILabel()
        label.text = "CP"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var cpTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "08003"
        tf.keyboardType = .numberPad
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.tintColor = UIColor.darkText
        tf.layer.borderColor = UIColor.black.cgColor
        tf.delegate = self
        tf.inputAccessoryView = makeTextFieldToolBar()
        
        return tf
    }()
    
    // MKMapView's previous annotation
    var previousAnnotation: MKAnnotation?
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.delegate = self
        map.layer.masksToBounds = true
        map.layer.borderWidth = 1
        map.layer.borderColor = UIColor.darkText.cgColor
        
        return map
    }()
    
    let mapViewActivityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = UIColor.mainBlue()
        ai.translatesAutoresizingMaskIntoConstraints = false
        
        return ai
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.darkText
        button.setTitle("Listo!", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleDoneButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleDoneButton() {
//        if mapView.annotations.isEmpty {
//            let alert = UIView.okayAlert(title: "No location provided", message: "Please specify the location for where your needed service will take place.")
//            present(alert, animated: true, completion: nil)
//
//        } else {
        guard let taskValues: [String : Any] = verifyTaskValues() else {
            // Simply return since alert message gets display from within verifyTaskValues()
            return
        }
//        }
    }
    
    fileprivate func verifyTaskValues() -> [String : Any]? {
        var taskValues = [String : Any]()
        
        disableAndAnimate(true)
        
        return taskValues
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Listo!", style: .plain, target: self, action: #selector(handleDoneButton))
        
        setupViews()
        setupHideKeyBoardOnTapGesture()
    }
    
    fileprivate func setupViews() {
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        scrollView.contentSize = CGSize(width: view.frame.width, height: 1100)
        
        scrollView.addSubview(taskTitleLabel)
        taskTitleLabel.anchor(top: scrollView.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        
        scrollView.addSubview(taskTitleTextField)
        taskTitleTextField.anchor(top: taskTitleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 4, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 50)
        
        scrollView.addSubview(taskDescriptionLabel)
        taskDescriptionLabel.anchor(top: taskTitleTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        taskDescriptionLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(taskDescriptionTextView)
        taskDescriptionTextView.anchor(top: taskDescriptionLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 4, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 100)
        taskDescriptionTextView.layer.cornerRadius = 5
        
        scrollView.addSubview(durationLabel)
        durationLabel.anchor(top: taskDescriptionTextView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        scrollView.addSubview(durationTextField)
        durationTextField.anchor(top: durationLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 4, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 50)
        
        scrollView.addSubview(budgetLabel)
        budgetLabel.anchor(top: durationTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        scrollView.addSubview(budgetTextField)
        budgetTextField.anchor(top: budgetLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 4, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 50)
        
        scrollView.addSubview(onlineTaskLabel)
        onlineTaskLabel.anchor(top: budgetTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: (view.frame.width * 0.7), height: nil)
        
        scrollView.addSubview(onlineSwitch)
        onlineSwitch.anchor(top: nil, left: onlineTaskLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: nil, height: nil)
        onlineSwitch.centerYAnchor.constraint(equalTo: onlineTaskLabel.centerYAnchor).isActive = true
        
        scrollView.addSubview(oLabel)
        oLabel.anchor(top: onlineTaskLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        scrollView.addSubview(streetLabel)
        streetLabel.anchor(top: oLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: (view.frame.width * 0.6), height: nil)
        
        scrollView.addSubview(streetTextField)
        streetTextField.anchor(top: streetLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: streetLabel.rightAnchor, paddingTop: 4, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: nil, height: 50)
        
        scrollView.addSubview(numberLabel)
        numberLabel.anchor(top: oLabel.bottomAnchor, left: streetLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        scrollView.addSubview(numberTextField)
        numberTextField.anchor(top: numberLabel.bottomAnchor, left: streetTextField.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 4, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 50)
        
        scrollView.addSubview(cityLabel)
        cityLabel.anchor(top: streetTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: (view.frame.width * 0.6), height: nil)
        
        scrollView.addSubview(cityTextField)
        cityTextField.anchor(top: cityLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: cityLabel.rightAnchor, paddingTop: 4, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: nil, height: 50)
        
        scrollView.addSubview(cpLabel)
        cpLabel.anchor(top: numberTextField.bottomAnchor, left: cityLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        scrollView.addSubview(cpTextField)
        cpTextField.anchor(top: cpLabel.bottomAnchor, left: streetTextField.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 4, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 50)
        
        scrollView.addSubview(mapView)
        mapView.anchor(top: cityTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 300)
        mapView.layer.cornerRadius = 5
        
        mapView.addSubview(mapViewActivityIndicator)
        mapViewActivityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapViewActivityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        scrollView.addSubview(postTaskActivityIndicator)
        postTaskActivityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        postTaskActivityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        scrollView.addSubview(doneButton)
        doneButton.anchor(top: mapView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 50)
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
    
    func disableAndAnimate(_ bool: Bool) {
        DispatchQueue.main.async {
            if bool {
                self.postTaskActivityIndicator.startAnimating()
            } else {
                self.postTaskActivityIndicator.stopAnimating()
            }

        }
        
        taskTitleTextField.isUserInteractionEnabled = !bool
        taskDescriptionTextView.isUserInteractionEnabled = !bool
        durationTextField.isUserInteractionEnabled = !bool
        budgetTextField.isUserInteractionEnabled = !bool
        onlineSwitch.isEnabled = !bool
        
        if !onlineSwitch.isOn {
            streetTextField.isUserInteractionEnabled = !bool
            numberTextField.isUserInteractionEnabled = !bool
            cityTextField.isUserInteractionEnabled = !bool
            cpTextField.isUserInteractionEnabled = !bool
            mapView.isUserInteractionEnabled = !bool
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = !bool
        navigationItem.leftBarButtonItem?.isEnabled = !bool
        doneButton.isUserInteractionEnabled = !bool
    }
}

//MARK: UITextFieldDelegate & UITextViewDelegate Methods
extension TaskSpecificationsVC: UITextFieldDelegate, UITextViewDelegate {
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.darkText
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "(Minimum 25 charcaters, max 250 characters)"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func setupHideKeyBoardOnTapGesture() {
         let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(handleTextFieldDoneButton))
          tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
}

extension TaskSpecificationsVC: MKMapViewDelegate {
    
    func placePinAt(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
        self.mapView.centerCoordinate = coordinate
        
        if let oldAnnotation = self.previousAnnotation {
            self.mapView.removeAnnotation(oldAnnotation)
            self.previousAnnotation = annotation
        } else {
            self.previousAnnotation = annotation
        }
    }
    
    //Delegate methods
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseIdentifier = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKPinAnnotationView
        
        if let pinView = pinView {
            pinView.annotation = annotation
        } else {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            pinView!.pinTintColor = UIColor.mainBlue()
        }
        return pinView
    }
}
