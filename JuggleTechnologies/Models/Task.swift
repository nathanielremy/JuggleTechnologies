//
//  Task.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-20.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import Foundation
import Firebase

struct Task {
    
    let id: String
    let userId: String
    
    let latitude: Double?
    let longitude: Double?
    let stringLocation: String?
    
    //Status of 0 means the task is pending
    //Status of 1 means the task has been accepted
    //Status of 2 means the task has been completed
    var status: Int
    
    let isOnline: Bool
    let duration: Double
    let budget: Int
    let category: String
    let description: String
    let title: String
    let creationDate: Date
    let acceptedDate: Date
    let completionDate: Date
    
    let isJugglerComplete: Bool
    var isUserComplete: Bool
    var assignedJugglerId: String?

    
    init(id: String, dictionary: [String : Any]) {
        
        self.id = id
        
        self.userId = dictionary[Constants.FirebaseDatabase.userId] as? String ?? ""
        let online = dictionary[Constants.FirebaseDatabase.isTaskOnline] as? Int ?? 1
        
        if online == 1 {
            self.isOnline = true
            self.latitude = nil
            self.longitude = nil
            self.stringLocation = nil
        } else {
            self.isOnline = false
            self.latitude = dictionary[Constants.FirebaseDatabase.latitude] as? Double ?? 41.390205
            self.longitude = dictionary[Constants.FirebaseDatabase.longitude] as? Double ?? 2.154007
            self.stringLocation = dictionary[Constants.FirebaseDatabase.stringLocation] as? String ?? ""
        }
        
        self.status = dictionary[Constants.FirebaseDatabase.taskStatus] as? Int ?? 0
        
        self.budget = dictionary[Constants.FirebaseDatabase.taskBudget] as? Int ?? 0
        self.category = dictionary[Constants.FirebaseDatabase.taskCategory] as? String ?? ""
        self.description = dictionary[Constants.FirebaseDatabase.taskDescription] as? String ?? ""
        self.title = dictionary[Constants.FirebaseDatabase.taskTitle] as? String ?? ""
        self.duration = dictionary[Constants.FirebaseDatabase.taskDuration] as? Double ?? 0.0
        
        let creationSecondsFrom1970 = dictionary[Constants.FirebaseDatabase.creationDate] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: creationSecondsFrom1970)
        
        let acceptedSecondsFrom1970 = dictionary[Constants.FirebaseDatabase.acceptedDate] as? Double ?? 0
        self.acceptedDate = Date(timeIntervalSince1970: acceptedSecondsFrom1970)
        
        let completionSecondsFrom1970 = dictionary[Constants.FirebaseDatabase.completionDate] as? Double ?? 0
        self.completionDate = Date.init(timeIntervalSince1970: completionSecondsFrom1970)
        
        self.isJugglerComplete = dictionary[Constants.FirebaseDatabase.isJugglerComplete] as? Bool ?? false
        self.isUserComplete = dictionary[Constants.FirebaseDatabase.isUserComplete] as? Bool ?? false
        self.assignedJugglerId = dictionary[Constants.FirebaseDatabase.assignedJugglerId] as? String
    }
}

struct FilteredTask {
    let id: String
    let status: Int
    let creationDate: Date
    let acceptedDate: Date
    let completionDate: Date
    
    init(id: String, dictionary: [String : Any]) {
        self.id = id
        
        self.status = dictionary[Constants.FirebaseDatabase.taskStatus] as? Int ?? 0
        
        let secondsFrom1970 = dictionary[Constants.FirebaseDatabase.creationDate] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        
        let acceptedSecondsFrom1970 = dictionary[Constants.FirebaseDatabase.acceptedDate] as? Double ?? 0
        self.acceptedDate = Date(timeIntervalSince1970: acceptedSecondsFrom1970)
        
        let completionSecondsFrom1970 = dictionary[Constants.FirebaseDatabase.completionDate] as? Double ?? 0
        self.completionDate = Date.init(timeIntervalSince1970: completionSecondsFrom1970)
    }
}
