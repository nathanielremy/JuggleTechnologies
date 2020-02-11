//
//  JugglerApplicationCompleteVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-11.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit

class JugglerApplicationCompleteVC: UIViewController {
    
    //MARK: Stored properties
    var user: User? {
        didSet {
            guard let user = self.user else {
                return
            }
            
            print(user.firstName + " " + user.lastName)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.mainBlue()
    }
}
