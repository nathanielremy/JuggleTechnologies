//
//  DashboardChatLogVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-23.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class DashboardChatLogVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    //MARK: Stored properties
    var messages = [Message]()
    var containerViewBottomAnchor: NSLayoutConstraint?
    var currentUser: User? {
        didSet {
            guard let _ = self.currentUser else {
                self.navigationController?.popViewController(animated: false)
                return
            }
        }
    }
    
    var chatPartner: User? {
        didSet {
            guard let juggler = self.chatPartner else {
                self.navigationController?.popViewController(animated: false)
                return
            }
            
            self.navigationItem.title = juggler.firstName + " " + juggler.lastName
            
            if let _ = self.task {
                self.observeMessages(forChatPartnerId: juggler.userId)
            }
        }
    }
    
    var task: Task? {
        didSet {
            guard let _ = self.task else {
                self.navigationController?.popViewController(animated: false)
                return
            }
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Detalles", style: .plain, target: self, action: #selector(handleRightBarButtonItem))
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.mainBlue()
            
            if let chatPartner = self.chatPartner {
                self.observeMessages(forChatPartnerId: chatPartner.userId)
            }
        }
    }
    
    @objc fileprivate func handleRightBarButtonItem() {
        guard let task = task else {
            return
        }
        
        let taskDetailsVC = TaskDetailsVC()
        taskDetailsVC.task = task
        Database.fetchUserFromUserID(userId: task.userId) { (usr) in
            if let user = usr {
                taskDetailsVC.user = user
            }
        }
        
        let taskDetailsNavVC = UINavigationController(rootViewController: taskDetailsVC)
        self.present(taskDetailsNavVC, animated: true, completion: nil)
    }
    
    //MARK: Views
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Enviar", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.tintColor = UIColor.mainBlue()
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSendButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleSendButton() {
        guard let text = self.messageTextField.text, text != "", text != " " else {
            self.messageTextField.text = ""
            self.sendButton.isEnabled = false
            return
        }
        
        //sendMessage function definition above viewDidLoad
        self.sendMessage(withText: text)
    }
    
    lazy var messageTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Escribe un mensaje..."
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextFieldChanges), for: .editingChanged)
        
        return tf
    }()
    
    @objc fileprivate func handleTextFieldChanges() {
        if let text = messageTextField.text, text != "" {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
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
            self.containerViewBottomAnchor?.constant = -height + view.safeAreaInsets.bottom
            //Animate the containerView going up
            UIView.animate(withDuration: keyBoardDuration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func handleKeyBoardWillHide(notifaction: NSNotification) {
        //Move the keyboard back down
        let keyBoardDuration: Double = (notifaction.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        self.containerViewBottomAnchor?.constant = 0
        //Animate the containerView going down
        UIView.animate(withDuration: keyBoardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    let noResultsView: UIView = {
        let view = UIView.noResultsView(withText: "No hay mensajes en este momento.")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    fileprivate func showNoResultsFoundView(andReload reload: Bool) {
        self.collectionView.bounces = false
        self.collectionView?.refreshControl?.endRefreshing()
        DispatchQueue.main.async {
            if reload {
                self.collectionView?.reloadData()
            }
            self.collectionView?.addSubview(self.noResultsView)
            self.noResultsView.centerYAnchor.constraint(equalTo: (self.collectionView?.centerYAnchor)!).isActive = true
            self.noResultsView.centerXAnchor.constraint(equalTo: (self.collectionView?.centerXAnchor)!).isActive = true
        }
    }
    
    fileprivate func removeNoResultsView(andReload reload: Bool) {
        self.collectionView.bounces = true
        self.collectionView?.refreshControl?.endRefreshing()
        DispatchQueue.main.async {
            self.noResultsView.removeFromSuperview()
            if reload {
                self.collectionView?.reloadData()
            }
            self.collectionView.scrollToItem(at: IndexPath(item: self.messages.count - 1, section: self.collectionView.numberOfSections - 1), at: .top, animated: true)
        }
    }
    
    fileprivate func sendMessage(withText text: String) {
        self.disableViews(true)
        
        guard let task = self.task else {
            self.disableViews(false)
            let alert = UIAlertController(title: "La Tarea ha Sido Eliminada", message: "Ir atrás", preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .default) { (_) in
                self.navigationController?.popToRootViewController(animated: true)
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)

            return
        }
        
        guard let fromUserId = Auth.auth().currentUser?.uid, let toUserId = self.chatPartner?.userId else {
            self.disableViews(false)
            let alert = UIView.okayAlert(title: "Error de Envío", message: "Se produjo un error al intentar enviar su mensaje. Salga e intente nuevamente.")
            self.present(alert, animated: true) {
                // Dismiss or pop view?
                if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            return
        }
        
        let messageValues: [String : Any] = [
            Constants.FirebaseDatabase.text : text,
            Constants.FirebaseDatabase.fromUserId : fromUserId,
            Constants.FirebaseDatabase.toUserId : toUserId,
            Constants.FirebaseDatabase.creationDate : Date().timeIntervalSince1970,
            Constants.FirebaseDatabase.taskId : task.id,
            Constants.FirebaseDatabase.taskOwnerUserId : task.userId
        ]
        
        // Store message under /messages/randomId
        let messsagesRef = Database.database().reference().child(Constants.FirebaseDatabase.messagesRef)
        let messageIdRef = messsagesRef.childByAutoId()
        messageIdRef.updateChildValues(messageValues) { (err, _) in
            if let error = err {
                print("Error pushing message/randomId to database: ", error)
                DispatchQueue.main.async {
                    self.disableViews(false)
                    let alert = UIView.okayAlert(title: "No se Puede Enviar este Mensaje", message: "Sal e intenta nuevamente.")
                    self.present(alert, animated: true) {
                        // Dismiss or pop view?
                        if let navController = self.navigationController {
                            navController.popViewController(animated: true)
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                return
            }
        }
        
        // Store a reference to message in database for the sender
        let messageId = messageIdRef.key ?? "Failed to unwrap messageIdRef.key"
        let senderRef = Database.database().reference().child(Constants.FirebaseDatabase.userMessagesRef).child(fromUserId).child(task.id).child(toUserId)
        senderRef.updateChildValues([messageId : 1]) { (err, _) in
            if let error = err {
                print("Error storing reference to message for sender: ", error)
                DispatchQueue.main.async {
                    self.disableViews(false)
                    let alert = UIView.okayAlert(title: "No se Puede Enviar este Mensaje", message: "Sal e intenta nuevamente.")
                    self.present(alert, animated: true) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                return
            }
        }
        
        // Store a reference to message in database for the receiver
        let recipientRef = Database.database().reference().child(Constants.FirebaseDatabase.userMessagesRef).child(toUserId).child(task.id).child(fromUserId)
        recipientRef.updateChildValues([messageId: 1]) { (err, _) in
            if let error = err {
                print("Error storing reference to message for receiver: ", error)
                DispatchQueue.main.async {
                    self.disableViews(false)
                    let alert = UIView.okayAlert(title: "No se Puede Enviar este Mensaje", message: "Sal e intenta nuevamente.")
                    self.present(alert, animated: true) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                return
            }
        }
        
        self.disableViews(false)
        self.messageTextField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        
        //Register collectionViewCells
        collectionView?.register(DashboardChatMessageCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.dashboardChatMessageCell)
        collectionView?.contentInset = UIEdgeInsets.init(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 58, right: 0)
        
        self.fetchCurrentUser()
        self.setupInputComponents()
    }
    
    fileprivate func fetchCurrentUser() {
        let currentUserId = Auth.auth().currentUser?.uid ?? "No currentUserId"
        userCache.removeValue(forKey: currentUserId)
        Database.fetchUserFromUserID(userId: currentUserId) { (usr) in
            self.currentUser = usr
        }
    }
    
    fileprivate func setupInputComponents() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        containerView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 50)
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        
        containerView.addSubview(sendButton)
        sendButton.anchor(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: nil)
        
        containerView.addSubview(messageTextField)
        messageTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = .black
        
        containerView.addSubview(seperatorView)
        seperatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    fileprivate func observeMessages(forChatPartnerId chatPartnerId: String) {
        self.disableViews(true)
        // Fetch messages for currentUserId and from chatPartnerId
        guard let currentUserId = Auth.auth().currentUser?.uid, let task = self.task else {
            print("No current user id")
            self.disableViews(false)
            
            return
        }
        
        let userMessagesRef = Database.database().reference().child(Constants.FirebaseDatabase.userMessagesRef).child(currentUserId).child(task.id).child(chatPartnerId)
        
        self.disableViews(false)
        
        userMessagesRef.observe(.childAdded, with: { (messagesSnapshot) in
            let messageId = messagesSnapshot.key
            let messagesRef = Database.database().reference().child(Constants.FirebaseDatabase.messagesRef).child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (messageSnapshot) in
                
                guard let messageDictionary = messageSnapshot.value as? [String : Any] else {
                    self.disableViews(false)
                    return
                }
                
                let message = Message(key: messageSnapshot.key, dictionary: messageDictionary)
                
                if message.chatPartnerId() == self.chatPartner?.userId {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.disableViews(false)
                        self.collectionView.reloadData()
                        //Make collectionView scroll to bottom when message is sent and/or recieved
                        self.collectionView.scrollToItem(at: IndexPath(item: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                    }
                }
            }) { (error) in
                print("Error fetching userMessages for user: \(currentUserId): ", error)
                self.disableViews(false)
                return
            }
        }) { (error) in
            print("Error fetching userMessages for user: \(currentUserId): ", error)
            self.disableViews(false)
            return
        }
    }
    
    //MARK: CollectionView Delegate Methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if messages.count == 0 {
            self.showNoResultsFoundView(andReload: false)
        } else {
            self.removeNoResultsView(andReload: false)
        }
        
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dashboardChatMessageCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.dashboardChatMessageCell, for: indexPath) as? DashboardChatMessageCell else {
            return UICollectionViewCell()
        }

        let message = self.messages[indexPath.item]
        
        dashboardChatMessageCell.textView.text = message.text
        
        setupChatMessageCell(cell: dashboardChatMessageCell, message: message)
        
        //Modifyig the chat bubble's width
        let text = self.messages[indexPath.item].text
        dashboardChatMessageCell.chatBubbleWidth?.constant = estimatedFrameForChatBubble(fromText: text).width + 32
        
        dashboardChatMessageCell.delegate = self
        
        return dashboardChatMessageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80

        //Modifying the chat bubble's height
        let text = self.messages[indexPath.item].text
        height = self.estimatedFrameForChatBubble(fromText: text).height + 20

        return CGSize(width: view.frame.width, height: height)
    }
    
    fileprivate func setupChatMessageCell(cell: DashboardChatMessageCell, message: Message) {
        if let profileImageURLString = self.chatPartner?.profileImageURLString {
            cell.profileImageView.loadImage(from: profileImageURLString)
        }
        
        if message.fromUserId == Auth.auth().currentUser?.uid {
            //Display blue chatBubble
            cell.chatBubble.backgroundColor = UIColor.mainBlue()
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            cell.chatBubbleLeftAnchor?.isActive = false
            cell.chatBubbleRightAnchor?.isActive = true
        } else {
            //Display gray chatBubble
            cell.chatBubble.backgroundColor = UIColor.chatBubbleGray()
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            cell.chatBubbleLeftAnchor?.isActive = true
            cell.chatBubbleRightAnchor?.isActive = false
        }
    }
    
    fileprivate func estimatedFrameForChatBubble(fromText text: String) -> CGRect {
        // height must be something really tall and width is the same as chatBubble in ChatMessageCell
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func disableViews(_ bool: Bool) {
        DispatchQueue.main.async {
            if let text = self.messageTextField.text, text == "" {
                self.sendButton.isEnabled = false
            } else {
                self.sendButton.isEnabled = !bool
            }
            
            self.messageTextField.isEnabled = !bool
            self.collectionView?.isUserInteractionEnabled = !bool
        }
    }
}

//MARK: UITextFieldDelegate
extension DashboardChatLogVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        return true
    }
}

//MARK: ChatMessageCell Delegate methods
extension DashboardChatLogVC: ChatMessageCellDelegate {
    func handleProfileImageView() {
        
        guard let juggler = self.chatPartner else {
            return
        }
        
        let profileVC = ProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        profileVC.user = juggler
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
