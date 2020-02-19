//
//  OnGoingChatMessageCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-19.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit

class OnGoingChatMessageCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
