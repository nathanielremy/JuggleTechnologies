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
            guard let user = self.user else {
                return
            }
            
            if user.userId == Auth.auth().currentUser?.uid {
                self.setupTopNavigationBarSettingsButton()
            }
            
            collectionView.refreshControl?.endRefreshing()
            collectionView.reloadData()
        }
    }
    
    fileprivate func setupTopNavigationBarSettingsButton() {
        let settingsBarButton = UIBarButtonItem(title: "···", style: .done
            , target: self, action: #selector(handleSettingsBarButton))
        settingsBarButton.setTitleTextAttributes([.font : UIFont.boldSystemFont(ofSize: 24)], for: .normal)
        settingsBarButton.tintColor = UIColor.mainBlue()
        navigationItem.rightBarButtonItem = settingsBarButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        navigationController?.navigationBar.tintColor = .black
        
        //Register the CollectionViewCells
//        collectionView.register(UserProfileHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.CollectionViewCellIds.userProfileHeaderCell)
        collectionView.register(UserProfileHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.CollectionViewCellIds.userProfileHeaderCell)
        collectionView.register(UserProfileStatisticsCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.userProfileStatisticsCell)
        collectionView.register(UserSelfDescriptionCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.userSelfDescriptionCell)
        
        // Manualy refresh the collectionView
        let refreshController = UIRefreshControl()
        refreshController.tintColor = UIColor.darkText
        refreshController.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshController
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTextFieldDoneButton))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        let userId = self.user?.userId ?? (Auth.auth().currentUser?.uid ?? "")
        
        fetchUser(withUserId: userId)
    }
    
    @objc fileprivate func handleRefresh() {
        guard let userId = user?.userId else {
            collectionView.refreshControl?.endRefreshing()
            return
        }
        
        self.hasCalledFetchUser = false
        fetchUser(withUserId: userId)
    }
    
    // When done button is clicked on keyboard input accessory view
    @objc func handleTextFieldDoneButton() {
        view.endEditing(true)
    }
    
    //Fetching user only happens once per freshing, either from viewDidLoad or uself.userID's didSet method
    private var hasCalledFetchUser: Bool = false
    fileprivate func fetchUser(withUserId userId: String) {
        if hasCalledFetchUser {
            return
        }
        hasCalledFetchUser = true
        
        if userId == Auth.auth().currentUser?.uid {
            userCache.removeValue(forKey: userId)
        }
        
        Database.fetchUserFromUserID(userID: userId) { (usr) in
            guard let user = usr else {
                return
            }
            
            self.user = user
            self.navigationItem.title = user.firstName
        }
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
        
        headerCell.delegate = self
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
        userSelfDescriptionCell.delegate = self
        return userSelfDescriptionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.item == 0 ? CGSize(width: view.frame.width, height: 75) : CGSize(width: view.frame.width, height: 200)
    }
}

//MARK: UserSelfDescriptionCellDelegate methods
extension ProfileVC: UserSelfDescriptionCellDelegate {
    func saveUserDescription(description: String?, completion: @escaping (Bool, String) -> Void) {
        guard let description = description, description != "", description != "No hay Descripción" else {
            completion(false, "")
            let alert = UIView.okayAlert(title: "No hay Descripción", message: "Asegúrese de que la descripción se haya completado correctamente")
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            
            return
        }
        
        guard let userId = self.user?.userId else {
            completion(false, "")
            let alert = UIView.okayAlert(title: "No se Puede Guardar", message: "Asegúrese de que la descripción se haya completado correctamente")
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            
            return
        }
        
        if self.user?.description == description {
            completion(true, description)
            
            return
        }
        
        let userDescriptionRef = Database.database().reference().child(Constants.FirebaseDatabase.usersRef).child(userId)
        userDescriptionRef.updateChildValues([Constants.FirebaseDatabase.description : description]) { (err, _) in
            if let error = err {
                print("Error updating user.description in UserSelfDescriptionCellDelegate: \(error)")
                completion(false, "")
                let alert = UIView.okayAlert(title: "No se Puede Guardar", message: "Asegúrese de que la descripción se haya completado correctamente")
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                
                return
            }
            
         completion(true, description)
        }
    }
}

extension ProfileVC: UserProfileHeaderCellDelegate {
    func dispalayBecomeAJugglerAlert() {
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
