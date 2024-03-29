//
//  OfferCompleteVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-16.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit

class OfferCompleteVC: UIViewController {
    //MARK: Stored properties
    var offer: (String?, String?, Bool?) {
        didSet {
            guard let offer = self.offer.0, let taskTitle = self.offer.1, let isAcceptingBudget = self.offer.2 else {
                return
            }
            
            var attributedText = NSMutableAttributedString()
            
            if isAcceptingBudget {
                attributedText = NSMutableAttributedString(string: "Su aceptación de \"\(taskTitle)\"\n\n", attributes: [.font : UIFont.boldSystemFont(ofSize: 14), .foregroundColor : UIColor.gray])
            } else {
                attributedText = NSMutableAttributedString(string: "Su oferta para \"\(taskTitle)\"\n\n", attributes: [.font : UIFont.boldSystemFont(ofSize: 14), .foregroundColor : UIColor.gray])
            }
            
            attributedText.append(NSAttributedString(string: "€" + offer, attributes: [.font : UIFont.boldSystemFont(ofSize: 17), .foregroundColor : UIColor.darkText]))
            attributedText.append(NSAttributedString(string: "\n\nEsta Enviada!", attributes: [.font : UIFont.boldSystemFont(ofSize: 14), .foregroundColor : UIColor.gray]))
            
            detailsLabel.attributedText = attributedText
            
            setupNextStepsLabel()
        }
    }
    
    fileprivate func setupNextStepsLabel() {
        let attributedText = NSMutableAttributedString(string: "• ", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.darkText])
        attributedText.append(NSAttributedString(string: "Puedes ver tu oferta en la sección \"Mis Tareas\" -> Modo Juggler -> \"Pendiente\".", attributes: [.font : UIFont.systemFont(ofSize: 14), .foregroundColor : UIColor.gray]))
        
        attributedText.append(NSMutableAttributedString(string: "\n\n• ", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.darkText]))
        attributedText.append(NSAttributedString(string: "Desde esta sección, puedes enviar mensajes, modificar su oferta y cualquier otra interacción que desee.", attributes: [.font : UIFont.systemFont(ofSize: 14), .foregroundColor : UIColor.gray]))
        attributedText.append(NSMutableAttributedString(string: "\n\n• ", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.darkText]))
        attributedText.append(NSAttributedString(string: "Cuando su oferta es aceptada, la tarea sera visible en la sección \"Mis Tareas\" -> Modo Juggler -> \"Aceptada\".", attributes: [.font : UIFont.systemFont(ofSize: 14), .foregroundColor : UIColor.gray]))
        
        nextStepsDetailsLabel.attributedText = attributedText
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
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .left
        
        return label
    }()
    
    let nextStepsLabel: UILabel = {
        let label = UILabel()
        label.text = "Próximos pasos y consejos"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .darkText
        label.textAlignment = .center
        
        return label
    }()
    
    let nextStepsDetailsLabel: UILabel =  {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        
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
        navigationItem.hidesBackButton = true
        navigationItem.title = "Oferta Enviada"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "¡Listo!", style: .done, target: self, action: #selector(handleDoneButton))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.mainBlue()
        
        setupViews()
    }

    fileprivate func setupViews() {
        view.addSubview(congratulationsLabel)
        congratulationsLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 30)
        
        view.addSubview(detailsLabel)
        detailsLabel.anchor(top: congratulationsLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        view.addSubview(nextStepsLabel)
        nextStepsLabel.anchor(top: detailsLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        view.addSubview(nextStepsDetailsLabel)
        nextStepsDetailsLabel.anchor(top: nextStepsLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        view.addSubview(doneButton)
        doneButton.anchor(top: nextStepsDetailsLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 50)
        doneButton.layer.cornerRadius = 5
    }
}
