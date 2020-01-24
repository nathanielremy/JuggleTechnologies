//
//  User.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-18.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import Foundation

struct User {
    let userId: String
    
    let firstName: String
    let lastName: String
    let emailAddress: String
    let profileImageURLString: String
    let isJuggler: Bool
    let hasAppliedForJuggler: Bool
    let creationDate: Date
    var description: String
    
    init(userId: String, dictionary: [String : Any]) {
        self.userId = userId
        self.firstName = dictionary[Constants.FirebaseDatabase.firstName] as? String ?? "Nombre"
        self.lastName = dictionary[Constants.FirebaseDatabase.lastName] as? String ?? "Apellido"
        self.emailAddress = dictionary[Constants.FirebaseDatabase.emailAddress] as? String ?? "No email"
        self.profileImageURLString = dictionary[Constants.FirebaseDatabase.profileImageURLString] as? String ?? ""
        self.isJuggler = dictionary[Constants.FirebaseDatabase.isJuggler] as? Bool ?? false
        self.hasAppliedForJuggler = dictionary[Constants.FirebaseDatabase.hasAppliedForJuggler] as? Bool ?? false
        
        let secondsFrom1970 = dictionary[Constants.FirebaseDatabase.creationDate] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        
        self.description = dictionary[Constants.FirebaseDatabase.description] as? String ?? ""
    }
}
