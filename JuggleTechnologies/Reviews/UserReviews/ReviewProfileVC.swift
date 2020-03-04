//
//  ReviewProfileVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-03-03.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class ReviewProfileVC: UIViewController {
    
    //MARK: Stored properties
    var intRating: Int = 0
    var isReviewingUser = true
    
    var reviewTextViewBottomAnchor: NSLayoutConstraint?
    
    var user: User? {
        didSet {
            guard let user = self.user else {
                return
            }
            
            profileImageView.loadImage(from: user.profileImageURLString)
            fullNameLabel.text = user.firstName + " " + user.lastName
            publiqueReviewLabel.text = "Deje una evaluación pública para \(user.firstName)"
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    var task: Task? {
        didSet {
            guard let task = self.task else {
                return
            }
            
            postedTimeagoLabel.text = task.completionDate.timeAgoDisplay()
            taskTitleLabel.text = task.title
        }
    }
    
    let postedTimeagoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.textColor = .lightGray
        label.numberOfLines = 1
        
        return label
    }()
    
    let taskTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .left
        label.textColor = .darkText
        label.numberOfLines = 2
        
        return label
    }()
    
    let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkText
        label.textAlignment = .center
        
        return label
    }()
    
    let starRatingImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "0StarRating").withTintColor(UIColor.mainBlue())
        iv.clipsToBounds = true
        
        return iv
    }()
    
    lazy var oneStarRatingButton: UIButton = {
        let button = UIButton(type: .system)
        button.tag = 1
        button.addTarget(self, action: #selector(handleNewRating(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var twoStarRatingButton: UIButton = {
        let button = UIButton(type: .system)
        button.tag = 2
        button.addTarget(self, action: #selector(handleNewRating(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var threeStarRatingButton: UIButton = {
        let button = UIButton(type: .system)
        button.tag = 3
        button.addTarget(self, action: #selector(handleNewRating(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var fourStarRatingButton: UIButton = {
        let button = UIButton(type: .system)
        button.tag = 4
        button.addTarget(self, action: #selector(handleNewRating(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var fiveStarRatingButton: UIButton = {
        let button = UIButton(type: .system)
        button.tag = 5
        button.addTarget(self, action: #selector(handleNewRating(_:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleNewRating(_ button: UIButton) {
        self.intRating = button.tag
        print(button.tag)
    }
    
    let publiqueReviewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .darkText
        
        return label
    }()
    
    let reviewCaracterCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "0/500"
        
        return label
    }()
    
    lazy var reviewTextView: UITextView = {
        let tv = UITextView()
        tv.text = "Entre 10 y 500 caracteres"
        tv.textColor = UIColor.lightGray
        tv.layer.borderWidth = 0.5
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.layer.masksToBounds = true
        tv.isScrollEnabled = true
        tv.bounces = true
        tv.inputAccessoryView = makeTextFieldToolBar()
        
        //Remove placeholder text when user enters text methods in delegate
        tv.delegate = self
        
        return tv
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
        print("Handling doneButton")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupHideKeyBoardOnTapGesture()
        setupNavigationBar()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyBoardObservers()
    }
    
    // Never forget to remove observers
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupKeyBoardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyBoardWillShow(notifaction: NSNotification) {
        //Get the height of the keyBoard
        let keyBoardFrame = (notifaction.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyBoardDuration: Double = (notifaction.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        if let height = keyBoardFrame?.height {
            self.reviewTextViewBottomAnchor?.constant = -height + view.safeAreaInsets.bottom + 50
            self.fullNameLabel.textColor = UIDevice().getDeviceSafeAreaInsetsHeightEstimation() == 88 ? UIColor.darkText : UIColor.clear
            self.publiqueReviewLabel.textColor = UIColor.clear
            //Animate the containerView going up
            UIView.animate(withDuration: keyBoardDuration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func handleKeyBoardWillHide(notifaction: NSNotification) {
        //Move the keyboard back down
        let keyBoardDuration: Double = (notifaction.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        self.reviewTextViewBottomAnchor?.constant = -50
        self.fullNameLabel.textColor = .darkText
        self.publiqueReviewLabel.textColor = .darkText
        //Animate the containerView going down
        UIView.animate(withDuration: keyBoardDuration) {
            self.view.layoutIfNeeded()
            
        }
    }
    
    fileprivate func setupNavigationBar() {
        navigationItem.title = "Evaluación"
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(handleCancelButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "¡Listo!", style: .plain, target: self, action: #selector(handleDoneButton))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.mainBlue()
    }
    
    @objc fileprivate func handleCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setupViews() {
        view.addSubview(postedTimeagoLabel)
        postedTimeagoLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: -40, width: nil, height: nil)
        
        view.addSubview(taskTitleLabel)
        taskTitleLabel.anchor(top: postedTimeagoLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 40, paddingBottom: 0, paddingRight: -40, width: nil, height: nil)
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: taskTitleLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        profileImageView.layer.cornerRadius = 100 / 2
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(fullNameLabel)
        fullNameLabel.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: nil)
        
        view.addSubview(starRatingImageView)
        starRatingImageView.anchor(top: fullNameLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 250, height: 40)
        starRatingImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let starRatingButtonStackView = UIStackView(arrangedSubviews: [
            oneStarRatingButton,
            twoStarRatingButton,
            threeStarRatingButton,
            fourStarRatingButton,
            fiveStarRatingButton
        ])
        starRatingButtonStackView.axis = .horizontal
        starRatingButtonStackView.distribution = .fillEqually
        
        view.addSubview(starRatingButtonStackView)
        starRatingButtonStackView.anchor(top: starRatingImageView.topAnchor, left: starRatingImageView.leftAnchor, bottom: starRatingImageView.bottomAnchor, right: starRatingImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        
        view.addSubview(doneButton)
        doneButton.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: -20, paddingRight: -20, width: nil, height: 50)
        doneButton.layer.cornerRadius = 5
        
        view.addSubview(reviewTextView)
        reviewTextView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 100)
        reviewTextView.layer.cornerRadius = 5
        
        view.addSubview(reviewCaracterCountLabel)
        reviewCaracterCountLabel.anchor(top: nil, left: nil, bottom: reviewTextView.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: -20, width: nil, height: nil)
        
        view.addSubview(publiqueReviewLabel)
        publiqueReviewLabel.anchor(top: nil, left: nil, bottom: reviewTextView.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -26, paddingRight: 0, width: nil, height: nil)
        publiqueReviewLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        reviewTextViewBottomAnchor = reviewTextView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -50)
        reviewTextViewBottomAnchor?.isActive = true
    }
    
    fileprivate func makeTextFieldToolBar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(handleTextFieldDoneButton))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        return toolBar
    }
}

extension ReviewProfileVC: UITextViewDelegate {
    // When done button is clicked on keyboard input accessory view
    @objc func handleTextFieldDoneButton() {
        view.endEditing(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let review = reviewTextView.text, textView == reviewTextView {
            reviewCaracterCountLabel.text = review.count == 1 ? "0/500" : "\(review.count)/500"
            if review.count > 499 {
                reviewTextView.text.removeLast()
                reviewCaracterCountLabel.text = "\(review.count)/500"
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.darkText
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Entre 10 y 500 caracteres"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func setupHideKeyBoardOnTapGesture() {
         let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTextFieldDoneButton))
          tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
}