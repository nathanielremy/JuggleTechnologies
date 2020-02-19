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
    var currentUser: User?
    var filterMode: Int = 0 // 0 == offers, 1 == mensajes
    var canFetchOffers = true
    var canFetchMessagess = true
    
    var offers = [Offer]()
    var tempOffers = [Offer]()
    
    var messages = [Message]()
    
    var task: Task? {
        didSet {
            guard let task = self.task else {
                self.navigationController?.popViewController(animated: false)
                return
            }
            
            self.fetchOffers(forTask: task)
            setupNavigationBar(forTask: task)
        }
    }
    
    fileprivate func setupNavigationBar(forTask task: Task) {
        navigationItem.title = task.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Detalles", style: .plain, target: self, action: #selector(handleDetailsNavBarButton))
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        collectionView.bounces = true
        
        //Register the CollectionViewCells
        collectionView.register(OnGoingTaskInteractionsHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.CollectionViewCellIds.onGoingTaskInteractionsVCHeaderCell)
        collectionView.register(OnGoingTaskOfferCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.onGoingTaskOfferCell)
        collectionView.register(OnGoingChatMessageCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.onGoingChatMessageCell)
        
        // Manualy refresh the collectionView
        let refreshController = UIRefreshControl()
        refreshController.tintColor = UIColor.darkText
        refreshController.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshController
        
        self.animateAndShowActivityIndicator(true)
        self.fetchCurrentUser()
        self.setupActivityIndicator()
    }
    
    @objc fileprivate func handleRefresh() {
        guard let task = self.task else {
            self.collectionView.refreshControl?.endRefreshing()
            return
        }
        
        if self.filterMode == 0 {
            self.tempOffers.removeAll()
            fetchOffers(forTask: task)
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
            guard let onGoingTaskOfferCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.onGoingTaskOfferCell, for: indexPath) as? OnGoingTaskOfferCell else {
                return UICollectionViewCell()
            }
            
            onGoingTaskOfferCell.offer = self.offers[indexPath.item]
            
            return onGoingTaskOfferCell
        } else { //Messages
            guard let onGoingChatMessageCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.onGoingChatMessageCell, for: indexPath) as? OnGoingChatMessageCell else {
                return UICollectionViewCell()
            }
            
            return onGoingChatMessageCell
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
        print(indexPath.item)
    }
    
    //MARK: DashboardHeaderCell Methods
    // Add section header for collectionView a supplementary kind
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.CollectionViewCellIds.onGoingTaskInteractionsVCHeaderCell, for: indexPath) as? OnGoingTaskInteractionsHeaderCell else { fatalError("Unable to dequeue DashboardHeaderCell")}
            
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
