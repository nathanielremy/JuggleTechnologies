//
//  Constants.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-18.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import Foundation

class Constants {
    struct FirebaseStorage {
        static let profileImages = "profile_images"
    }
    
    struct FirebaseDatabase {
        static let usersRef = "users"
        static let userId = "userId"
        static let emailAddress = "emailAddress"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let profileImageURLString = "profileImageURLString"
        static let isJuggler = "isJuggler"
        static let hasAppliedForJuggler = "hasAppliedForJuggler"
        
        static let creationDate = "creationDate"
    }
    
    struct TaskCategories {
        static let all = "All"
        static let cleaning = "Cleaning"
        static let delivery = "Delivery"
        static let moving = "Moving"
        static let computerIT = "Computer/IT"
        static let photoVideo = "Photo/Video"
        static let handyMan = "Handyman"
        static let assembly = "Assembly"
        static let pets = "Pets"
        static let anything = "Anything"
        
        static func categoryArray() -> [String] {
            return [self.cleaning, self.handyMan, self.computerIT, self.photoVideo, self.assembly, self.delivery, self.moving, self.pets, self.anything]
        }
    }
    
    struct ErrorDescriptions {
        static let invalidPassword = "The password is invalid or the user does not have a password."
        static let invalidEmailAddress = "There is no user record corresponding to this identifier. The user may have been deleted."
        static let networkError = "Network error (such as timeout, interrupted connection or unreachable host) has occurred."
        static let unavailableEmail = "The email address is already in use by another account."
    }
}
