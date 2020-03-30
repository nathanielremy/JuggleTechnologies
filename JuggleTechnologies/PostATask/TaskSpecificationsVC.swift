//
//  TaskSpecificationsVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-19.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class TaskSpecificationsVC: UIViewController {
    
    //MARK: Stored prperties
    var isTaskOnline = false
    var addressString: String?
    
    var taskCategory: String? {
        didSet {
            guard let category = taskCategory else {
                self.navigationController?.popViewController(animated: false)
                return
            }
            
            navigationItem.title = "Tarea de " + category
        }
    }
    
    let postTaskActivityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = UIColor.mainBlue()
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
    
    let taskTitleCaracterCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "0/50"
        
        return label
    }()
    
    lazy var taskTitleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Entre 10 y 50 caracteres"
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
    
    let taskDescriptionCaracterCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "0/500"
        
        return label
    }()
    
    lazy var taskDescriptionTextView: UITextView = {
        let tv = UITextView()
        tv.textColor = UIColor.lightGray
        tv.text = "Entre 25 y 500 caracteres"
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
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        label.textAlignment = .left
        
        let attributedText = NSMutableAttributedString(string: "Duración Estimada ", attributes: [.font : UIFont.boldSystemFont(ofSize: 14), .foregroundColor : UIColor.darkText])
        attributedText.append(NSAttributedString(string: "¿Cuántas horas requiere esta tarea?", attributes: [.font : UIFont.systemFont(ofSize: 12), .foregroundColor : UIColor.gray]))
        
        label.attributedText = attributedText
        
        return label
    }()
    
    lazy var durationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "2,5"
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
        attributedText.append(NSAttributedString(string: "¿Cuánto le gustaría pagar por esta tarea?", attributes: [.font : UIFont.systemFont(ofSize: 12), .foregroundColor : UIColor.gray]))
        
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
        toggle.tintColor = UIColor.mainBlue()
        toggle.onTintColor = UIColor.mainBlue()
        toggle.addTarget(self, action: #selector(handleOnlineSwitch), for: .valueChanged)
        
        return toggle
    }()
    
    @objc fileprivate func handleOnlineSwitch() {
        if onlineSwitch.isOn {
            isTaskOnline = true
            addressString = nil
            if !mapView.annotations.isEmpty {
                mapView.removeAnnotations([mapView.annotations[0]])
            }
            streetTextField.text = ""
            numberTextField.text = ""
            cpTextField.text = ""
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
            isTaskOnline = false
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
        map.layer.borderColor = UIColor.mainBlue().cgColor
        
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
        button.setTitle("¡Listo!", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.mainBlue()
        button.addTarget(self, action: #selector(handleDoneButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleDoneButton() {
        guard let taskValues: [String : Any] = verifyTaskValues() else {
            // Simply return since alert message gets display from within verifyTaskValues()
            return
        }
        
        postTask(withValues: taskValues)
    }
    
    fileprivate func postTask(withValues taskValues: [String : Any]) {
        let tasksRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef)
        let autoRef = tasksRef.childByAutoId()

        autoRef.updateChildValues(taskValues) { (err, dataRef) in
            if let error = err {
                print("PostTask(): Error updating to Firebase: ", error)
                DispatchQueue.main.async {
                    let alert = UIView.okayAlert(title: "No se Puede Publicar Esta Tarea", message: "No podemos publicar en este momento. Por favor intente nuevamente más tarde.")
                    self.present(alert, animated: true, completion: nil)
                    self.disableAndAnimate(false)
                }
                
                return
            }
            
            let task = Task(id: dataRef.key ?? "PLACEHOLDER STRING", dictionary: taskValues)
            
            self.addUserReference(forTask: task)
        }
    }
    
    fileprivate func addUserReference(forTask task: Task) {
        let userTasksRefValues = [
            Constants.FirebaseDatabase.creationDate : task.creationDate.timeIntervalSince1970,
            Constants.FirebaseDatabase.taskStatus : 0
        ]
        let userTasksRef = Database.database().reference().child(Constants.FirebaseDatabase.userTasksRef).child(task.userId).child(task.id)
        userTasksRef.updateChildValues(userTasksRefValues) { (err, _) in
            if let error = err {
                print("Error adding user reference to task: \(error)")
                DispatchQueue.main.async {
                    let alert = UIView.okayAlert(title: "No se Puede Publicar Esta Tarea", message: "No podemos publicar en este momento. Por favor intente nuevamente más tarde.")
                    self.present(alert, animated: true, completion: nil)
                    self.disableAndAnimate(false)
                }
                
                return
            }
            
            self.disableAndAnimate(false)
            let postCompleteVC = PostCompleteVC()
            postCompleteVC.task = task
            self.navigationController?.pushViewController(postCompleteVC, animated: true)
        }
    }
    
    fileprivate func verifyTaskValues() -> [String : Any]? {
        disableAndAnimate(true)
        
        var taskValues = [String : Any]()
        
        guard let inputs = areTextFieldInputsValid() else {
             // Simply return since alert message gets display from within areTextFieldInputsValid()
            disableAndAnimate(false)
            
            return nil
        }
        
        if !isTaskOnline {
            guard let locationString = self.addressString, !mapView.annotations.isEmpty else {
                let alert = UIView.okayAlert(title: "Ubicación Invalida", message: "Por favor, introduzca una ubicación válida.")
                present(alert, animated: true, completion: nil)
                disableAndAnimate(false)
                
                return nil
            }
            
            let latitude = mapView.annotations[0].coordinate.latitude as Double
            let longitude = mapView.annotations[0].coordinate.longitude as Double
            
            taskValues[Constants.FirebaseDatabase.latitude] = latitude
            taskValues[Constants.FirebaseDatabase.longitude] = longitude
            taskValues[Constants.FirebaseDatabase.stringLocation] = locationString
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            let alert = UIView.okayAlert(title: "No se Puede Publicar Esta Tarea", message: "No podemos publicar en este momento. Por favor intente nuevamente más tarde.")
            present(alert, animated: true, completion: nil)
            disableAndAnimate(false)
            
            return nil
        }
        
        taskValues[Constants.FirebaseDatabase.taskTitle] = inputs.title
        taskValues[Constants.FirebaseDatabase.taskDescription] = inputs.description
        taskValues[Constants.FirebaseDatabase.taskCategory] = inputs.category
        taskValues[Constants.FirebaseDatabase.taskDuration] = inputs.duration
        taskValues[Constants.FirebaseDatabase.taskBudget] = inputs.budget
        taskValues[Constants.FirebaseDatabase.taskStatus] = 0
        taskValues[Constants.FirebaseDatabase.isTaskOnline] = isTaskOnline ? 1 : 0
        taskValues[Constants.FirebaseDatabase.userId] = userId
        taskValues[Constants.FirebaseDatabase.creationDate] = Date().timeIntervalSince1970
        taskValues[Constants.FirebaseDatabase.isJugglerComplete] = 0
        taskValues[Constants.FirebaseDatabase.isUserComplete] = 0
        
        return taskValues
    }
    
    fileprivate func areTextFieldInputsValid() -> (title: String, description: String, category: String, duration: Double, budget: Double)? {
        guard let title = taskTitleTextField.text, title.count > 9, title.count < 51 else {
            let alert = UIView.okayAlert(title: "Error con el Titulo", message: "Tiene que estar entre 10 y 25 caracteres.")
            present(alert, animated: true, completion: nil); return nil
        }
        
        guard let description = taskDescriptionTextView.text, description.count > 24, description.count < 501, description != "Entre 25 y 500 caracteres" else {
            let alert = UIView.okayAlert(title: "Error con la Descripción", message: "Tiene que estar entre 25 y 500 caracteres.")
            present(alert, animated: true, completion: nil); return nil
        }
        
        guard let category = self.taskCategory else {
            self.navigationController?.popViewController(animated: true)
            return nil
        }
        
        let doubleDurationString = durationTextField.text?.replacingOccurrences(of: ",", with: ".") ?? ""
        guard let duration = Double(doubleDurationString) else {
            let alert = UIView.okayAlert(title: "Error con la Duración", message: "Indique cuántas horas requiere esta tarea.")
            present(alert, animated: true, completion: nil); return nil
        }
        
        guard let budgetString = budgetTextField.text, let budget = Double(budgetString) else {
            let alert = UIView.okayAlert(title: "Error con el Presupuesto", message: "Indique cuánto le gustaría pagar por esta tarea.")
            present(alert, animated: true, completion: nil); return nil
        }
        
        return (title, description, category, duration, budget)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "¡Listo!", style: .done, target: self, action: #selector(handleDoneButton))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.mainBlue()
        
        setupViews()
        setupHideKeyBoardOnTapGesture()
    }
    
    fileprivate func setupViews() {
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        scrollView.contentSize = CGSize(width: view.frame.width, height: 1110)
        
        scrollView.addSubview(taskTitleLabel)
        taskTitleLabel.anchor(top: scrollView.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        
        scrollView.addSubview(taskTitleTextField)
        taskTitleTextField.anchor(top: taskTitleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 4, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 50)
        
        scrollView.addSubview(taskTitleCaracterCountLabel)
        taskTitleCaracterCountLabel.anchor(top: nil, left: nil, bottom: taskTitleTextField.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: -20, width: nil, height: nil)
        
        scrollView.addSubview(taskDescriptionLabel)
        taskDescriptionLabel.anchor(top: taskTitleTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        taskDescriptionLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(taskDescriptionTextView)
        taskDescriptionTextView.anchor(top: taskDescriptionLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 4, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 100)
        taskDescriptionTextView.layer.cornerRadius = 5
        
        scrollView.addSubview(taskDescriptionCaracterCountLabel)
        taskDescriptionCaracterCountLabel.anchor(top: nil, left: nil, bottom: taskDescriptionTextView.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: -20, width: nil, height: nil)
        
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
        mapViewActivityIndicator.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
        mapViewActivityIndicator.centerYAnchor.constraint(equalTo: mapView.centerYAnchor).isActive = true
        
        scrollView.addSubview(postTaskActivityIndicator)
        postTaskActivityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        postTaskActivityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        scrollView.addSubview(doneButton)
        doneButton.anchor(top: mapView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 50)
        doneButton.layer.cornerRadius = 5
    }
    
    fileprivate func verifyCoordinates() {
        guard let street = streetTextField.text, street != "", let number = numberTextField.text, let intNumber = Int(number), let postalCode = cpTextField.text, postalCode != "" else {
            addressString = nil
            
            return
        }
        
        self.mapViewActivityIndicator.startAnimating()
        
        let address = street + ", " + "\(intNumber)" + ", " + "\(postalCode)" + ", Barcelona, España"
        self.addressString = address
        
        getCoordinates(fromAdress: address) { (success, coordinates) in
            guard let coordinate = coordinates, success else {
                self.mapViewActivityIndicator.stopAnimating()
                let alert = UIView.okayAlert(title: "Ubicación Invalida", message: "Por favor, introduzca una ubicación válida.")
                self.present(alert, animated: true, completion: nil)
                
                self.addressString = nil
                
                return
            }
            
            let latitude = coordinate.latitude as Double
            let longitude = coordinate.longitude as Double
            
            if (latitude > Constants.BarcalonaCoordinates.maximumLatitude) || (latitude < Constants.BarcalonaCoordinates.minimumLatitude) || (longitude > Constants.BarcalonaCoordinates.maximumLongitude) || (longitude < Constants.BarcalonaCoordinates.minimumLongitude) {
                
                DispatchQueue.main.async {
                    let alert = UIView.okayAlert(title: "Ubicación fuera de Barcelona", message: "Pronto estaremos disponibles en su área!")
                    self.present(alert, animated: true, completion: nil)
                    
                    self.mapViewActivityIndicator.stopAnimating()
                }
                
                self.addressString = nil
                
                return
            }
            
            DispatchQueue.main.async {
                self.placePinAt(coordinate: coordinate)
                self.mapViewActivityIndicator.stopAnimating()
            }
        }
        
    }
    
    func getCoordinates(fromAdress address: String, completionHandlerForCoordinates: @escaping (_ success: Bool, _ location: CLLocationCoordinate2D?) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location else {
                completionHandlerForCoordinates(false, nil)
                
                return
            }
            
            completionHandlerForCoordinates(true, location.coordinate)
        }
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
        
        cityTextField.isUserInteractionEnabled = false // Remains Barcelona
        
        taskTitleTextField.isUserInteractionEnabled = !bool
        taskDescriptionTextView.isUserInteractionEnabled = !bool
        durationTextField.isUserInteractionEnabled = !bool
        budgetTextField.isUserInteractionEnabled = !bool
        onlineSwitch.isEnabled = !bool
        
        if !onlineSwitch.isOn {
            streetTextField.isUserInteractionEnabled = !bool
            numberTextField.isUserInteractionEnabled = !bool
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
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let taskTitle = taskTitleTextField.text, textField == taskTitleTextField {
            taskTitleCaracterCountLabel.text = taskTitle.count == 1 ? "0/50" : "\(taskTitle.count)/50"
            if taskTitle.count > 49 {
                taskTitleTextField.text?.removeLast()
                taskTitleCaracterCountLabel.text = "\(taskTitle.count)/50"
            }
        } else if let postalCode = cpTextField.text, textField == cpTextField {
            if postalCode.count > 4 {
                cpTextField.text?.removeLast()
            }
        } else if let streetNumber = numberTextField.text, textField == numberTextField {
            if streetNumber.count > 5 {
                numberTextField.text?.removeLast()
            }
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == taskTitleTextField || textField == durationTextField {
            return
        }
        
        let frame: CGRect = textField == budgetTextField ? cpTextField.frame : doneButton.frame
        DispatchQueue.main.async {
            self.scrollView.scrollRectToVisible(frame, animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField == streetTextField) || (textField == numberTextField) || textField == cpTextField {
            self.verifyCoordinates()
        }
    }
    
    // When done button is clicked on keyboard input accessory view
    @objc func handleTextFieldDoneButton() {
        view.endEditing(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let taskDescription = taskDescriptionTextView.text, textView == taskDescriptionTextView {
            taskDescriptionCaracterCountLabel.text = taskDescription.count == 1 ? "0/500" : "\(taskDescription.count)/500"
            if taskDescription.count > 499 {
                taskDescriptionTextView.text.removeLast()
                taskDescriptionCaracterCountLabel.text = "\(taskDescription.count)/500"
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.darkText
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Entre 25 y 500 caracteres"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func setupHideKeyBoardOnTapGesture() {
         let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTextFieldDoneButton))
          tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
}

//MARK: MapView extension
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
