//
//  Offer.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-16.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import Foundation

struct Offer {
    let offerOwnerId: String
    var isOfferAccepted: Bool
    var isOfferRejected: Bool
    let creationDate: Date
    let offerPrice: Int
    let taskId: String
    let isAcceptingBudget: Bool
    
    init(offerDictionary: [String : Any]) {
        self.offerOwnerId = offerDictionary[Constants.FirebaseDatabase.offerOwnerId] as? String ?? ""
        self.isOfferAccepted = offerDictionary[Constants.FirebaseDatabase.isOfferAccepted] as? Bool ?? false
        self.isOfferRejected = offerDictionary[Constants.FirebaseDatabase.isOfferRejected] as? Bool ?? false
        
        let secondsFrom1970 = offerDictionary[Constants.FirebaseDatabase.creationDate] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        
        self.offerPrice = offerDictionary[Constants.FirebaseDatabase.offerPrice] as? Int ?? 0
        self.taskId = offerDictionary[Constants.FirebaseDatabase.taskId] as? String ?? ""
        self.isAcceptingBudget = offerDictionary[Constants.FirebaseDatabase.isAcceptingBudget] as? Bool ?? false
    }
}
