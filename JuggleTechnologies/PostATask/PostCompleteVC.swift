//
//  PostCompleteVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-20.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit

class PostCompleteVC: UIViewController {
    
    //MARK: Stored properties
    var task: Task? {
        didSet {
            guard let task = task else {
                return
            }
            
            let attributedText = NSMutableAttributedString(string: "Su tarea\n\n", attributes: [.font : UIFont.boldSystemFont(ofSize: 14), .foregroundColor : UIColor.gray])
            attributedText.append(NSAttributedString(string: "\"" + task.title + "\"", attributes: [.font : UIFont.boldSystemFont(ofSize: 17), .foregroundColor : UIColor.darkText]))
            attributedText.append(NSAttributedString(string: "\n\nEsta Publicada!", attributes: [.font : UIFont.boldSystemFont(ofSize: 14), .foregroundColor : UIColor.gray]))
            
            detailsLabel.attributedText = attributedText
        }
    }
    
    let congratulationsLabel: UILabel = {
        let label = UILabel()
        label.text = "¡Felicidades!"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .darkText
        label.textAlignment = .center
        
        return label
    }()
    
    let detailsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("¡Listo!", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.mainBlue()
        button.addTarget(self, action: #selector(handleDoneButton), for: .touchUpInside)
        
        return button
    }()
        
    @objc fileprivate func handleDoneButton() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        view.addSubview(congratulationsLabel)
        congratulationsLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 30)
        
        view.addSubview(detailsLabel)
        detailsLabel.anchor(top: congratulationsLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        view.addSubview(doneButton)
        doneButton.anchor(top: detailsLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 50)
        doneButton.layer.cornerRadius = 5
    }
}
