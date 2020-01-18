//
//  User.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-18.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import Foundation

struct User {
    let uid: String
    
    let firstName: String
    let lastName: String
    let emailAddress: String
    let profileImageURLString: String
    let isJuggler: Bool
    let hasAppliedForJuggler: Bool
    let creationDate: Date
    
    init(uid: String, dictionary: [String : Any]) {
        self.uid = uid
        self.firstName = dictionary[Constants.FirebaseDatabase.firstName] as? String ?? "first"
        self.lastName = dictionary[Constants.FirebaseDatabase.lastName] as? String ?? "last"
        self.emailAddress = dictionary[Constants.FirebaseDatabase.emailAddress] as? String ?? "No email"
        self.profileImageURLString = dictionary[Constants.FirebaseDatabase.profileImageURLString] as? String ?? ""
        self.isJuggler = dictionary[Constants.FirebaseDatabase.isJuggler] as? Bool ?? false
        self.hasAppliedForJuggler = dictionary[Constants.FirebaseDatabase.hasAppliedForJuggler] as? Bool ?? false
        
        let secondsFrom1970 = dictionary[Constants.FirebaseDatabase.creationDate] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
