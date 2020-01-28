//
//  ChatMessageCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-27.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .blue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
