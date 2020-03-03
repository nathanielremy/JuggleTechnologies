//
//  OnGoingTaskInteractionsVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-02-17.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class OnGoingTaskInteractionsVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    //MARK: Stored properties
    var dashboardVC: DashboardVC?
    var dashboardVCTaskIndex: Int?
    
    var currentUser: User?
    var filterMode: Int = 0 // 0 == offers, 1 == mensajes
    var canFetchOffers = true
    
    var offers = [Offer]()
    var tempOffers = [Offer]()
    
    var messages = [Message]()
    var messagesDictionary = [String : Message]()
    var timer: Timer?
    
    var task: Task? {
        didSet {
            guard let task = self.task else {
                self.navigationController?.popViewController(animated: false)
                return
            }
            
            self.tempOffers.removeAll()
            self.messages.removeAll()
            self.fetchOffers(forTask: task)
            self.observeUserMessages(forTask: task)
            setupNavigationBar(forTask: task)
        }
    }
    
    fileprivate func setupNavigationBar(forTask task: Task) {
        navigationItem.title = task.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Detalles", style: .plain, target: self, action: #selector(handleDetailsNavBarButton))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.mainBlue()
    }
    
    @objc fileprivate func handleDetailsNavBarButton() {
        guard let task = self.task else {
            return
        }
        
        let taskDetailsVC = TaskDetailsVC()
        taskDetailsVC.task = task
        taskDetailsVC.user = self.currentUser
        taskDetailsVC.previousOnGoingTaskInteractionVC = self
        self.navigationController?.pushViewController(taskDetailsVC, animated: true)
    }
    
    // Display activity indicator while filtering
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
        
        self.collectionView.isUserInteractionEnabled = !bool
        self.navigationItem.rightBarButtonItem?.isEnabled = !bool
    }
    
    let noMessagessView: UIView = {
        let view = UIView.noResultsView(withText: "Esta tarea todavía no tiene mensajes.")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    fileprivate func showNoMessagesFoundView(andReload reload: Bool) {
        self.collectionView?.refreshControl?.endRefreshing()
        DispatchQueue.main.async {
            if reload {
                self.collectionView?.reloadData()
            }
            self.collectionView?.addSubview(self.noMessagessView)
            self.noMessagessView.centerYAnchor.constraint(equalTo: (self.collectionView?.centerYAnchor)!).isActive = true
            self.noMessagessView.centerXAnchor.constraint(equalTo: (self.collectionView?.centerXAnchor)!).isActive = true
        }
    }
    
    let noOffersView: UIView = {
        let view = UIView.noResultsView(withText: "Esta tarea todavía no tiene ofertas.")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    fileprivate func showNoOffersFoundFoundView(andReload reload: Bool) {
        self.collectionView?.refreshControl?.endRefreshing()
        DispatchQueue.main.async {
            if reload {
                self.collectionView?.reloadData()
            }
            self.collectionView?.addSubview(self.noOffersView)
            self.noOffersView.centerYAnchor.constraint(equalTo: (self.collectionView?.centerYAnchor)!).isActive = true
            self.noOffersView.centerXAnchor.constraint(equalTo: (self.collectionView?.centerXAnchor)!).isActive = true
        }
    }
    
    fileprivate func removeNoResultsView(andReload reload: Bool) {
        self.collectionView?.refreshControl?.endRefreshing()
        DispatchQueue.main.async {
            self.noMessagessView.removeFromSuperview()
            self.noOffersView.removeFromSuperview()
            if reload {
                self.collectionView?.reloadData()
            }
        }
    }
    
    fileprivate func observeUserMessages(forTask task: Task) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.attemptReloadTable()
            print("No currentuserId to fetch OnGoingTaskMessages")
            return
        }
        
        self.attemptReloadTable()
        
        // Fetch the references to message objects in database
        let userMessagesRef = Database.database().reference().child(Constants.FirebaseDatabase.userMessagesRef).child(currentUserId).child(task.id)
        userMessagesRef.observe(.childAdded, with: { (userMessagesSnapshot) in
            
            let userId = userMessagesSnapshot.key
            
            // From reference fetch message objects
            let userRef = Database.database().reference().child(Constants.FirebaseDatabase.userMessagesRef).child(currentUserId).child(task.id).child(userId)
            userRef.observe(.childAdded, with: { (messageIdSnapshot) in
                
                let messageId = messageIdSnapshot.key
                self.fetchMessage(withMessageId: messageId)
                
            }) { (error) in
                self.attemptReloadTable()
                print("Error fetching userRef in OnGoingTaskInteractionsVC: \(error)")
            }
        }) { (error) in
            self.attemptReloadTable()
            print("Error fetching userMessages in OnGoingTaskInteractionsVC: \(error)")
        }
    }
    
    fileprivate func fetchMessage(withMessageId messageId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.attemptReloadTable()
            print("No current user")
            return
        }
        
        let messagesRef = Database.database().reference().child(Constants.FirebaseDatabase.messagesRef).child(messageId)
        messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String : Any] else {
                self.attemptReloadTable()
                print("snapShot not convertible to [String : Any]")
                return
            }
            
            let message = Message(key: snapshot.key, dictionary: dictionary)
            
            //Grouping all messages per user and users can only message about their own tasks
            if let chatPartnerId = message.chatPartnerId(), currentUserId == message.taskOwnerId {
                self.messagesDictionary[chatPartnerId] = message
            }
            
            self.attemptReloadTable()
            
        }, withCancel: { (error) in
            self.attemptReloadTable()
            print("ERROR: ", error)
            return
        })
    }
    
    fileprivate func attemptReloadTable() {
        // Solution with timer to only reload the tableView once
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.handleReloadCollectionView), userInfo: nil, repeats: false)
    }
    
    @objc func handleReloadCollectionView() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (msg1, msg2) -> Bool in
            return Double(msg1.creationDate.timeIntervalSince1970) > Double(msg2.creationDate.timeIntervalSince1970)
        })
        
        if self.filterMode == 1 {
            // Reload table view
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        collectionView.bounces = true
        
        //Register the CollectionViewCells
        collectionView.register(OnGoingTaskInteractionsHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.CollectionViewCellIds.onGoingTaskInteractionsHeaderCell)
        collectionView.register(OnGoingTaskOfferCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.onGoingTaskOfferCell)
        collectionView.register(OnGoingTaskChatMessageCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.onGoingTaskChatMessageCell)
        
        // Manualy refresh the collectionView
        let refreshController = UIRefreshControl()
        refreshController.tintColor = UIColor.darkText
        refreshController.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshController
        
        self.fetchCurrentUser()
        self.setupActivityIndicator()
        self.animateAndShowActivityIndicator(true)
    }
    
    @objc fileprivate func handleRefresh() {
        guard let task = self.task else {
            self.collectionView.refreshControl?.endRefreshing()
            return
        }
        
        if self.filterMode == 0 {
            self.tempOffers.removeAll()
            fetchOffers(forTask: task)
        } else if self.filterMode == 1 {
            self.observeUserMessages(forTask: task)
        }
    }
    
    fileprivate func setupActivityIndicator() {
        view.addSubview(self.activityIndicator)
        self.activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    fileprivate func fetchCurrentUser() {
        let currentUserId = Auth.auth().currentUser?.uid ?? "No currentUserId"
        userCache.removeValue(forKey: currentUserId)
        Database.fetchUserFromUserID(userID: currentUserId) { (usr) in
            self.currentUser = usr
        }
    }
    
    fileprivate func fetchOffers(forTask task: Task) {
        if !self.canFetchOffers {
            return
        }
        self.canFetchOffers = false
        
        let taskOffersRef = Database.database().reference().child(Constants.FirebaseDatabase.taskOffersRef).child(task.id)
        taskOffersRef.observeSingleEvent(of: .value, with: { (offersSnapshot) in
            guard let offersSnapshotDictionary = offersSnapshot.value as? [String : [String : Any]] else {
                if self.filterMode == 0 {
                    self.offers.removeAll()
                    self.canFetchOffers = true
                    self.showNoOffersFoundFoundView(andReload: true)
                    self.animateAndShowActivityIndicator(false)
                }
                return
            }
            
            var offersCreated = 0
            offersSnapshotDictionary.forEach { (key, value) in
                let offer = Offer(offerDictionary: value)
                offersCreated += 1
                
                if !offer.isOfferRejected && !offer.isOfferAccepted {
                    self.tempOffers.append(offer)
                }
                
                self.tempOffers.sort(by: { (offer1, offer2) -> Bool in
                    return offer1.creationDate.compare(offer2.creationDate) == .orderedDescending
                })
                
                if offersCreated == offersSnapshotDictionary.count {
                    self.offers = self.tempOffers
                    
                    if self.filterMode != 0 {
                        return
                    }
                    
                    self.removeNoResultsView(andReload: true)
                    self.animateAndShowActivityIndicator(false)
                    self.canFetchOffers = true
                    
                    if self.offers.count == 0 {
                        self.showNoOffersFoundFoundView(andReload: true)
                    }
                }
            }
        }) { (error) in
            print("Error fetching offers for task \(task.id): \(error)")
            if self.filterMode == 0 {
                self.offers.removeAll()
                self.canFetchOffers = true
                self.showNoOffersFoundFoundView(andReload: true)
                self.animateAndShowActivityIndicator(false)
            }
        }
    }
    
    //MARK: CollectionView Delegate Methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.removeNoResultsView(andReload: false)
        if filterMode == 0 { //Offers
            if self.offers.count == 0 {
                self.showNoOffersFoundFoundView(andReload: false)
            }
            return self.offers.count
        } else { //Messages
            if self.messages.count == 0 {
                self.showNoMessagesFoundView(andReload: false)
            }
            return self.messages.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.filterMode == 0 { //Offers
            guard let taskOfferCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.onGoingTaskOfferCell, for: indexPath) as? OnGoingTaskOfferCell else {
                return UICollectionViewCell()
            }
            
            taskOfferCell.offer = self.offers[indexPath.item]
            taskOfferCell.indexOfOffer = indexPath.item
            taskOfferCell.delegate = self
            
            return taskOfferCell
        } else { //Messages
            guard let chatMessageCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.onGoingTaskChatMessageCell, for: indexPath) as? OnGoingTaskChatMessageCell else {
                return UICollectionViewCell()
            }
            let message = self.messages[indexPath.row]
            
            if self.messages.count >= indexPath.row {
                if let uId = message.chatPartnerId() {
                    Database.fetchUserFromUserID(userID: uId) { (jglr) in
                        guard let juggler = jglr else { print("Could not fetch Juggler from Database"); return }
                        DispatchQueue.main.async {
                            chatMessageCell.message = (message, juggler)
                            chatMessageCell.delegate = self
                        }
                    }
                }
            }
            
            return chatMessageCell
        }
    }
    
    // What's the vertical spacing between each cell ?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.filterMode == 1 else { //Make sure collectionView is displaying messages not offers.
            return
        }
        
        self.animateAndShowActivityIndicator(true)
        let message = self.messages[indexPath.item]
        
        guard let jugglerId = message.chatPartnerId() else {
            self.animateAndShowActivityIndicator(false)
            print("No chatPartnerId")
            return
        }
        
        Database.fetchUserFromUserID(userID: jugglerId) { (usr) in
            self.animateAndShowActivityIndicator(false)
            guard let user = usr, let task = self.task else {
                let alert = UIView.okayAlert(title: "Error Grabando Mensajes", message: "Error al grabar de los mensajes. Sal e intente nuevamente")
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let dashboardChatlogVC = DashboardChatLogVC(collectionViewLayout: UICollectionViewFlowLayout())
            dashboardChatlogVC.chatPartner = user
            dashboardChatlogVC.task = task
            self.navigationController?.pushViewController(dashboardChatlogVC, animated: true)
        }
    }
    
    //MARK: DashboardHeaderCell Methods
    // Add section header for collectionView a supplementary kind
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.CollectionViewCellIds.onGoingTaskInteractionsHeaderCell, for: indexPath) as? OnGoingTaskInteractionsHeaderCell else { fatalError("Unable to dequeue DashboardHeaderCell")}
            
        headerCell.delegate = self
            
        return headerCell
    }
        
    // Need to provide a size or the header will not render out
    // Define the size of the section header for the collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
}

extension OnGoingTaskInteractionsVC: OnGoingTaskInteractionsHeaderCellDelegate {
    func changeFilterOption(forTag tag: Int) {
        self.filterMode = tag
        self.collectionView.reloadData()
    }
}

extension OnGoingTaskInteractionsVC: OnGoingTaskOfferCellDelegate {
    func handleProfileImageView(forOfferOwner offerOwner: User?) {
        guard let juggler = offerOwner else {
            return
        }
        
        let profileVC = ProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        profileVC.user = juggler
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func handleDenyOffer(_ offer: Offer?, index: Int?) {
        self.animateAndShowActivityIndicator(true)
        
        let denyOfferAlert = UIAlertController(title: "¿Seguro?", message: "Esta oferta sera eliminada indefinadamente", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { (_) in
            self.animateAndShowActivityIndicator(false)
        }
        let denyAction = UIAlertAction(title: "Denegar", style: .default) { (_) in
            guard let offer = offer, let index = index else {
                let alert = UIView.okayAlert(title: "No se Puede Denegar Esta Oferta", message: "Sal e intente nuevamente")
                self.present(alert, animated: true, completion: nil)
                self.animateAndShowActivityIndicator(false)
                return
            }
            
            let offerValues = [Constants.FirebaseDatabase.isOfferRejected : true]
            let taskOffersRef = Database.database().reference().child(Constants.FirebaseDatabase.taskOffersRef).child(offer.taskId).child(offer.offerOwnerId)
            taskOffersRef.updateChildValues(offerValues) { (err, _) in
                if let error = err {
                    print("Error denying offer: \(error)")
                    let alert = UIView.okayAlert(title: "No se Puede Denegar Esta Oferta", message: "Sal e intente nuevamente")
                    self.present(alert, animated: true, completion: nil)
                    self.animateAndShowActivityIndicator(false)
                    return
                }
                
                self.animateAndShowActivityIndicator(false)
                self.offers.remove(at: index)
                self.collectionView.reloadData()
            }
        }
        
        denyOfferAlert.addAction(cancelAction)
        denyOfferAlert.addAction(denyAction)
        present(denyOfferAlert, animated: true, completion: nil)
    }
    
    func handleAcceptOffer(_ offer: Offer?, offerOwner: User?) {
        self.animateAndShowActivityIndicator(true)
        
        guard let offer = offer, let index = self.dashboardVCTaskIndex, let offerOwner = offerOwner, let task = self.task else {
            print("Error accepting offer")
            let alert = UIView.okayAlert(title: "No se Puede Acceptar Esta Oferta", message: "Sal e intente nuevamente")
            self.present(alert, animated: true, completion: nil)
            self.animateAndShowActivityIndicator(false)
            return
        }
        
        let acceptOfferAlert = UIAlertController(title: "¿Seguro?", message: "Esta oferta sera accepta por \(offerOwner.firstName)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { (_) in
            self.animateAndShowActivityIndicator(false)
        }
        let acceptAction = UIAlertAction(title: "Aceptar", style: .default) { (_) in
            if self.dashboardVC == nil {
                print("self.dashboardVC == nil")
                let alert = UIView.okayAlert(title: "No se Puede Acceptar Esta Oferta", message: "Sal e intente nuevamente")
                self.present(alert, animated: true, completion: nil)
                self.animateAndShowActivityIndicator(false)
                return
            }
            
            let acceptedDate = Date().timeIntervalSince1970
            let tasksRefValues: [String : Any] = [
                Constants.FirebaseDatabase.acceptedDate : acceptedDate,
                Constants.FirebaseDatabase.acceptedBudget : offer.offerPrice,
                Constants.FirebaseDatabase.assignedJugglerId : offerOwner.userId,
                Constants.FirebaseDatabase.taskStatus : 1,
            ]
            //Update the tasksRef at location tasks/offer.taskId
            let tasksRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).child(offer.taskId)
            tasksRef.updateChildValues(tasksRefValues) { (err, _) in
                if let error = err {
                    print("Error accepting offer: \(error)")
                    let alert = UIView.okayAlert(title: "No se Puede aceptar Esta Oferta", message: "Sal e intente nuevamente")
                    self.present(alert, animated: true, completion: nil)
                    self.animateAndShowActivityIndicator(false)
                    return
                }
                
                let userTasksValues: [String : Any] = [
                    Constants.FirebaseDatabase.acceptedDate : acceptedDate,
                    Constants.FirebaseDatabase.taskStatus : 1
                ]
                //Update user's task at location userTasks/offer.taskId
                let userTasksRef = Database.database().reference().child(Constants.FirebaseDatabase.userTasksRef).child(task.userId).child(offer.taskId)
                userTasksRef.updateChildValues(userTasksValues) { (err, _) in
                    if let error = err {
                        print("Error accepting offer: \(error)")
                        let alert = UIView.okayAlert(title: "No se Puede aceptar Esta Oferta", message: "Sal e intente nuevamente")
                        self.present(alert, animated: true, completion: nil)
                        self.animateAndShowActivityIndicator(false)
                        return
                    }
                    
                    let jugglerTasksValues = [
                        Constants.FirebaseDatabase.acceptedDate : acceptedDate,
                        Constants.FirebaseDatabase.taskStatus : 1
                    ]
                    //Update Juggler's task at location jugglerTasks/offer.taskId
                    let jugglerTasksRef = Database.database().reference().child(Constants.FirebaseDatabase.jugglerTasksRef).child(offer.offerOwnerId).child(offer.taskId)
                    jugglerTasksRef.updateChildValues(jugglerTasksValues) { (err, _) in
                        if let error = err {
                            print("Error accepting offer: \(error)")
                            let alert = UIView.okayAlert(title: "No se Puede aceptar Esta Oferta", message: "Sal e intente nuevamente")
                            self.present(alert, animated: true, completion: nil)
                            self.animateAndShowActivityIndicator(false)
                            return
                        }
                        
                        self.dashboardVC?.acceptedIndex = index
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
             
        }
        
        acceptOfferAlert.addAction(cancelAction)
        acceptOfferAlert.addAction(acceptAction)
        self.present(acceptOfferAlert, animated: true, completion: nil)
    }
}

extension OnGoingTaskInteractionsVC: OnGoingTaskChatMessageCellDelegate {
    func handleProfileImageView(forJuggler juggler: User?) {
        guard let juggler = juggler else {
            return
        }
        
        let profileVC = ProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        profileVC.user = juggler
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}
