//
//  Message.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-05.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

struct Message {
    
    let messageKey: String
    let taskId: String
    let fromUserId: String
    let toUserId: String
    let text: String
    let creationDate: Date
    let taskOwnerId: String
    
    func chatPartnerId() -> String? {
        return self.toUserId == Auth.auth().currentUser?.uid ? self.fromUserId : self.toUserId
    }
    
    init(key: String, dictionary: [String : Any]) {
        self.messageKey = key
        self.taskId = dictionary[Constants.FirebaseDatabase.taskId] as? String ?? ""
        self.fromUserId = dictionary[Constants.FirebaseDatabase.fromUserId] as? String ?? ""
        self.toUserId = dictionary[Constants.FirebaseDatabase.toUserId] as? String ?? ""
        self.text = dictionary[Constants.FirebaseDatabase.text] as? String ?? ""
        self.taskOwnerId = dictionary[Constants.FirebaseDatabase.taskOwnerUserId] as? String ?? ""
        
        let secondsFrom1970 = dictionary[Constants.FirebaseDatabase.creationDate] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
