//
//  UserProfileStatisticsCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-22.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit

protocol UserProfileStatisticsCellDelegate {
    func showReviews()
}

class UserProfileStatisticsCell: UICollectionViewCell {
    //MARK: Stored properties
    var delegate: UserProfileStatisticsCellDelegate?
    var isUserMode: Bool = true
    var tasksCount: Int? {
        didSet {
            guard let count = self.tasksCount else {
                return
            }
            
            let attributedText = NSMutableAttributedString(string: "\(count)", attributes: [.font : UIFont.boldSystemFont(ofSize: 24), .foregroundColor : UIColor.darkText])
            
            if self.isUserMode {
                attributedText.append(NSAttributedString(string: "\n\(count == 1 ? "Tarea Publicada" : "Tareas Publicadas")", attributes: [.font : UIFont.systemFont(ofSize: 12), .foregroundColor : UIColor.darkText]))
            } else {
                attributedText.append(NSAttributedString(string: "\n\(count == 1 ? "Tarea Completada" : "Tareas Completadas")", attributes: [.font : UIFont.systemFont(ofSize: 12), .foregroundColor : UIColor.darkText]))
            }
            
            taskStatisticsLabel.attributedText = attributedText
        }
    }
    
    var intRating: Int? {
        didSet {
            guard let rating = intRating else {
                return
            }
            
            self.displayRating(rating)
        }
    }
    
    var reviewsCount: Int? {
        didSet {
            guard let reviews = self.reviewsCount else {
                return
            }
            
            reviewsButton.setAttributedTitle(NSAttributedString(string: "\(reviews) \(reviews == 1 ? "Evaluación" : "Evaluaciones")", attributes: [.font : UIFont.systemFont(ofSize: 12), .foregroundColor : UIColor.darkText, .underlineStyle : 1]), for: .normal)
        }
    }
    
    var user: User? {
        didSet {
            guard let user = self.user else {
                return
            }
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.locale = Locale(identifier: "es_ES")
            dateFormatterPrint.dateFormat = "dd, MMM, yyyy"
            
            self.memberSinceLabel.text = "Miembro desde el " + dateFormatterPrint.string(from: user.creationDate)
        }
    }
    
    let memberSinceLabel: UILabel = {
           let label = UILabel()
           label.font = UIFont.systemFont(ofSize: 12)
           label.textColor = .darkText
           label.textAlignment = .center
           
           return label
       }()
    
    let taskStatisticsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        
        return label
    }()
    
    let oneStarRatingImage: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "unselectedStar")
        
        return iv
    }()
    
    let twoStarRatingImage: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "unselectedStar")
        
        return iv
    }()
    
    let threeStarRatingImage: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "unselectedStar")
        
        return iv
    }()
    
    let fourStarRatingImage: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "unselectedStar")
        
        return iv
    }()
    
    let fiveStarRatingImage: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "unselectedStar")
        
        return iv
    }()
    
    @objc fileprivate func displayRating(_ rating: Int) {
        oneStarRatingImage.image = #imageLiteral(resourceName: "unselectedStar").withRenderingMode(.alwaysOriginal)
        twoStarRatingImage.image = #imageLiteral(resourceName: "unselectedStar").withRenderingMode(.alwaysOriginal)
        threeStarRatingImage.image = #imageLiteral(resourceName: "unselectedStar").withRenderingMode(.alwaysOriginal)
        fourStarRatingImage.image = #imageLiteral(resourceName: "unselectedStar").withRenderingMode(.alwaysOriginal)
        fiveStarRatingImage.image = #imageLiteral(resourceName: "unselectedStar").withRenderingMode(.alwaysOriginal)
        
        if rating == 1 {
            oneStarRatingImage.image = #imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal)
        } else if rating == 2 {
            oneStarRatingImage.image = #imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal)
            twoStarRatingImage.image = #imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal)
        } else if rating == 3 {
            oneStarRatingImage.image = #imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal)
            twoStarRatingImage.image = #imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal)
            threeStarRatingImage.image = #imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal)
        } else if rating == 4 {
            oneStarRatingImage.image = #imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal)
            twoStarRatingImage.image = #imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal)
            threeStarRatingImage.image = #imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal)
            fourStarRatingImage.image = #imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal)
        } else if rating == 5 {
            oneStarRatingImage.image = #imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal)
            twoStarRatingImage.image = #imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal)
            threeStarRatingImage.image = #imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal)
            fourStarRatingImage.image = #imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal)
            fiveStarRatingImage.image = #imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal)
        }
    }
    
    lazy var reviewsButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.addTarget(self, action: #selector(handleReviewsButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleReviewsButton() {
        self.delegate?.showReviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        addSubview(memberSinceLabel)
        memberSinceLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        memberSinceLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        addSubview(taskStatisticsLabel)
        taskStatisticsLabel.anchor(top: memberSinceLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        taskStatisticsLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        let starStackView = UIStackView(arrangedSubviews: [
            oneStarRatingImage,
            twoStarRatingImage,
            threeStarRatingImage,
            fourStarRatingImage,
            fiveStarRatingImage
        ])
        starStackView.axis = .horizontal
        starStackView.distribution = .fillEqually
        starStackView.spacing = 12
        
        addSubview(starStackView)
        starStackView.anchor(top: taskStatisticsLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 30)
        starStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        addSubview(reviewsButton)
        reviewsButton.anchor(top: starStackView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        reviewsButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
}
