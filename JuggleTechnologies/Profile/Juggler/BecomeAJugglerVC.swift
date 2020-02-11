//
//  BecomeAJugglerVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-09.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class BecomeAJugglerVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: Stored properties
    var currentUser: User?
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = UIColor.mainBlue()
        
        return ai
    }()
    
    let CTATitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        
        let attributedText = NSMutableAttributedString(string: "Siendo un Juggler le da la oportunidad de ganar dinero mientras ayudas y conoces a la gente", attributes: [.foregroundColor : UIColor.darkText, .font : UIFont.boldSystemFont(ofSize: 17)])
        attributedText.append(NSAttributedString(string: "\n\nGana dinero trabajando en las cosas que quieres, cuando quieras con ", attributes: [.foregroundColor : UIColor.gray, .font : UIFont.systemFont(ofSize: 16)]))
        attributedText.append(NSAttributedString(string: "Juggle", attributes: [.foregroundColor : UIColor.mainBlue(), .font : UIFont.systemFont(ofSize: 16)]))
        
        label.attributedText = attributedText
        
        return label
    }()
    
    let faceAndIdPictureButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderColor = UIColor.mainBlue().cgColor
        button.layer.borderWidth = 1
        button.setTitle("Agrega una selfie con su DNI al lado de su figura.", for: .normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(handleFaceAndIdPictureButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleFaceAndIdPictureButton() {
        let alert = UIAlertController(title: "Toma o Elige una foto", message: "Agrega una selfie con su DNI al lado de su figura.", preferredStyle: .alert)
        let camaraAction = UIAlertAction(title: "Cámara", style: .default) { (_) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .camera
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        let eligeAction = UIAlertAction(title: "Elegir", style: .default) { (_) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(eligeAction)
        alert.addAction(camaraAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Set the selected image from image picker as profile picture
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            faceAndIdPictureButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
            
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            faceAndIdPictureButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        // Make button perfectly round
        faceAndIdPictureButton.layer.masksToBounds = true
        faceAndIdPictureButton.layer.cornerRadius = 5
        faceAndIdPictureButton.layer.borderColor = UIColor.mainBlue().cgColor
        faceAndIdPictureButton.layer.borderWidth = 1
        
        // Dismiss image picker view
        picker.dismiss(animated: true, completion: nil)
    }
    
    let testVersionLabel: UILabel = {
        let label = UILabel()
        label.text = "Here below we will ask for information required by Stripe to add deposit account."
        label.textColor = .darkText
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("¡Listo!", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.mainBlue()
        button.addTarget(self, action: #selector(handleDoneButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleDoneButton() {
        guard let image = self.faceAndIdPictureButton.imageView?.image else {
            self.handleFaceAndIdPictureButton()
            return
        }
        
        print(image.description)
        self.animateAndDisableViews(true)
        
        //Compress image
        guard let imageData = image.jpegData(compressionQuality: 0.2), let currentUser = self.currentUser else {
            DispatchQueue.main.async {
                self.present(self.errorSendingApplicationAlert(), animated: true, completion: nil)
                self.animateAndDisableViews(false)
            }
            return
        }
        
        // create a random file name to add profile image to Firebase storage
        let randomFile = UUID().uuidString
        let storageRef = Storage.storage().reference().child(Constants.FirebaseStorage.jugglerApplicationPictures).child(randomFile)
        storageRef.putData(imageData, metadata: nil) { (metaData, err) in
            if let error = err {
                print("Error putting applicationPicture to Firebase Storage: \(error)")
                DispatchQueue.main.async {
                    self.present(self.errorSendingApplicationAlert(), animated: true, completion: nil)
                    self.animateAndDisableViews(false)
                }
                
                return
            }
            
            storageRef.downloadURL { (url, err) in
                if let error = err {
                    print("Error putting applicationPicture to Firebase Storage: \(error)")
                    DispatchQueue.main.async {
                        self.present(self.errorSendingApplicationAlert(), animated: true, completion: nil)
                        self.animateAndDisableViews(false)
                    }
                    
                    return
                }
                
                guard let applicationPictureURLString = url?.absoluteString else {
                    print("No URL returned")
                    DispatchQueue.main.async {
                        self.present(self.errorSendingApplicationAlert(), animated: true, completion: nil)
                        self.animateAndDisableViews(false)
                    }
                    return
                }
                
                let applicationValues: [String : Any] = [
                    Constants.FirebaseDatabase.creationDate : Date().timeIntervalSince1970,
                    Constants.FirebaseDatabase.applicationPictureURLString : applicationPictureURLString
                ]
                
                let values = [currentUser.userId : applicationValues]
                
                let ref = Database.database().reference().child(Constants.FirebaseDatabase.jugglerApplicationsRef)
                ref.updateChildValues(values) { (err, _) in
                    if let error = err {
                        print("Error saving jugglerApplication to database: ", error)
                        DispatchQueue.main.async {
                            self.present(self.errorSendingApplicationAlert(), animated: true, completion: nil)
                            self.animateAndDisableViews(false)
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.animateAndDisableViews(false)
                        let jugglerApplicationCompleteVC = JugglerApplicationCompleteVC()
                        jugglerApplicationCompleteVC.user = currentUser
                        self.navigationController?.pushViewController(jugglerApplicationCompleteVC, animated: true)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "¡Se un Juggler!"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        
        setupViews()
        fetchCurrentUser()
    }
    
    fileprivate func fetchCurrentUser() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.navigationController?.dismiss(animated: false, completion: nil)
            return
        }
        
        Database.fetchUserFromUserID(userID: currentUserId) { (user) in
            if let currentUser = user {
                self.currentUser = currentUser
            }
        }
    }
    
    fileprivate func setupViews() {
        view.addSubview(CTATitleLabel)
        CTATitleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        view.addSubview(faceAndIdPictureButton)
        let faceAndIdPictureButtonWidth = view.frame.width * 0.33
        faceAndIdPictureButton.anchor(top: CTATitleLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: faceAndIdPictureButtonWidth, height: faceAndIdPictureButtonWidth * 1.2)
        faceAndIdPictureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(testVersionLabel)
        testVersionLabel.anchor(top: faceAndIdPictureButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        view.addSubview(doneButton)
        doneButton.anchor(top: testVersionLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 50)
        doneButton.layer.cornerRadius = 5
    }
    
    fileprivate func animateAndDisableViews(_ bool: Bool) {
        if bool {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
        
        self.faceAndIdPictureButton.isEnabled = !bool
        self.doneButton.isEnabled = !bool
    }
    
    fileprivate func errorSendingApplicationAlert() -> UIAlertController {
        let alert = UIView.okayAlert(title: "No podemos finalizar su solicitud.", message: "Salga e intente nuevamente")
        
        return alert
    }
}

extension BecomeAJugglerVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
