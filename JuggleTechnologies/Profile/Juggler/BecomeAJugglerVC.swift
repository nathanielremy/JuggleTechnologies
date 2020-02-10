//
//  BecomeAJugglerVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-09.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class BecomeAJugglerVC: UIViewController {
    //MARK: Stored properties
    var currentUser: User?
    
    let CTATitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        
        let attributedText = NSMutableAttributedString(string: "Siendo un Juggler le da la oportunidad de ganar dinero mientras ayudando y conociendo a la gente alrededor", attributes: [.foregroundColor : UIColor.darkText, .font : UIFont.boldSystemFont(ofSize: 17)])
        attributedText.append(NSAttributedString(string: "\n\nGana dinero trabajando en las cosas que quieres, cuando quieras con ", attributes: [.foregroundColor : UIColor.gray, .font : UIFont.systemFont(ofSize: 16)]))
        attributedText.append(NSAttributedString(string: "Juggle", attributes: [.foregroundColor : UIColor.mainBlue(), .font : UIFont.systemFont(ofSize: 16)]))
        
        label.attributedText = attributedText
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "¡Se un Juggler!"
        
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
