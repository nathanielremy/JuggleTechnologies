//
//  OnGoingTaskInteractionsHeaderCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-17.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit

protocol OnGoingTaskInteractionsHeaderCellDelegate {
    func changeFilterOption(forTag tag: Int)
}

class OnGoingTaskInteractionsHeaderCell: UICollectionViewCell {
    //MARK: Stored properties
    var delegate: OnGoingTaskInteractionsHeaderCellDelegate?
    
    let filterOptionsSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkText
        
        return view
    }()
    
    lazy var offersFilterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ofertas", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.titleLabel?.textAlignment = .center
        button.tintColor = .darkText
        button.tag = 0
        button.addTarget(self, action: #selector(handleFilterButton(forButton:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var messagesFilterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Mensajes", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.titleLabel?.textAlignment = .center
        button.tintColor = .lightGray
        button.tag = 1
        button.addTarget(self, action: #selector(handleFilterButton(forButton:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleFilterButton(forButton button: UIButton) {
        filterOptionsSeperatorView.removeFromSuperview()
        
        offersFilterButton.tintColor = .lightGray
        messagesFilterButton.tintColor = .lightGray
        
        addSubview(filterOptionsSeperatorView)
        filterOptionsSeperatorView.anchor(top: nil, left: button.leftAnchor, bottom: button.bottomAnchor, right: button.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 1)
        
        if button.tag == 0 {
            offersFilterButton.tintColor = .darkText
            offersFilterButton.isUserInteractionEnabled = false
            messagesFilterButton.isUserInteractionEnabled = true
             delegate?.changeFilterOption(forTag: 0)
        } else {
            messagesFilterButton.tintColor = .darkText
            messagesFilterButton.isUserInteractionEnabled = false
            offersFilterButton.isUserInteractionEnabled = true
             delegate?.changeFilterOption(forTag: 1)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        self.setupViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [offersFilterButton, messagesFilterButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(filterOptionsSeperatorView)
        filterOptionsSeperatorView.anchor(top: nil, left: offersFilterButton.leftAnchor, bottom: offersFilterButton.bottomAnchor, right: offersFilterButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 1)
    }
}
