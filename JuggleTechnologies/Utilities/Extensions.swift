//
//  Extensions.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-18.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

var userCache = [String : User]()

//MARK: Firebase Auth
extension Auth {
    static func loginUser(withEmail email: String, passcode: String, completion: @escaping (User?, String?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: passcode) { (usr, err) in
            if let error = err {
                completion(nil, error.localizedDescription); return
            }
            
            guard let firebaseData = usr else {
                completion(nil, "Ext/Auth: No firebaseUser returned in closure."); return
            }
            
            Database.fetchUserFromUserID(userID: firebaseData.user.uid, completion: { (usr) in
                guard let user = usr else {
                    completion(nil, "Ext/Auth: No firebaseUser returned in closure."); return
                }
                
                completion(user, nil); return
            })
        }
    }
}

//MARK: Firebase Database
extension Database {
    static func fetchUserFromUserID(userID: String, completion: @escaping (User?) -> Void) {
        
        // Check if we have already fetched the user
        if let user = userCache[userID] {
            completion(user)
            return
        }
        Database.database().reference().child(Constants.FirebaseDatabase.usersRef).child(userID).observeSingleEvent(of: .value, with: { (dataSnapshot) in

            guard let userDictionary = dataSnapshot.value as? [String : Any] else {
                completion(nil)
                print("Ext/Database: Datasnapshot dictionary not castable to [String:Any]"); return
            }

            let user = User(uid: userID, dictionary: userDictionary)
            
            userCache[userID] = user
            
            completion(user)

        }) { (error) in
            print("Ext/Database: Failed to fetch dataSnapshot of currentUser", error)
            completion(nil)
        }
    }
}

//MARK: UIColor
extension UIColor {
    static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
    
    static func mainBlue() -> UIColor {
        return rgb(0, 161, 255)
    }
    
    static func mainAmarillo() -> UIColor {
        return rgb(249, 186, 0)
    }
    
    static func chatBubbleGray() -> UIColor {
        return rgb(240, 240, 240)
    }
}

//MARK: UIView
extension UIView {
    static func okayAlert(title: String, message: String) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .cancel , handler: nil)
        alertController.addAction(okAction)
        
        return alertController
    }
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat?, height: CGFloat?) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: paddingRight).isActive = true
        }
        
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}
