//
//  JugglerSignupRequirementsVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-10.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit

class JugglerSignupRequirementsVC: UIViewController {
    
    //MARK: Stored properties
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .white
        
        return sv
    }()
    
    let firstRequirementLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        
        let attributedText = NSMutableAttributedString(string: "• ", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.darkText])
        attributedText.append(NSAttributedString(string: "Tener al menos ", attributes: [.font : UIFont.systemFont(ofSize: 16), .foregroundColor : UIColor.gray]))
        attributedText.append(NSAttributedString(string: "18 años", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.mainBlue()]))
        attributedText.append(NSAttributedString(string: ".", attributes: [.font : UIFont.systemFont(ofSize: 16), .foregroundColor : UIColor.gray]))
        
        label.attributedText = attributedText
        
        return label
    }()
    
    let secondRequirementLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        
        let attributedText = NSMutableAttributedString(string: "• ", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.darkText])
        attributedText.append(NSAttributedString(string: "Vivir o trabajar ", attributes: [.font : UIFont.systemFont(ofSize: 16), .foregroundColor : UIColor.gray]))
        attributedText.append(NSAttributedString(string: "en Barcelona ", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.mainBlue()]))
        attributedText.append(NSAttributedString(string: "o ", attributes: [.font : UIFont.systemFont(ofSize: 16), .foregroundColor : UIColor.gray]))
        attributedText.append(NSAttributedString(string: "en su alrededor", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.mainBlue()]))
        attributedText.append(NSAttributedString(string: ".", attributes: [.font : UIFont.systemFont(ofSize: 16), .foregroundColor : UIColor.gray]))
        
        label.attributedText = attributedText
        
        return label
    }()
    
    let thirdRequirementLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        
        let attributedText = NSMutableAttributedString(string: "• ", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.darkText])
        attributedText.append(NSAttributedString(string: "Tener ", attributes: [.font : UIFont.systemFont(ofSize: 16), .foregroundColor : UIColor.gray]))
        attributedText.append(NSAttributedString(string: "cuenta bancaria", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.mainBlue()]))
        attributedText.append(NSAttributedString(string: ".", attributes: [.font : UIFont.systemFont(ofSize: 16), .foregroundColor : UIColor.gray]))
        
        label.attributedText = attributedText
        
        return label
    }()
    
    let fourthRequirementLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        
        let attributedText = NSMutableAttributedString(string: "• ", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.darkText])
        attributedText.append(NSAttributedString(string: "Tener ", attributes: [.font : UIFont.systemFont(ofSize: 16), .foregroundColor : UIColor.gray]))
        attributedText.append(NSAttributedString(string: "DNI", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.mainBlue()]))
        attributedText.append(NSAttributedString(string: ".", attributes: [.font : UIFont.systemFont(ofSize: 16), .foregroundColor : UIColor.gray]))
        
        label.attributedText = attributedText
        
        return label
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("¡Listo!", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.mainBlue()
        button.addTarget(self, action: #selector(handleDoneButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleDoneButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationItem.title = "Credenciales"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(handleCancel))
        navigationController?.navigationBar.tintColor = .darkText
        
        setupViews()
    }
    
    @objc fileprivate func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setupViews() {
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
        
        scrollView.addSubview(firstRequirementLabel)
        anchorHelper(forView: firstRequirementLabel, topAnchor: scrollView.topAnchor, topPadding: 50, height: 50)
        
        scrollView.addSubview(secondRequirementLabel)
        anchorHelper(forView: secondRequirementLabel, topAnchor: firstRequirementLabel.bottomAnchor, topPadding: 0, height: 50)
        
        scrollView.addSubview(thirdRequirementLabel)
        anchorHelper(forView: thirdRequirementLabel, topAnchor: secondRequirementLabel.bottomAnchor, topPadding: 0, height: 50)
        
        scrollView.addSubview(fourthRequirementLabel)
        anchorHelper(forView: fourthRequirementLabel, topAnchor: thirdRequirementLabel.bottomAnchor, topPadding: 0, height: 50)
        
        scrollView.addSubview(doneButton)
        anchorHelper(forView: doneButton, topAnchor: fourthRequirementLabel.bottomAnchor, topPadding: 50, height: 50)
        doneButton.layer.cornerRadius = 5
    }
    
    fileprivate func anchorHelper(forView anchorView: UIView, topAnchor: NSLayoutYAxisAnchor, topPadding: CGFloat, height: CGFloat) {
        return anchorView.anchor(top: topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: topPadding, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: height)
    }
}
