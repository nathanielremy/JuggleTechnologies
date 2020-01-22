//
//  ProfileVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-18.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //MARK: Stores properties
    var user: User? {
        didSet {
            guard let _ = self.user else {
                return
            }
            
            collectionView.reloadData()
        }
    }
    
    var userId: String? {
        didSet {
            guard let userId = userId else {
                return
            }
            
            fetchUser(withUserId: userId)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        
        //Register the CollectionViewCells
        collectionView.register(UserProfileHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.CollectionViewCellIds.userProfileHeaderCell)
        collectionView.register(UserProfileStatisticsCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.userProfileStatisticsCell)
        collectionView.register(UserSelfDescriptionCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.userSelfDescriptionCell)
        
        
        setupTopNavigationBar()
        
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        fetchUser(withUserId: userId)
    }
    
    //Fetching user only happens once per freshing, either from viewDidLoad or uself.userID's didSet method
    private var hasCalledFetchUser: Bool = false
    fileprivate func fetchUser(withUserId userId: String) {
        if hasCalledFetchUser {
            return
        }
        hasCalledFetchUser = true
        
        Database.fetchUserFromUserID(userID: userId) { (usr) in
            guard let user = usr else {
                return
            }
            
            self.user = user
            self.navigationItem.title = user.firstName
        }
    }
    
    fileprivate func setupTopNavigationBar() {
        navigationController?.navigationBar.tintColor = .black
        let settingsBarButton = UIBarButtonItem(title: "···", style: .done
            , target: self, action: #selector(handleSettingsBarButton))
        settingsBarButton.setTitleTextAttributes([.font : UIFont.boldSystemFont(ofSize: 24)], for: .normal)
        settingsBarButton.tintColor = UIColor.darkText
        navigationItem.rightBarButtonItem = settingsBarButton
    }
    
    @objc fileprivate func handleSettingsBarButton() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                
                let loginVC = LoginVC()
                let signupNavController = UINavigationController(rootViewController: loginVC)
                signupNavController.modalPresentationStyle = .fullScreen
                
                self.present(signupNavController, animated: true, completion: nil)
                
            } catch let signOutError {
                print("Unable to sign out: \(signOutError)")
                let alert = UIView.okayAlert(title: "Unable to Log out", message: "You are unnable to log out at this moment.")
                self.present(alert, animated: true, completion: nil)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: UserProfileHeaderCell Methods
    // Add section header for collectionView a supplementary kind
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.CollectionViewCellIds.userProfileHeaderCell, for: indexPath) as? UserProfileHeaderCell else { fatalError("Unable to dequeue UserProfileHeaderCell")}
        
//        headerCell.delegate = self
        headerCell.user = self.user
        
        return headerCell
    }
    
    // Need to provide a size or the header will not render out
    // Define the size of the section header for the collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 245)
    }
    
    //MARK: CollectionView methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2 // Statistics and description cells only
    }
    
    // What's the vertical spacing between each cell ?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            guard let userProfileStatisticsCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.userProfileStatisticsCell, for: indexPath) as? UserProfileStatisticsCell else {
                return UICollectionViewCell()
            }
            
            return userProfileStatisticsCell
        }
        
        guard let userSelfDescriptionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.userSelfDescriptionCell, for: indexPath) as? UserSelfDescriptionCell else {
            return UICollectionViewCell()
        }
        
        userSelfDescriptionCell.user = self.user
        return userSelfDescriptionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.item == 0 ? CGSize(width: view.frame.width, height: 75) : CGSize(width: view.frame.width, height: 200)
    }
}
