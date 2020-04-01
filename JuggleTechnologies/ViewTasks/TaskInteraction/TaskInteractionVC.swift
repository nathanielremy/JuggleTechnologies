//
//  TaskInteractionVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-27.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class TaskInteractionVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //MARK: Stored properties
    var messages = [Message]()
    let taskInteractionView = TaskInteractionDetailsView()
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    var jugglerOffer: Offer? {
        didSet {
            guard let offer = self.jugglerOffer else {
                return
            }
            
            self.taskInteractionView.currentJugglerOffer = offer
        }
    }
    
    var jugglerFilteredTask: FilteredTask? {
        didSet {
            guard let filteredTask = self.jugglerFilteredTask, let currentUser = self.currentUser else {
                return
            }
            
            //Check if currentUser has previously made an offer on this task
            let taskOffersRef = Database.database().reference().child(Constants.FirebaseDatabase.taskOffersRef).child(filteredTask.id).child(currentUser.userId)
            taskOffersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let taskOfferDictionary = snapshot.value as? [String : Any] else {
                    return
                }
                
                let taskOffer = Offer(offerDictionary: taskOfferDictionary)
                self.jugglerOffer = taskOffer
                
            }) { (error) in
                print("Error fetchning taskOffer: \(error)")
            }
        }
    }
    
    var currentUser: User? {
        didSet {
            guard let currentUser = self.currentUser, currentUser.isJuggler, let task = self.task else {
                return
            }
            
            //Check if current task is in currentUser's jugglerTasks. Since currentUser.isJuggler
            let jugglerTaskRef = Database.database().reference().child(Constants.FirebaseDatabase.jugglerTasksRef).child(currentUser.userId).child(task.id)
            jugglerTaskRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let filteredtaskDictionary = snapshot.value as? [String : Any] else {
                    return
                }
                
                let filteredTask = FilteredTask(id: snapshot.key, dictionary: filteredtaskDictionary)
                self.jugglerFilteredTask = filteredTask
                
            }) { (error) in
                print("Error fetchning filteredTask: \(error)")
            }
            
        }
    }
    
    var chatPartner: User? { //Set before pushing controller, used as toUserId when sending messages
        didSet {
            guard let chatPartner = self.chatPartner else {
                self.showNoResultsFoundView()
                return
            }
            
            if let _ = self.task {
                self.observeMessages(forChatPartnerId: chatPartner.userId)
            }
        }
    }
    
    var task: Task? {
        didSet {
            guard let task = task else {
                navigationItem.title = "Tarea Eliminada"
                return
            }
            
            navigationItem.title = task.title
            setupTaskInteractionDetailsView(forTask: task)
            
            if let chatPartner = self.chatPartner {
                self.observeMessages(forChatPartnerId: chatPartner.userId)
            }
        }
    }
    
    fileprivate func setupTaskInteractionDetailsView(forTask task: Task) {
        Database.fetchUserFromUserID(userId: task.userId) { (usr) in
            if let user = usr {
                self.taskInteractionView.user = user
                if self.chatPartner == nil && user.userId != Auth.auth().currentUser?.uid {
                    self.chatPartner = user
                }
            }
        }
        
        self.taskInteractionView.task = task
        self.taskInteractionView.delegate = self
        view.addSubview(self.taskInteractionView)
        self.taskInteractionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 295)
        
        self.anchorCollectionViewToTaskInteractionDetailsView(andScroll: true)
        var _ = self.textFieldShouldReturn(messageTextField)
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
        
        // Cant send messages to yourself
        if self.task?.userId == currentUser?.userId {
            let alert = UIView.okayAlert(title: "No se Puede Enviar Mensaje", message: "No se puede enviar mensajes por tareas que son tuyos.")
            self.present(alert, animated: true, completion: nil)
            self.messageTextField.text = ""
            
            return
        }
        
        if let currentUser = self.currentUser, !currentUser.isJuggler {
            self.dispalayBecomeAJugglerAlert()
            self.messageTextField.text = ""
            return
        }
        
        //Below function is right above viewDidLoad
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
                self.hideTaskInteractionDetailsView(andScroll: true, keyBoardHeight: height)
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
            if !self.view.subviews.contains(self.taskInteractionView) {
                self.anchorCollectionViewToTop(andScroll: false, keyBoardHeight: 0)
            }
            
        }
    }
    
    let noResultsView: UIView = {
        let view = UIView.noResultsView(withText: "No hay mensajes en este momento.")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    fileprivate func showNoResultsFoundView() {
        self.collectionView.bounces = false
        self.collectionView?.refreshControl?.endRefreshing()
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            self.collectionView?.addSubview(self.noResultsView)
            self.noResultsView.centerYAnchor.constraint(equalTo: (self.collectionView?.centerYAnchor)!).isActive = true
            self.noResultsView.centerXAnchor.constraint(equalTo: (self.collectionView?.centerXAnchor)!).isActive = true
        }
    }
    
    fileprivate func removeNoResultsView() {
        self.collectionView.bounces = true
        self.collectionView?.refreshControl?.endRefreshing()
        DispatchQueue.main.async {
            self.noResultsView.removeFromSuperview()
            self.collectionView?.reloadData()
            self.collectionView.scrollToItem(at: IndexPath(item: self.messages.count - 1, section: self.collectionView.numberOfSections - 1), at: .top, animated: true)
        }
    }
    
    fileprivate func sendMessage(withText text: String) {
        self.disableViews(true)
        
        guard let task = self.task else {
            self.disableViews(false)
            let alert = UIAlertController(title: "La Tarea ha Sido Eliminada", message: "Ir atrás", preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .default) { (_) in
                self.navigationController?.popViewController(animated: true)
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
        
        self.updatedJugglerTasks(forJugglerId: fromUserId, task: task)
        self.disableViews(false)
        self.messageTextField.text = ""
    }
    
    fileprivate func updatedJugglerTasks(forJugglerId jugglerId: String, task: Task) {
        if self.jugglerFilteredTask != nil {
            return
        }
        
        let jugglerTasksValues = [
            Constants.FirebaseDatabase.creationDate : Date().timeIntervalSince1970,
            Constants.FirebaseDatabase.taskStatus : 0
        ]
        //Update Juggler's task at location jugglerTasks/offer.taskId
        let jugglerTasksRef = Database.database().reference().child(Constants.FirebaseDatabase.jugglerTasksRef).child(jugglerId).child(task.id)
        jugglerTasksRef.updateChildValues(jugglerTasksValues) { (err, snapshot) in
            if let _ = err {
                return
            }
            
            guard let id = snapshot.key else {
                return
            }
            
            let filteredTaskDictionary: [String : Any] = [Constants.FirebaseDatabase.creationDate : Date().timeIntervalSince1970]
            let filteredTask = FilteredTask(id: id, dictionary: filteredTaskDictionary)
            self.jugglerFilteredTask = filteredTask
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        collectionView.backgroundColor = .white
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        
        //Register collectionViewCells
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.chatMessageCell)
        collectionView?.contentInset = UIEdgeInsets.init(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 58, right: 0)
        
        setupInputComponents()
        self.fetchCurrentUser()
    }
    
    fileprivate func fetchCurrentUser() {
        let currentUserId = Auth.auth().currentUser?.uid ?? "No currentUserId"
        userCache.removeValue(forKey: currentUserId)
        Database.fetchUserFromUserID(userId: currentUserId) { (usr) in
            self.currentUser = usr
        }
    }
    
    fileprivate func observeMessages(forChatPartnerId chatPartnerId: String) {
        self.disableViews(true)
        // Fetch messages for currentUserId and from chatPartnerId
        guard let currentUserId = Auth.auth().currentUser?.uid, let task = self.task else {
            print("No current user id")
            self.disableViews(false)
            self.showNoResultsFoundView()
            
            return
        }
        
        let userMessagesRef = Database.database().reference().child(Constants.FirebaseDatabase.userMessagesRef).child(currentUserId).child(task.id).child(chatPartnerId)
        
        self.disableViews(false)
        self.showNoResultsFoundView()
        
        userMessagesRef.observe(.childAdded, with: { (messagesSnapshot) in
            let messageId = messagesSnapshot.key
            let messagesRef = Database.database().reference().child(Constants.FirebaseDatabase.messagesRef).child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (messageSnapshot) in
                
                guard let messageDictionary = messageSnapshot.value as? [String : Any] else {
                    self.disableViews(false)
                    self.showNoResultsFoundView()
                    return
                }
                
                let message = Message(key: messageSnapshot.key, dictionary: messageDictionary)
                
                if message.chatPartnerId() == self.chatPartner?.userId {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.disableViews(false)
                        self.removeNoResultsView()
                    }
                }
            }) { (error) in
                print("Error fetching userMessages for user: \(currentUserId): ", error)
                self.disableViews(false)
                self.showNoResultsFoundView()
                return
            }
        }) { (error) in
            print("Error fetching userMessages for user: \(currentUserId): ", error)
            self.showNoResultsFoundView()
            self.disableViews(false)
            return
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
    
    //MARK: CollectionView Delegate Methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let chatMessageCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.chatMessageCell, for: indexPath) as? ChatMessageCell else {
            return UICollectionViewCell()
        }

        let message = self.messages[indexPath.item]
        
        chatMessageCell.textView.text = message.text
        
        setupChatMessageCell(cell: chatMessageCell, message: message)
        
        //Modifyig the chat bubble's width
        let text = self.messages[indexPath.item].text
        chatMessageCell.chatBubbleWidth?.constant = estimatedFrameForChatBubble(fromText: text).width + 32
        
        chatMessageCell.delegate = self
        
        return chatMessageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80

        //Modifying the chat bubble's height
        let text = self.messages[indexPath.item].text
        height = self.estimatedFrameForChatBubble(fromText: text).height + 20

        return CGSize(width: view.frame.width, height: height)
    }
    
    fileprivate func anchorCollectionViewToTop(andScroll scroll: Bool, keyBoardHeight: CGFloat) {
        var height = UIDevice().getDeviceSafeAreaInsetsHeightEstimation()
        var navBarHeight = UIDevice().getDeviceSafeAreaInsetsHeightEstimation()
        
        if let navBar = self.navigationController {
            navBarHeight = navBar.navigationBar.frame.size.height
        }
        
        height -= navBarHeight
        
        self.collectionView.frame = CGRect(x: 0.0, y: height, width: view.frame.width, height: view.frame.height - height - keyBoardHeight)
        
        if scroll {
            self.collectionView.scrollToItem(at: IndexPath(item: self.messages.count - 1, section: 0), at: .bottom, animated: false)
        }
    }
    
    fileprivate func anchorCollectionViewToTaskInteractionDetailsView(andScroll scroll: Bool) {
        var height = UIDevice().getDeviceSafeAreaInsetsHeightEstimation()
        height += 295 // 295 pixels is the heightAnchor of self.taskInteractionView
        
        self.collectionView.frame = CGRect(x: 0.0, y: height, width: view.frame.width, height: view.frame.height - height)
        
        if scroll {
            self.collectionView.scrollToItem(at: IndexPath(item: self.messages.count - 1, section: 0), at: .bottom, animated: false)
        }
    }
    
    fileprivate func setupChatMessageCell(cell: ChatMessageCell, message: Message) {
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
    
    @objc fileprivate func handleRightBarButtonItem() {
        guard let task = self.task else {
            return
        }
        
        self.setupTaskInteractionDetailsView(forTask: task)
        self.navigationItem.rightBarButtonItems?.remove(at: 0)
    }
    
    func disableViews(_ bool: Bool) {
        DispatchQueue.main.async {
            self.taskInteractionView.isUserInteractionEnabled = !bool
            self.messageTextField.isEnabled = !bool
            self.collectionView?.isUserInteractionEnabled = !bool
            
            if let text = self.messageTextField.text, text == "" {
                self.sendButton.isEnabled = false
            } else {
                self.sendButton.isEnabled = !bool
            }
        }
    }
    
    fileprivate func dispalayBecomeAJugglerAlert() {
        let alert = UIAlertController(title: "¡Se un Juggler!", message: "Gana dinero trabajando en las cosas que quieres, cuando quieras con Juggle", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        let becomeAJuggleAction = UIAlertAction(title: "¡Se un Juggler!", style: .default) { (_) in
            let jugglerApplicationStepsVC = JugglerApplicationStepsVC()
            let jugglerApplicationStepsNavVC = UINavigationController(rootViewController: jugglerApplicationStepsVC)
            jugglerApplicationStepsNavVC.modalPresentationStyle = .fullScreen
            self.present(jugglerApplicationStepsNavVC, animated: true, completion: nil)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(becomeAJuggleAction)
        
        self.present(alert, animated: true, completion: nil)
        
        return
    }
}

//MARK: Extensions
extension TaskInteractionVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        
        return true
    }
}

//MARK: TaskInteractionDetailsViewDelegate methods
extension TaskInteractionVC: TaskInteractionDetailsViewDelegate {
    func showTaskDetailsVC(forUser user: User?) {
        let taskDetailsVC = TaskDetailsVC()
        taskDetailsVC.task = self.task
        taskDetailsVC.user = user
        taskDetailsVC.previousTaskInteractionVC = self
        navigationController?.pushViewController(taskDetailsVC, animated: true)
    }
    
    func hideTaskInteractionDetailsView(andScroll scroll: Bool, keyBoardHeight: CGFloat) {
        self.taskInteractionView.removeFromSuperview()
        
        self.anchorCollectionViewToTop(andScroll: scroll, keyBoardHeight: keyBoardHeight)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Detalles", style: .plain, target: self, action: #selector(handleRightBarButtonItem))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.mainBlue()
    }
    
    func makeOffer() {
        guard let task = self.task else {
            let alert = UIAlertController(title: "La Tarea ha Sido Eliminada", message: "Ir atrás", preferredStyle: .alert)
            let backAction = UIAlertAction(title: "Okay", style: .default) { (_) in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(backAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard task.status == 0 else {
            let alert = UIView.okayAlert(title: "La Tarea ya esta Aceptada", message: "")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard task.userId != Auth.auth().currentUser?.uid else {
            let alert = UIView.okayAlert(title: "No se Puede Enviar Oferta", message: "No se puede hacer ofertas en tareas que son tuyos.")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        //Present become a Juggler action
        guard let currentUser = self.currentUser, currentUser.isJuggler else {
            self.dispalayBecomeAJugglerAlert()
            return
        }
        
        let taskOfferVC = TaskOfferVC()
        taskOfferVC.task = task
        taskOfferVC.user = self.taskInteractionView.user
        let taskOfferNavVC = UINavigationController(rootViewController: taskOfferVC)
        self.present(taskOfferNavVC, animated: true, completion: nil)
    }
    
    func acceptTask() {
        guard let task = self.task else {
            let alert = UIAlertController(title: "La Tarea ha Sido Eliminada", message: "Ir atrás", preferredStyle: .alert)
            let backAction = UIAlertAction(title: "Okay", style: .default) { (_) in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(backAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard task.userId != Auth.auth().currentUser?.uid else {
            let alert = UIView.okayAlert(title: "No se Puede Aceptar esta Tarea", message: "No se puede aceptar tareas que son tuyos.")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        //Present become a Juggler action
        guard let currentUser = self.currentUser, currentUser.isJuggler else {
            self.dispalayBecomeAJugglerAlert()
            return
        }
        
        let acceptTaskVC = AcceptTaskVC()
        acceptTaskVC.task = task
        acceptTaskVC.user = self.taskInteractionView.user
        let acceptTaskNavVC = UINavigationController(rootViewController: acceptTaskVC)
        self.present(acceptTaskNavVC, animated: true, completion: nil)
    }
    
    func handleProfileImageView(forUser user: User) {
        guard user.userId != Auth.auth().currentUser?.uid else {
            return
        }
        
        let profileVC = ProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        profileVC.user = user
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func cancelOffer() {
        let alert = UIView.okayAlert(title: "Still working on canceling offers", message: "")
        self.present(alert, animated: true, completion: nil)
    }
    
    func changeOffer(forTask task: Task?) {
        guard let task = self.task else {
            let alert = UIView.okayAlert(title: "Error al Grabar", message: "Sal e intenta nuevamente.")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        let taskOfferVC = TaskOfferVC()
        taskOfferVC.task = task
        taskOfferVC.user = self.taskInteractionView.user
        let taskOfferNavVC = UINavigationController(rootViewController: taskOfferVC)
        self.present(taskOfferNavVC, animated: true, completion: nil)
    }
}

//MARK: ChatMessageCell Delegate methods
extension TaskInteractionVC: ChatMessageCellDelegate {
    func handleProfileImageView() {
        self.disableViews(true)
        guard let chatPartnerId = self.messages.first?.chatPartnerId(), chatPartnerId != Auth.auth().currentUser?.uid else {
            self.disableViews(false)
            return
        }
        
        Database.fetchUserFromUserID(userId: chatPartnerId) { (user) in
            self.disableViews(false)
            let profileVC = ProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
            profileVC.user = user
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
}
