//
//  JugglerApplicationStepsVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-10.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit

class JugglerApplicationStepsVC: UIViewController {
    
    //MARK: Stored properties
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .darkText
        label.text = "¿Como ser un Juggler?"
        
        return label
    }()
    
    // Must be lazy var to add tapGestureRecognizer.
    lazy var stepOneLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        
        let attributedText = NSMutableAttributedString(string: "1. ", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.darkText])
        attributedText.append(NSAttributedString(string: "Asegurate que tienes todas ", attributes: [.font : UIFont.systemFont(ofSize: 16), .foregroundColor : UIColor.gray]))
        attributedText.append(NSAttributedString(string: "Las Credenciales", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.mainBlue()]))
        attributedText.append(NSAttributedString(string: ".", attributes: [.font : UIFont.systemFont(ofSize: 16), .foregroundColor : UIColor.gray]))
        
        label.attributedText = attributedText
        
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleRequirements))
        label.addGestureRecognizer(tapGesture)
        
        return label
    }()
    
    @objc fileprivate func handleRequirements() {
        let jugglerSignupRequirementsNavVC = UINavigationController(rootViewController: JugglerSignupRequirementsVC())
        present(jugglerSignupRequirementsNavVC, animated: true, completion: nil)
    }
    
    let stepTwoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        
        let attributedText = NSMutableAttributedString(string: "2. ", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.darkText])
        attributedText.append(NSAttributedString(string: "Continua y aplica.", attributes: [.font : UIFont.systemFont(ofSize: 16), .foregroundColor : UIColor.gray]))
        
        label.attributedText = attributedText
        
        return label
    }()
    
    let stepThreeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        
        let attributedText = NSMutableAttributedString(string: "3. ", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.darkText])
        attributedText.append(NSAttributedString(string: "Una vez que hemos recibido su applicatcion, le enviaremos mas informaciones sobre los trabajos con ", attributes: [.font : UIFont.systemFont(ofSize: 16), .foregroundColor : UIColor.gray]))
        attributedText.append(NSAttributedString(string: "Juggle", attributes: [.foregroundColor : UIColor.mainBlue(), .font : UIFont.systemFont(ofSize: 16)]))
        
        label.attributedText = attributedText
        
        return label
    }()
    
    lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continuar", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.mainBlue()
        button.addTarget(self, action: #selector(handleContinueButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleContinueButton() {
        let becomeAJugglerVC = BecomeAJugglerVC()
        self.navigationController?.pushViewController(becomeAJugglerVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
        setupNavigationItems()
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.title = "Pasos para Aplicar"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(handleCancelButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Continuar", style: .plain, target: self, action: #selector(handleContinueButton))
        navigationController?.navigationBar.tintColor = .darkText
        navigationItem.rightBarButtonItem?.tintColor = UIColor.mainBlue()
    }
    
    @objc fileprivate func handleCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setupViews() {
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 30)
        
        view.addSubview(stepOneLabel)
        stepOneLabel.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 50)
        
        view.addSubview(stepTwoLabel)
        anchorHelper(forView: stepTwoLabel, topAnchor: stepOneLabel.bottomAnchor, topPadding: 0, height: 50)
        
        view.addSubview(stepThreeLabel)
        anchorHelper(forView: stepThreeLabel, topAnchor: stepTwoLabel.bottomAnchor, topPadding: 0, height: 75)
        
        view.addSubview(continueButton)
        continueButton.anchor(top: stepThreeLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 50)
        continueButton.layer.cornerRadius = 5
    }
    
    fileprivate func anchorHelper(forView anchorView: UIView, topAnchor: NSLayoutYAxisAnchor, topPadding: CGFloat, height: CGFloat) {
        return anchorView.anchor(top: topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: topPadding, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: height)
    }
}
