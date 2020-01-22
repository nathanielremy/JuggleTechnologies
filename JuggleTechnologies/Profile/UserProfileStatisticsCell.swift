//
//  UserProfileStatisticsCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-22.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit

class UserProfileStatisticsCell: UICollectionViewCell {
    
    //MARK: Stored properties
    let leftStatisticLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        
        let attributedText = NSMutableAttributedString(string: "47", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.darkText])
        attributedText.append(NSAttributedString(string: "\nTareas Terminadas", attributes: [.font : UIFont.systemFont(ofSize: 12), .foregroundColor : UIColor.darkText]))
        
        label.attributedText = attributedText
        
        return label
    }()
    
    let centerStatisticLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        
        let attributedText = NSMutableAttributedString(string: "€800", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.darkText])
        attributedText.append(NSAttributedString(string: "\nDinero Ganado", attributes: [.font : UIFont.systemFont(ofSize: 12), .foregroundColor : UIColor.darkText]))
        
        label.attributedText = attributedText
        
        return label
    }()
    
    let rightStatisticLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        
        let attributedText = NSMutableAttributedString(string: "10", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.darkText])
        attributedText.append(NSAttributedString(string: "\nTodavía no Sabemos", attributes: [.font : UIFont.systemFont(ofSize: 12), .foregroundColor : UIColor.darkText]))
        
        label.attributedText = attributedText
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        let statisticsStackView = UIStackView(arrangedSubviews: [leftStatisticLabel, centerStatisticLabel, rightStatisticLabel])
        statisticsStackView.axis = .horizontal
        statisticsStackView.distribution = .fillEqually
        
        addSubview(statisticsStackView)
        statisticsStackView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
    }
}
