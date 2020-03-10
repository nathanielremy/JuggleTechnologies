//
//  Review.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-03-10.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import Foundation

struct Review {
    let id: String
    
    let creationDate: Date
    let isFromUserPerspective: Bool
    let rating: Int
    let reviewDescription: String
    let reviewedUserId: String
    let reviewerUserId: String
    let taskId: String
    
    init(id: String, dictionary: [String : Any]) {
        self.id = id
        
        let secondsFrom1970 = dictionary[Constants.FirebaseDatabase.creationDate] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        
        self.isFromUserPerspective = dictionary[Constants.FirebaseDatabase.isFromUserPerspective] as? Bool ?? true
        self.rating = dictionary[Constants.FirebaseDatabase.rating] as? Int ?? 0
        self.reviewDescription = dictionary[Constants.FirebaseDatabase.reviewDescription] as? String ?? "No hay descripción"
        self.reviewedUserId = dictionary[Constants.FirebaseDatabase.reviewedUserId] as? String ?? ""
        self.reviewerUserId = dictionary[Constants.FirebaseDatabase.reviewerUserId] as? String ?? ""
        self.taskId = dictionary[Constants.FirebaseDatabase.taskId] as? String ?? ""
    }
}
