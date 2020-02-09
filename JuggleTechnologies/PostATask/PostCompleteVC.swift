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
            attributedText.append(NSAttributedString(string: "\"" + task.title + "\"", attributes: [.font : UIFont.boldSystemFont(ofSize: 18), .foregroundColor : UIColor.darkText]))
            attributedText.append(NSAttributedString(string: "\n\nEsta Publicada.", attributes: [.font : UIFont.boldSystemFont(ofSize: 14), .foregroundColor : UIColor.gray]))
            
            detailsLabel.attributedText = attributedText
        }
    }
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        return view
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        return view
    }()
    
    let congratulationsLabel: UILabel = {
        let label = UILabel()
        label.text = "¡Felicidades!"
        label.font = UIFont.boldSystemFont(ofSize: 20)
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
        button.backgroundColor = UIColor.darkText
        button.setTitle("¡Listo!", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleDoneButton), for: .touchUpInside)
        
        return button
    }()
        
    @objc fileprivate func handleDoneButton() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        view.addSubview(backgroundView)
        backgroundView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        
        view.addSubview(containerView)
        containerView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: view.frame.height * 0.4)
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        containerView.addSubview(congratulationsLabel)
        congratulationsLabel.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        containerView.addSubview(doneButton)
        doneButton.anchor(top: nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: -20, paddingRight: -20, width: nil, height: 50)
        doneButton.layer.cornerRadius = 5
        
        containerView.addSubview(detailsLabel)
        detailsLabel.anchor(top: congratulationsLabel.bottomAnchor, left: containerView.leftAnchor, bottom: doneButton.topAnchor, right: containerView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: -20, paddingRight: -20, width: nil, height: nil)
    }
}
