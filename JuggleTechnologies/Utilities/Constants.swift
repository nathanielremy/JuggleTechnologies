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
        static let profileImages = "profileImages"
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
        static let description = "description"
        
        static let creationDate = "creationDate"
        
        static let tasksRef = "tasks"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let stringLocation = "stringLocation"
        static let taskTitle = "taskTitle"
        static let taskDescription = "taskDescription"
        static let taskCategory = "taskCategory"
        static let taskDuration = "taskDuration"
        static let taskBudget = "taskBudget"
        static let isTaskOnline = "isTaskOnline"
        static let taskStatus = "taskStatus"
        static let isTaskReviewed = "isTaskReviewed"
        static let isJugglerComplete = "isJugglerComplete"
        static let isUserComplete = "isUserComplete"
        
        static let userTasksRef = "userTasks"
        
        static let messagesRef = "messages"
        static let userMessagesRef = "userMessages"
        static let text = "text"
        static let fromUserId = "fromUserId"
        static let toUserId = "toUserId"
        static let taskId = "taskId"
        static let taskOwnerUserId = "taskOwnerUserId"
    }
    
    struct TaskCategories {
        static let all = "Todo"
        static let cleaning = "Limpieza"
        static let delivery = "Entrega"
        static let moving = "Mudanza"
        static let computerIT = "Computer/IT"
        static let photoVideo = "Foto/Vídeo"
        static let handyMan = "Mantenimiento"
        static let assembly = "Montaje"
        static let pets = "Mascotas"
        static let anything = "Lo Que Sea"
        
        static func categoryArray() -> [String] {
            return [self.cleaning, self.handyMan, self.computerIT, self.photoVideo, self.assembly, self.delivery, self.moving, self.pets, self.anything]
        }
    }
    
    struct CollectionViewCellIds {
        static let userProfileHeaderCell = "userProfileHeaderCell"
        static let userProfileStatisticsCell = "userProfileStatisticsCell"
        static let userSelfDescriptionCell = "userSelfDescriptionCell"
        static let viewTaskCollectionViewCell = "viewTaskCollectionViewCell"
        static let viewTasksHeaderCell = "viewTasksHeaderCell"
        static let chatMessageCellId = "chatMessageCellId"
    }
    
    struct BarcalonaCoordinates {
        static let maximumLatitude: Double = 41.5
        static let minimumLatitude: Double = 41.0
        static let maximumLongitude: Double = 2.21
        static let minimumLongitude: Double = 2.0
    }
    
    struct ErrorDescriptions {
        static let invalidPassword = "The password is invalid or the user does not have a password."
        static let invalidEmailAddress = "There is no user record corresponding to this identifier. The user may have been deleted."
        static let networkError = "Network error (such as timeout, interrupted connection or unreachable host) has occurred."
        static let unavailableEmail = "The email address is already in use by another account."
    }
}
