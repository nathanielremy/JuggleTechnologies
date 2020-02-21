//
//  OnGoingTaskOfferCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-18.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class OnGoingTaskOfferCell: UICollectionViewCell {
    
    //MARK: Stored properties
    var offer: Offer? {
        didSet {
            guard let offer = self.offer else {
                return
            }
            
            self.fetchOfferOwner(withUserId: offer.offerOwnerId)
            offerPriceLabel.text = "€\(offer.offerPrice)"
            timeAgoLabel.text = offer.creationDate.timeAgoDisplay()
        }
    }
    
    var offerOwner: User? {
        didSet {
            guard let user = self.offerOwner else {
                return
            }
            
            profileImageView.loadImage(from: user.profileImageURLString)
            fullNameLabel.text = user.firstName + " " + user.lastName
        }
    }
    
    fileprivate func fetchOfferOwner(withUserId userId: String) {
        Database.fetchUserFromUserID(userID: userId) { (usr) in
            if let user = usr {
                self.offerOwner = user
            }
        }
    }
    
    //MARK: Views
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .left
        label.textColor = .darkText
        label.numberOfLines = 1
        
        return label
    }()
    
    lazy var denyButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .red
        
        return button
    }()
    
    lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.mainBlue()
        
        return button
    }()
    
    let offerPriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textAlignment = .left
        label.textColor = UIColor.mainBlue()
        
        return label
    }()
    
    let timeAgoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.textColor = .gray
        label.numberOfLines = 1
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 60, height: 60)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 60 / 2
        
        addSubview(fullNameLabel)
        fullNameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        let offerInteractionsStackView = UIStackView(arrangedSubviews: [denyButton, acceptButton])
        offerInteractionsStackView.axis = .horizontal
        offerInteractionsStackView.distribution = .fillEqually
        offerInteractionsStackView.spacing = 8
        
        addSubview(offerInteractionsStackView)
        offerInteractionsStackView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: -20, width: 88, height: 40)
        offerInteractionsStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        denyButton.layer.cornerRadius = 40 / 2
        acceptButton.layer.cornerRadius = 40 / 2
        
        addSubview(offerPriceLabel)
        offerPriceLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: offerInteractionsStackView.leftAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        offerPriceLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(timeAgoLabel)
        timeAgoLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: -8, paddingRight: 0, width: nil, height: nil)
        
        let bottomSeperatorView = UIView()
        bottomSeperatorView.backgroundColor = .darkText
        addSubview(bottomSeperatorView)
        bottomSeperatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
    }
}
