//
//  JuggleAppReviewsVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-03-05.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class JuggleAppReviewsVC: UIViewController {
    
    //MARK: Stored properties
    var intRating: Int = 0
    
    var reviewTextViewBottomAnchor: NSLayoutConstraint?
    
    var task: Task? {
        didSet {
            guard let _ = self.task else {
                return
            }
            
            let attributedText = NSMutableAttributedString(string: "Cómo fue tu experiencia con\n\n", attributes: [.foregroundColor : UIColor.darkText, .font : UIFont.boldSystemFont(ofSize: 18)])
            attributedText.append(NSAttributedString(string: "Juggle", attributes: [.foregroundColor : UIColor.mainBlue(), .font : UIFont.boldSystemFont(ofSize: 26)]))
            
            detailsLabel.attributedText = attributedText
        }
    }
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = UIColor.mainBlue()
        ai.translatesAutoresizingMaskIntoConstraints = false
        
        return ai
    }()
    
    func animateAndShowActivityIndicator(_ bool: Bool) {
        if bool {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
        
        self.view.isUserInteractionEnabled = !bool
    }
    
    let detailsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var oneStarRatingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "unselectedStar"), for: .normal)
        button.tag = 1
        button.addTarget(self, action: #selector(handleNewRating(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var twoStarRatingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "unselectedStar"), for: .normal)
        button.tag = 2
        button.addTarget(self, action: #selector(handleNewRating(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var threeStarRatingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "unselectedStar"), for: .normal)
        button.tag = 3
        button.addTarget(self, action: #selector(handleNewRating(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var fourStarRatingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "unselectedStar"), for: .normal)
        button.tag = 4
        button.addTarget(self, action: #selector(handleNewRating(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var fiveStarRatingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "unselectedStar"), for: .normal)
        button.tag = 5
        button.addTarget(self, action: #selector(handleNewRating(_:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleNewRating(_ button: UIButton) {
        self.intRating = button.tag
        
        oneStarRatingButton.setImage(#imageLiteral(resourceName: "unselectedStar").withRenderingMode(.alwaysOriginal), for: .normal)
        twoStarRatingButton.setImage(#imageLiteral(resourceName: "unselectedStar").withRenderingMode(.alwaysOriginal), for: .normal)
        threeStarRatingButton.setImage(#imageLiteral(resourceName: "unselectedStar").withRenderingMode(.alwaysOriginal), for: .normal)
        fourStarRatingButton.setImage(#imageLiteral(resourceName: "unselectedStar").withRenderingMode(.alwaysOriginal), for: .normal)
        fiveStarRatingButton.setImage(#imageLiteral(resourceName: "unselectedStar").withRenderingMode(.alwaysOriginal), for: .normal)
        
        if button.tag == 1 {
            oneStarRatingButton.setImage(#imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal), for: .normal)
        } else if button.tag == 2 {
            oneStarRatingButton.setImage(#imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal), for: .normal)
            twoStarRatingButton.setImage(#imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal), for: .normal)
        } else if button.tag == 3 {
            oneStarRatingButton.setImage(#imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal), for: .normal)
            twoStarRatingButton.setImage(#imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal), for: .normal)
            threeStarRatingButton.setImage(#imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal), for: .normal)
        } else if button.tag == 4 {
            oneStarRatingButton.setImage(#imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal), for: .normal)
            twoStarRatingButton.setImage(#imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal), for: .normal)
            threeStarRatingButton.setImage(#imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal), for: .normal)
            fourStarRatingButton.setImage(#imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal), for: .normal)
        } else if button.tag == 5 {
            oneStarRatingButton.setImage(#imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal), for: .normal)
            twoStarRatingButton.setImage(#imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal), for: .normal)
            threeStarRatingButton.setImage(#imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal), for: .normal)
            fourStarRatingButton.setImage(#imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal), for: .normal)
            fiveStarRatingButton.setImage(#imageLiteral(resourceName: "selectedStar").withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    
    let reviewDetailsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .darkText
        label.numberOfLines = 0
        label.text = "Cuéntanos qué podemos mejorar o qué te gustó de tu experiencia con Juggle!"
        
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
        tv.text = "Máximo 500 caracteres"
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
        guard intRating > 0, intRating < 6, let currentUserId = Auth.auth().currentUser?.uid, let task = self.task else {
            let alert = UIView.okayAlert(title: "Deja una evaluación usando las estrellas", message: "")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        self.animateAndShowActivityIndicator(true)
        
        let isUserPerspective = task.userId == currentUserId ? true : false
        
        var reviewValues: [String : Any] = [
            Constants.FirebaseDatabase.rating : intRating,
            Constants.FirebaseDatabase.reviewerUserId : currentUserId,
            Constants.FirebaseDatabase.creationDate : Date().timeIntervalSince1970,
            Constants.FirebaseDatabase.taskId : task.id,
            Constants.FirebaseDatabase.isFromUserPerspective : isUserPerspective
        ]
        
        if let reviewText = reviewTextView.text, reviewText != "", reviewText != " ", reviewText != "Máximo 500 caracteres" {
            reviewValues[Constants.FirebaseDatabase.reviewDescription] = reviewText
        }
        
        sendReview(fromUserId: currentUserId, withReviewValues: reviewValues)
    }
    
    fileprivate func sendReview(fromUserId userId: String, withReviewValues reviewValues: [String : Any]) {
        let juggleIOSAppReviewsRef = Database.database().reference().child(Constants.FirebaseDatabase.juggleIOSAppReviewsRef)
        let juggleIOSAppReviewsIdRef = juggleIOSAppReviewsRef.childByAutoId()
        juggleIOSAppReviewsIdRef.updateChildValues(reviewValues) { (err, _) in
            if let error = err {
                print("Error sending juggleIOSAppReview: \(error)")
                self.animateAndShowActivityIndicator(false)
                let alert = UIView.okayAlert(title: "Error al Grabar", message: "Sal e intente nuevamente")
                self.present(alert, animated: true, completion: nil)
            }
            
            self.animateAndShowActivityIndicator(false)
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
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
        setupActivityIndicator()
    }
    
    fileprivate func setupActivityIndicator() {
        view.addSubview(self.activityIndicator)
        self.activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
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
            self.reviewTextViewBottomAnchor?.constant = -height + view.safeAreaInsets.bottom + 70
            //Animate the containerView going up
            UIView.animate(withDuration: keyBoardDuration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func handleKeyBoardWillHide(notifaction: NSNotification) {
        //Move the keyboard back down
        let keyBoardDuration: Double = (notifaction.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        self.reviewTextViewBottomAnchor?.constant = -40
        //Animate the containerView going down
        UIView.animate(withDuration: keyBoardDuration) {
            self.view.layoutIfNeeded()
            
        }
    }
    
    fileprivate func setupNavigationBar() {
        navigationItem.title = "Evaluación"
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(handleCancelButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "¡Listo!", style: .done, target: self, action: #selector(handleDoneButton))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.mainBlue()
    }
    
    @objc fileprivate func handleCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setupViews() {
        view.addSubview(detailsLabel)
        detailsLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: -40, width: nil, height: nil)
        
        let starStackView = UIStackView(arrangedSubviews: [
            oneStarRatingButton,
            twoStarRatingButton,
            threeStarRatingButton,
            fourStarRatingButton,
            fiveStarRatingButton
        ])
        starStackView.axis = .horizontal
        starStackView.distribution = .fillEqually
        
        view.addSubview(starStackView)
        starStackView.anchor(top: detailsLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 60, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 250, height: 40)
        starStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(doneButton)
        doneButton.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: -20, paddingRight: -20, width: nil, height: 50)
        doneButton.layer.cornerRadius = 5
        
        view.addSubview(reviewTextView)
        reviewTextView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 100)
        reviewTextView.layer.cornerRadius = 5
        
        view.addSubview(reviewCaracterCountLabel)
        reviewCaracterCountLabel.anchor(top: nil, left: nil, bottom: reviewTextView.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: -20, width: nil, height: nil)
        
        view.addSubview(reviewDetailsLabel)
        reviewDetailsLabel.anchor(top: nil, left: view.leftAnchor, bottom: reviewTextView.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: -35, paddingRight: -20, width: nil, height: nil)
        
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

extension JuggleAppReviewsVC: UITextViewDelegate {
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
            textView.text = "Máximo 500 caracteres"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func setupHideKeyBoardOnTapGesture() {
         let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTextFieldDoneButton))
          tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
}
