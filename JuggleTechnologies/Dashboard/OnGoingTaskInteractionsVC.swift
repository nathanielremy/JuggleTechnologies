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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        //Register the CollectionViewCells
        collectionView.register(OnGoingTaskInteractionsHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.CollectionViewCellIds.onGoingTaskInteractionsVCHeaderCell)
        
        self.fetchCurrentUser()
    }
    
    fileprivate func fetchCurrentUser() {
        let currentUserId = Auth.auth().currentUser?.uid ?? "No currentUserId"
        userCache.removeValue(forKey: currentUserId)
        Database.fetchUserFromUserID(userID: currentUserId) { (usr) in
            self.currentUser = usr
        }
    }
    
    fileprivate func fetchOffers(forTask task: Task) {
        
    }
    
    //MARK: DashboardHeaderCell Methods
    // Add section header for collectionView a supplementary kind
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.CollectionViewCellIds.onGoingTaskInteractionsVCHeaderCell, for: indexPath) as? OnGoingTaskInteractionsHeaderCell else { fatalError("Unable to dequeue DashboardHeaderCell")}
            
//        headerCell.delegate = self
            
        return headerCell
    }
        
    // Need to provide a size or the header will not render out
    // Define the size of the section header for the collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
}
