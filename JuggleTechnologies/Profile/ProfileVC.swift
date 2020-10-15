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
    var isUserMode: Bool = true
    
    var userTasksPostedCount: Int = 0
    var jugglerCompletedTasksCount: Int = 0
    
    var didFetchUserTasks: Bool = false
    var didFetchJugglerTasks: Bool = false
    
    var userReviews = [Review]()
    var userReviewsTotalRatingCount = 0
    
    var jugglerReviews = [Review]()
    var jugglerReviewsTotalRatingCount = 0
    
    var didFetchReviews: Bool = false
    
    let profileSettingsView = ProfileSettingsView()
    var isProfileSettingsViewPresent = false
    
    lazy var profileSettingsBlurrViewButton: UIButton = {
        let  button = UIButton()
        button.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        button.addTarget(self, action: #selector(handleProfileSettingsBlurrViewButton), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleProfileSettingsBlurrViewButton() {
        profileSettingsBlurrViewButton.removeFromSuperview()
        profileSettingsView.removeFromSuperview()
        isProfileSettingsViewPresent = false
    }
    
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
            
            self.navigationItem.title = user.firstName
            
            self.didFetchUserTasks = false
            self.didFetchJugglerTasks = false
            self.userTasksPostedCount = 0
            self.jugglerCompletedTasksCount = 0
            self.fetchTasks(forUser: user)
            
            self.userReviews.removeAll()
            self.userReviewsTotalRatingCount = 0
            self.jugglerReviews.removeAll()
            self.jugglerReviewsTotalRatingCount = 0
            self.didFetchReviews = false
            
            self.fetchReviews(forUser: user)
        }
    }
    
    fileprivate func fetchTasks(forUser user: User) {
        let dataReference = self.isUserMode ? Constants.FirebaseDatabase.userTasksRef : Constants.FirebaseDatabase.jugglerTasksRef
        let tasksRef = Database.database().reference().child(dataReference).child(user.userId)
        tasksRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.didFetchJugglerTasks = dataReference == Constants.FirebaseDatabase.jugglerTasksRef ? true : self.didFetchJugglerTasks
            self.didFetchUserTasks = dataReference == Constants.FirebaseDatabase.userTasksRef ? true : self.didFetchUserTasks
            
            guard let filteredTasks = snapshot.value as? [String : [String : Any]] else {
                if self.isUserMode {
                    self.userTasksPostedCount = 0
                } else {
                    self.jugglerCompletedTasksCount = 0
                }
                
                self.collectionView.reloadData()
                return
            }
            
            if self.isUserMode {
                self.userTasksPostedCount = filteredTasks.count
            } else {
                var completedTasksCount = 0
                filteredTasks.forEach { (_, value) in
                    if let status = value[Constants.FirebaseDatabase.taskStatus] as? Int, status == 2 {
                        completedTasksCount += 1
                    }
                }
                self.jugglerCompletedTasksCount = completedTasksCount
            }
            
            self.collectionView.reloadData()
            
        }) { (error) in
            print("Error fetching tasks in ProfileVC: \(error)")
            if self.isUserMode {
                self.userTasksPostedCount = 0
            } else {
                self.jugglerCompletedTasksCount = 0
            }
            
            self.collectionView.reloadData()
        }
    }
    
    fileprivate func fetchReviews(forUser user: User) {
        let dataReference = Database.database().reference().child(Constants.FirebaseDatabase.reviewsRef).child(user.userId)
        dataReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.didFetchReviews = true
            
            guard let reviews = snapshot.value as? [String : [String : Any]] else {
                if self.isUserMode {
                    self.userReviews.removeAll()
                } else {
                    self.jugglerReviews.removeAll()
                }
                
                self.collectionView.reloadData()
                return
            }
            
            reviews.forEach { (key, value) in
                let review = Review(id: key, dictionary: value)
                
                if review.isFromUserPerspective {
                    self.jugglerReviews.append(review)
                    self.jugglerReviewsTotalRatingCount += review.rating
                    self.jugglerReviews.sort(by: { (review1, review2) -> Bool in
                        return review1.creationDate.compare(review2.creationDate) == .orderedDescending
                    })
                } else {
                    self.userReviews.append(review)
                    self.userReviewsTotalRatingCount += review.rating
                    self.userReviews.sort(by: { (review1, review2) -> Bool in
                        return review1.creationDate.compare(review2.creationDate) == .orderedDescending
                    })
                }
            }
            
            self.collectionView.reloadData()
            
        }) { (error) in
            print("Error fetching reviews in ProfileVC: \(error)")
            self.collectionView.reloadData()
        }
    }
    
    fileprivate func setupTopNavigationBarSettingsButton() {
        let settingsBarButton = UIBarButtonItem(title: "···", style: .done
            , target: self, action: #selector(handleSettingsBarButton))
        settingsBarButton.setTitleTextAttributes([.font : UIFont.boldSystemFont(ofSize: 30)], for: .normal)
        settingsBarButton.tintColor = UIColor.mainBlue()
        navigationItem.rightBarButtonItem = settingsBarButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        navigationController?.navigationBar.tintColor = .darkText
        
        //Register the CollectionViewCells
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
        
        if self.user == nil {
            fetchUser(withUserId: userId)
        }
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
        
        Database.fetchUserFromUserID(userId: userId) { (usr) in
            guard let user = usr else {
                return
            }
            
            self.user = user
        }
    }
    
    @objc fileprivate func handleSettingsBarButton() {
        guard Auth.auth().currentUser?.uid == self.user?.userId else {
            return
        }
        
        if self.isProfileSettingsViewPresent {
            self.profileSettingsView.removeFromSuperview()
            self.profileSettingsBlurrViewButton.removeFromSuperview()
            self.isProfileSettingsViewPresent = false
            
            return
        }
        
        view.addSubview(profileSettingsBlurrViewButton)
        profileSettingsBlurrViewButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        
        view.addSubview(profileSettingsView)
        profileSettingsView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width * 0.66, height: 265)
        
        isProfileSettingsViewPresent = true
        profileSettingsView.delegate = self
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
        
        return CGSize(width: view.frame.width, height: 193)
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
            
            userProfileStatisticsCell.isUserMode = self.isUserMode
            userProfileStatisticsCell.user = self.user
            userProfileStatisticsCell.delegate = self
            
            if (self.isUserMode && self.didFetchUserTasks) || (!self.isUserMode && self.didFetchJugglerTasks) {
                userProfileStatisticsCell.tasksCount = self.isUserMode ? self.userTasksPostedCount : self.jugglerCompletedTasksCount
            }
            
            if self.didFetchReviews {
                userProfileStatisticsCell.intRating = self.isUserMode ? (self.userReviewsTotalRatingCount / (self.userReviews.count != 0 ? self.userReviews.count : 1)) : (self.jugglerReviewsTotalRatingCount / (self.jugglerReviews.count != 0 ? self.jugglerReviews.count : 1))
                userProfileStatisticsCell.reviewsCount = self.isUserMode ? self.userReviews.count : self.jugglerReviews.count
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
        return indexPath.item == 0 ? CGSize(width: view.frame.width, height: 195) : CGSize(width: view.frame.width, height: 200)
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
    func switchuserMode(forMode mode: Int) {
        self.isUserMode = mode == 0 ? true : false
        self.collectionView.reloadData()
        
        guard let user = self.user else {
            return
        }
        
        if (!self.isUserMode && !self.didFetchJugglerTasks) || (self.isUserMode && !self.didFetchUserTasks) {
            self.fetchTasks(forUser: user)
        }
    }
    
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
    
    func handleProfileImageView() {
        let alert = UIAlertController(title: "¿Quieres cambiar tu foto de perfil?", message: "", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "¡Si!", style: .default) { (_) in
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
            
            return
        }
        let cancelAction =  UIAlertAction(title: "Cancelar", style: .default, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(yesAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension ProfileVC: UserProfileStatisticsCellDelegate {
    func showReviews() {
        let userReviewsVC = UserReviewsVC(collectionViewLayout: UICollectionViewFlowLayout())
        userReviewsVC.reviews = self.isUserMode ? self.userReviews : self.jugglerReviews
        self.navigationController?.pushViewController(userReviewsVC, animated: true)
    }
}

extension ProfileVC: ProfileSettingsViewDelegete {
    func handleSettingsOption(option: Int) {
        if option == 0 { //Become a Juggler
            
            guard let isJuggler = self.user?.isJuggler, !isJuggler else {
                
                let okayAlert = UIView.okayAlert(title: "¡Felicidades! Ya eres Juggler", message: "")
                self.present(okayAlert, animated: true, completion: nil)
                return
            }
            
            let jugglerApplicationStepsNavVC = UINavigationController(rootViewController: JugglerApplicationStepsVC())
            jugglerApplicationStepsNavVC.modalPresentationStyle = .fullScreen
            
            self.present(jugglerApplicationStepsNavVC, animated: true, completion: nil)
            
        } else if option == 1 { //Terms and Consitions
            
            let termsAndConditionsVC = TermsAndConditionsVC()
            let navigationController = UINavigationController(rootViewController: termsAndConditionsVC)
            self.present(navigationController, animated: true, completion: nil)
            
        } else if option == 2 { //Logout
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Cerrar Sesión", style: .destructive, handler: { (_) in
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
            alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        
        self.handleSettingsBarButton() //Will simply remove side settings bar from superview and return
    }
}

// UIImagePickerControllerDelegate Delegate Extension
extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Set the selected image from image picker as profile picture
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
//        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
//            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
            
//        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
//            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
//        }
        
        // Make button perfectly round
//        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
//        plusPhotoButton.layer.masksToBounds = true
//        plusPhotoButton.layer.borderColor = UIColor.mainBlue().cgColor
//        plusPhotoButton.layer.borderWidth = 3
        
        // Dismiss image picker view
//        picker.dismiss(animated: true, completion: nil)
    }
}
