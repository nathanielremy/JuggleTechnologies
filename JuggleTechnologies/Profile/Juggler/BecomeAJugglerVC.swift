//
//  BecomeAJugglerVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-09.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class BecomeAJugglerVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.mainBlue()
    }
}

extension BecomeAJugglerVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
