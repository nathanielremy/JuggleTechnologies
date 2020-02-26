//
//  AssignedTaskCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-04.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class AssignedTaskCell: UICollectionViewCell {
    //MARK: Stored properties
    var taskId: String? {
        didSet {
            guard let taskId = self.taskId else {
                return
            }
            
            let taskRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).child(taskId)
            taskRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String : Any] else {
                    return
                }
                
                let task = Task(id: snapshot.key, dictionary: dictionary)
                self.task = task
                
            }) { (error) in
                print(error)
                return
            }
        }
    }
    
    var task: Task? {
        didSet {
            guard let task = task else {
                return
            }
            
            print(task.title)
            print(task.assignedJugglerId)
            print(task.userId)
        }
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
