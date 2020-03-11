//
//  ReviewCell.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-03-10.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class ReviewCell: UICollectionViewCell {
    //MARK: Stored properties
    var user: User? {
        didSet {
            guard let user = self.user else {
                return
            }
            
            profileImageView.loadImage(from: user.profileImageURLString)
            firstNameLabel.text = user.firstName
        }
    }
    
    var task: Task? {
        didSet {
            guard let task = self.task else {
                return
            }
            
            taskTitleLabel.text = task.title
        }
    }
    
    var review: Review? {
        didSet {
            guard let review = self.review else {
                return
            }
            
            self.fetchTask(withId: review.taskId)
            
            Database.fetchUserFromUserID(userID: review.reviewerUserId) { (usr) in
                if let user = usr {
                    self.user = user
                }
            }
            
            self.postedTimeagoLabel.text = review.creationDate.timeAgoDisplay()
            self.displayRating(review.rating)
            self.reviewDescriptionTextView.text = review.reviewDescription
        }
    }
    
    fileprivate func fetchTask(withId taskId: String) {
        let tasksRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).child(taskId)
        tasksRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let taskDictionary = snapshot.value as? [String : Any] else {
                return
            }
            
            self.task = Task(id: snapshot.key, dictionary: taskDictionary)
            
        }) { (error) in
            print("Error fetching task for review")
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    let firstNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = .darkText
        label.numberOfLines = 0
        
        return label
    }()
    
    let postedTimeagoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.textColor = .gray
        label.numberOfLines = 1
        
        return label
    }()
    
    let taskTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = .darkText
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
    
    let reviewDescriptionTextView: UITextView = {
        let tv = UITextView()
        tv.textColor = UIColor.darkText
        tv.tintColor = .darkText
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.isScrollEnabled = true
        tv.bounces = true
        tv.isEditable = false
//        tv.layer.borderWidth = 0.5
//        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.masksToBounds = true
        
        return tv
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
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 60, height: 60)
        profileImageView.layer.cornerRadius = 60 / 2
        
        addSubview(firstNameLabel)
        firstNameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: profileImageView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 12, width: nil, height: nil)
        
        addSubview(postedTimeagoLabel)
        postedTimeagoLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 14)
        
        addSubview(taskTitleLabel)
        taskTitleLabel.anchor(top: postedTimeagoLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
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
        starStackView.anchor(top: taskTitleLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 165, height: (165 - (4 * 12)) / 5)
        
        addSubview(reviewDescriptionTextView)
        reviewDescriptionTextView.anchor(top: starStackView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: -8, paddingRight: -20, width: nil, height: nil)
//        reviewDescriptionTextView.layer.cornerRadius = 5
        
        let bottomSeperatorView = UIView()
        bottomSeperatorView.backgroundColor = .lightGray
        bottomSeperatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bottomSeperatorView)
        bottomSeperatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
    }
}
