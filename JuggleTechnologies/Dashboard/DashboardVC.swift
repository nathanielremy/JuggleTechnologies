//
//  DashboardVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-18.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class DashboardVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //MARK: Stored properties
    var isUserMode: Bool = true
    var filterOptionsValue = 1 // 1 == onGoing, 2 == accepted, 3 == completed, 4 == saved
    
    var canFetchTasks = true
    
    //User filteredTask arrays
    var userOnGoingTasks = [FilteredTask]()
    var userTempOnGoingTasks = [FilteredTask]()
    var userOnGoingTasksDictionary = [String : Task]()
    
    var userAcceptedTasks = [FilteredTask]()
    var userTempAcceptedTasks = [FilteredTask]()
    var userAcceptedTasksDictionary = [String : Task]()
    
    var userCompletedTasks = [FilteredTask]()
    var userTempCompletedTasks = [FilteredTask]()
    
    //Juggler filteredTask arrays
    var jugglerTempOnGoingTasks = [FilteredTask]()
    var jugglerOnGoingTasks = [FilteredTask]()
    var jugglerOnGoingTasksDictionary = [String : Task]()
    
    var jugglerAcceptedTasks = [FilteredTask]()
    var jugglerTempAcceptedTasks = [FilteredTask]()
    var jugglerAcceptedTasksDictionary = [String : Task]()
    
    var jugglerCompletedTasks = [FilteredTask]()
    var jugglerTempCompletedTasks = [FilteredTask]()
    
    var jugglerSavedTasks = [FilteredTask]()
    var jugglerTempSavedTasks = [FilteredTask]()
    
    var didFetchJugglerTasks = false
    
    var acceptedIndex: Int? {
        didSet {
            guard let index = self.acceptedIndex else {
                return
            }
            self.userOnGoingTasks.remove(at: index)
            self.collectionView.reloadData()
        }
    }
    
    // Display activity indicator while changing categories
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
    }
    
    let noResultsView: UIView = {
        let view = UIView.noResultsView(withText: "No tienes tareas en este momento.")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    fileprivate func showNoResultsFoundView() {
        self.collectionView?.refreshControl?.endRefreshing()
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            self.collectionView?.addSubview(self.noResultsView)
            self.noResultsView.centerYAnchor.constraint(equalTo: (self.collectionView?.centerYAnchor)!).isActive = true
            self.noResultsView.centerXAnchor.constraint(equalTo: (self.collectionView?.centerXAnchor)!).isActive = true
        }
    }
    
    fileprivate func removeNoResultsView() {
        self.collectionView?.refreshControl?.endRefreshing()
        DispatchQueue.main.async {
            self.noResultsView.removeFromSuperview()
            self.collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        //Register the CollectionViewCells
        collectionView.register(DashboardHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.CollectionViewCellIds.dashboardHeaderCell)
        collectionView.register(OnGoingTaskCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.onGoingTaskCell)
        collectionView.register(AssignedTaskCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.assignedTaskCell)
        collectionView.register(SavedTaskCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.savedTaskCell)
        collectionView.register(ViewTaskCollectionViewCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.viewTaskCollectionViewCell)
        
        // Manualy refresh the collectionView
        let refreshController = UIRefreshControl()
        refreshController.tintColor = UIColor.darkText
        refreshController.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshController
        
        setupActivityIndicator()
        setupTopNavigationBar()
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("No currentUser.uid in DashboardVC.viewDidLoad")
            self.animateAndShowActivityIndicator(false)
            self.showNoResultsFoundView()
            return
        }
        
        self.fetchTasks(forUserId: currentUserId, isUserMode: true)
    }
    
    @objc fileprivate func handleRefresh() {
        if !canFetchTasks {
            return
        }
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("No currentUser.uid in DashboardVC.handleRefresh")
            self.animateAndShowActivityIndicator(false)
            self.showNoResultsFoundView()
            return
        }
        
        if isUserMode {
            userTempOnGoingTasks.removeAll()
            userTempAcceptedTasks.removeAll()
            userTempCompletedTasks.removeAll()
            userOnGoingTasksDictionary.removeAll()
        } else {
            jugglerTempOnGoingTasks.removeAll()
            jugglerTempAcceptedTasks.removeAll()
            jugglerTempCompletedTasks.removeAll()
            jugglerOnGoingTasksDictionary.removeAll()
            jugglerTempSavedTasks.removeAll()
            //self.fetchSavedTasks()
        }
        
        self.fetchTasks(forUserId: currentUserId, isUserMode: self.isUserMode)
    }
    
    fileprivate func setupActivityIndicator() {
        view.addSubview(self.activityIndicator)
        self.activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    fileprivate func setupTopNavigationBar() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "Mis Tareas"
    }
    
    fileprivate func fetchTasks(forUserId userId: String, isUserMode: Bool) {
        if !canFetchTasks {
            return
        }
        canFetchTasks = false
        
        //UserTasks or JugglerTasks
        let childReference: String = isUserMode ? Constants.FirebaseDatabase.userTasksRef : Constants.FirebaseDatabase.jugglerTasksRef
        
        if !self.didFetchJugglerTasks {
            self.didFetchJugglerTasks = childReference == Constants.FirebaseDatabase.jugglerTasksRef
        }
        
        let tasksRef = Database.database().reference().child(childReference).child(userId)
        tasksRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let filteredTasksDictionary = snapshot.value as? [String : [String : Any]] else {
                print("Error fetching filtered tasks")
                self.canFetchTasks = true
                
                if isUserMode {
                    self.userOnGoingTasks.removeAll()
                    self.userAcceptedTasks.removeAll()
                    self.userCompletedTasks.removeAll()
                } else {
                    self.jugglerOnGoingTasks.removeAll()
                    self.jugglerAcceptedTasks.removeAll()
                    self.jugglerCompletedTasks.removeAll()
                }
                
                self.showNoResultsFoundView()
                self.animateAndShowActivityIndicator(false)
                
                return
            }
            
            var filteredTasksCreated = 0
            filteredTasksDictionary.forEach { (key, value) in
                let filteredTask = FilteredTask(id: key, dictionary: value)
                filteredTasksCreated += 1
                
                if self.isUserMode {
                    if filteredTask.status == 0 { //OnGoing
                        self.userTempOnGoingTasks.append(filteredTask)
                        self.userTempOnGoingTasks.sort(by: { (task1, task2) -> Bool in
                            return task1.creationDate.compare(task2.creationDate) == .orderedDescending
                        })
                    } else if filteredTask.status == 1 { //Accepted
                        self.userTempAcceptedTasks.append(filteredTask)
                        self.userTempAcceptedTasks.sort(by: { (task1, task2) -> Bool in
                            return task1.acceptedDate.compare(task2.acceptedDate) == .orderedDescending
                        })
                    } else if filteredTask.status == 2 { //Completed
                        self.userTempCompletedTasks.append(filteredTask)
                        self.userTempCompletedTasks.sort(by: { (task1, task2) -> Bool in
                            return task1.completionDate.compare(task2.completionDate) == .orderedDescending
                        })
                    }
                } else {
                    if filteredTask.status == 0 { //OnGoing
                        self.jugglerTempOnGoingTasks.append(filteredTask)
                        self.jugglerTempOnGoingTasks.sort(by: { (task1, task2) -> Bool in
                            return task1.creationDate.compare(task2.creationDate) == .orderedDescending
                        })
                    } else if filteredTask.status == 1 { //Accepted
                        self.jugglerTempAcceptedTasks.append(filteredTask)
                        self.jugglerTempAcceptedTasks.sort(by: { (task1, task2) -> Bool in
                            return task1.acceptedDate.compare(task2.acceptedDate) == .orderedDescending
                        })
                    } else if filteredTask.status == 2 { //Completed
                        self.jugglerTempCompletedTasks.append(filteredTask)
                        self.jugglerTempCompletedTasks.sort(by: { (task1, task2) -> Bool in
                            return task1.completionDate.compare(task2.completionDate) == .orderedDescending
                        })
                    }
                }
                
                if filteredTasksCreated == filteredTasksDictionary.count {
                    self.canFetchTasks = true
                    self.animateAndShowActivityIndicator(false)
                    
                    if isUserMode {
                        self.userOnGoingTasks = self.userTempOnGoingTasks
                        self.userAcceptedTasks = self.userTempAcceptedTasks
                        self.userCompletedTasks = self.userTempCompletedTasks
                        
                        if self.filterOptionsValue == 1 && self.userOnGoingTasks.isEmpty {
                            self.showNoResultsFoundView()
                        } else if self.filterOptionsValue == 2 && self.userAcceptedTasks.isEmpty {
                            self.showNoResultsFoundView()
                        } else if self.filterOptionsValue == 3 && self.userCompletedTasks.isEmpty {
                            self.showNoResultsFoundView()
                        }
                    } else {
                        self.jugglerOnGoingTasks = self.jugglerTempOnGoingTasks
                        self.jugglerAcceptedTasks = self.jugglerTempAcceptedTasks
                        self.jugglerCompletedTasks = self.jugglerTempCompletedTasks
                        
                        if self.filterOptionsValue == 1 && self.jugglerOnGoingTasks.isEmpty {
                            self.showNoResultsFoundView()
                        } else if self.filterOptionsValue == 2 && self.jugglerAcceptedTasks.isEmpty {
                            self.showNoResultsFoundView()
                        } else if self.filterOptionsValue == 3 && self.jugglerCompletedTasks.isEmpty {
                            self.showNoResultsFoundView()
                        }
                    }
                    
                    self.removeNoResultsView()
                }
            }
        }) { (error) in
            print("Error fetching tasks DashboardVC: \(error)")
            self.canFetchTasks = true
            
            if isUserMode {
                self.userOnGoingTasks.removeAll()
                self.userAcceptedTasks.removeAll()
                self.userCompletedTasks.removeAll()
            } else {
                self.jugglerOnGoingTasks.removeAll()
                self.jugglerAcceptedTasks.removeAll()
                self.jugglerCompletedTasks.removeAll()
            }
            
            self.showNoResultsFoundView()
            self.animateAndShowActivityIndicator(false)
            
            return
        }
    }
    
    //MARK: CollectionView Delegate Methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.filterOptionsValue == 1 {
            return self.isUserMode ? self.userOnGoingTasks.count : self.jugglerOnGoingTasks.count
        } else if self.filterOptionsValue == 2 {
            return self.isUserMode ? self.userAcceptedTasks.count : self.jugglerAcceptedTasks.count
        } else if self.filterOptionsValue == 3 {
            return self.isUserMode ? self.userCompletedTasks.count : self.jugglerCompletedTasks.count
        } else if self.filterOptionsValue == 4 {
            return self.isUserMode ? 0 : self.jugglerSavedTasks.count
        } else {
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.filterOptionsValue == 1 && self.isUserMode {
            
            guard let onGoingTaskCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.onGoingTaskCell, for: indexPath) as? OnGoingTaskCell else {
                return UICollectionViewCell()
            }
            
            onGoingTaskCell.taskId = self.userOnGoingTasks[indexPath.item].id
            onGoingTaskCell.delegate = self
            
            return onGoingTaskCell
            
        } else if self.filterOptionsValue == 1 && !self.isUserMode {

            guard let viewTaskCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.viewTaskCollectionViewCell, for: indexPath) as? ViewTaskCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            viewTaskCollectionViewCell.taskId = self.jugglerOnGoingTasks[indexPath.item].id
            viewTaskCollectionViewCell.delegate = self
            
            return viewTaskCollectionViewCell
            
        } else if self.filterOptionsValue == 2 {
            
            guard let acceptedTaskCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.assignedTaskCell, for: indexPath) as? AssignedTaskCell else {
                return UICollectionViewCell()
            }
            
            acceptedTaskCell.taskId = nil
            acceptedTaskCell.task = nil
            acceptedTaskCell.taskPartner = nil
            acceptedTaskCell.delegate = self
            acceptedTaskCell.acceptedIndex = indexPath.item
            
            if self.isUserMode {
                acceptedTaskCell.taskId = self.userAcceptedTasks[indexPath.item].id
            } else {
                acceptedTaskCell.taskId = self.jugglerAcceptedTasks[indexPath.item].id
            }
            
            return acceptedTaskCell
            
        } else if self.filterOptionsValue == 3 {
            
            guard let completedTaskCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.assignedTaskCell, for: indexPath) as? AssignedTaskCell else {
                return UICollectionViewCell()
            }
            
            completedTaskCell.taskId = nil
            completedTaskCell.task = nil
            completedTaskCell.taskPartner = nil
            completedTaskCell.delegate = self
            
            if self.isUserMode {
                completedTaskCell.taskId = self.userCompletedTasks[indexPath.item].id
            } else {
                completedTaskCell.taskId = self.jugglerCompletedTasks[indexPath.item].id
            }
            
            return completedTaskCell
            
        } else if self.filterOptionsValue == 4 {
            
            guard let savedTaskCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.savedTaskCell, for: indexPath) as? SavedTaskCell else {
                return UICollectionViewCell()
            }
            
            return savedTaskCell
            
        } else {
            return UICollectionViewCell()
        }
    }
    
    // What's the vertical spacing between each cell ?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return (self.filterOptionsValue == 1 && self.isUserMode) ? CGSize(width: view.frame.width, height: 195) : CGSize(width: view.frame.width, height: 175)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.filterOptionsValue == 1 && self.isUserMode { //OnGoingTaskCell
            
            let onGoingTaskInteractionsVC = OnGoingTaskInteractionsVC(collectionViewLayout: UICollectionViewFlowLayout())
            onGoingTaskInteractionsVC.dashboardVC = self
            onGoingTaskInteractionsVC.dashboardVCTaskIndex = indexPath.item
            onGoingTaskInteractionsVC.task = self.userOnGoingTasksDictionary[self.userOnGoingTasks[indexPath.item].id]
            self.navigationController?.pushViewController(onGoingTaskInteractionsVC, animated: true)
            
        } else if self.filterOptionsValue == 1 && !self.isUserMode {
            guard let task = self.jugglerOnGoingTasksDictionary[self.jugglerOnGoingTasks[indexPath.item].id] else {
                return
            }
            
            let taskInteractionVC = TaskInteractionVC(collectionViewLayout: UICollectionViewFlowLayout())
            taskInteractionVC.chatPartner = userCache[task.userId]
            taskInteractionVC.task = task
            self.navigationController?.pushViewController(taskInteractionVC, animated: true)
        } else if self.filterOptionsValue == 2 {
            guard let task = (self.isUserMode ? self.userAcceptedTasksDictionary[self.userAcceptedTasks[indexPath.item].id] : self.jugglerAcceptedTasksDictionary[self.jugglerAcceptedTasks[indexPath.item].id]), let assignedJugglerId = task.assignedJugglerId else {
                return
            }
            
            let chatPartnerId = self.isUserMode ? assignedJugglerId : task.userId
            
            Database.fetchUserFromUserID(userID: chatPartnerId) { (user) in
                if let chatPartner = user {
                    let dashboardChatlogVC = DashboardChatLogVC(collectionViewLayout: UICollectionViewFlowLayout())
                    dashboardChatlogVC.chatPartner = chatPartner
                    dashboardChatlogVC.task = task
                    self.navigationController?.pushViewController(dashboardChatlogVC, animated: true)
                }
            }
        }
    }
    
    //MARK: DashboardHeaderCell Methods
    // Add section header for collectionView a supplementary kind
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.CollectionViewCellIds.dashboardHeaderCell, for: indexPath) as? DashboardHeaderCell else { fatalError("Unable to dequeue DashboardHeaderCell")}
            
        headerCell.delegate = self
        headerCell.isUserMode = self.isUserMode
            
        return headerCell
    }
        
    // Need to provide a size or the header will not render out
    // Define the size of the section header for the collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
}

extension DashboardVC: DashboardHeaderCellDelegate {
    func changeFilterOptions(forFilterValue filterValue: Int, isUserMode: Bool) {
        self.isUserMode = isUserMode
        self.filterOptionsValue = filterValue
        
        if isUserMode {
            if filterValue == 1 && self.userOnGoingTasks.isEmpty {
                self.showNoResultsFoundView()
                return
            } else if filterValue == 2 && self.userAcceptedTasks.isEmpty {
                self.showNoResultsFoundView()
                return
            } else if filterValue == 3 && self.userCompletedTasks.isEmpty {
                self.showNoResultsFoundView()
                return
            }
        } else {
            if !self.didFetchJugglerTasks {
                if let userId = Auth.auth().currentUser?.uid {
                    self.animateAndShowActivityIndicator(true)
                    self.fetchTasks(forUserId: userId, isUserMode: false)
                    return
                }
            }
            
            if filterValue == 1 && self.jugglerOnGoingTasks.isEmpty {
                self.showNoResultsFoundView()
                return
            } else if filterValue == 2 && self.jugglerAcceptedTasks.isEmpty {
                self.showNoResultsFoundView()
                return
            } else if filterValue == 3 && self.jugglerCompletedTasks.isEmpty {
                self.showNoResultsFoundView()
                return
            } else if filterValue == 4 && self.jugglerSavedTasks.isEmpty {
                self.showNoResultsFoundView()
                return
            }
        }
        
        self.removeNoResultsView()
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
}

extension DashboardVC: OnGoingTaskCellDelegate {
    func addUserOnGoingTaskToDictionary(forTask task: Task) {
        self.userOnGoingTasksDictionary[task.id] = task
    }
    
    func addJugglerOnGoingTaskToDictionary(forTask task: Task) {
        self.jugglerOnGoingTasksDictionary[task.id] = task
    }
}

extension DashboardVC: AssignedTaskCellDelegate {
    func cancelOrShowDetails(forTask task: Task?, taskPartner: User?) {
        guard let task = task, let taskPartner = taskPartner else {
            return
        }
        
        guard task.status == 1 else {
            let taskDetailsVC = TaskDetailsVC()
            taskDetailsVC.task = task
            Database.fetchUserFromUserID(userID: task.userId) { (usr) in
                if let user = usr {
                    taskDetailsVC.user = user
                }
            }
            self.present(taskDetailsVC, animated: true, completion: nil)
            return
        }
        
        
    }
    
    func completeOrReviewTask(task: Task?, taskPartner: User?, index: Int?) {
        guard let task = task, let taskPartner = taskPartner, let currentUserId = Auth.auth().currentUser?.uid, let index = index else {
            let alert = UIView.okayAlert(title: "No se puede completar esta tarea", message: "Sal e intente nuevamente")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if task.status == 1 {
            guard task.userId == taskPartner.userId else {
                let alert = UIView.okayAlert(title: "No se puede completar esta tarea", message: "")
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let completeAlert = UIAlertController(title: "¿Seguro?", message: "Esta tarea se marcará como completada indefinidamente.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
            let completarAction = UIAlertAction(title: "Completar", style: .default) { (_) in
                let jugglerId = task.assignedJugglerId ?? (task.userId == currentUserId ? taskPartner.userId : currentUserId)
                self.completeTask(forTaskId: task.id, userId: task.userId, jugglerId: jugglerId, acceptedIndex: index)
            }
            
            completeAlert.addAction(cancelAction)
            completeAlert.addAction(completarAction)
            self.present(completeAlert, animated: true, completion: nil)
        } else if task.status == 2 {
            
            let reviewProfileVC = ReviewProfileVC()
            reviewProfileVC.task = task
            reviewProfileVC.user = taskPartner
            
            if task.userId != taskPartner.userId && !task.isJugglerReviewed { //Review Juggler
                reviewProfileVC.isReviewingUser = false
            } else if !task.isUserReviewed { //Review User
                reviewProfileVC.isReviewingUser = true
            }
            
            let reviewNavVC =  UINavigationController(rootViewController: reviewProfileVC)
            self.present(reviewNavVC, animated: true, completion: nil)
        }
    }
    
    func completeTask(forTaskId taskId: String, userId: String, jugglerId: String, acceptedIndex: Int) {
        self.animateAndShowActivityIndicator(true)
        
        let completedDate = Date().timeIntervalSince1970
        
        // Update tasks Node
        let tasksRefValues: [String : Any] = [
            Constants.FirebaseDatabase.isJugglerComplete : true,
            Constants.FirebaseDatabase.taskStatus : 2,
            Constants.FirebaseDatabase.completionDate : completedDate
        ]
        
        let tasksRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).child(taskId)
        tasksRef.updateChildValues(tasksRefValues) { (err, _) in
            if let error = err {
                print("Error updating tasksRefNode: \(error)")
                DispatchQueue.main.async {
                    self.animateAndShowActivityIndicator(false)
                    let alert = UIView.okayAlert(title: "No se puede completar esta tarea", message: "Sal e intente nuevamente")
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            // Update userTasks Node
            let userTasksRefValues: [String : Any] = [
                Constants.FirebaseDatabase.taskStatus : 2,
                Constants.FirebaseDatabase.completionDate : completedDate
            ]
            
            let userTasksRef = Database.database().reference().child(Constants.FirebaseDatabase.userTasksRef).child(userId).child(taskId)
            userTasksRef.updateChildValues(userTasksRefValues) { (err, _) in
                if let error = err {
                    print("Error updating userTasksNode: \(error)")
                    DispatchQueue.main.async {
                        self.animateAndShowActivityIndicator(false)
                        let alert = UIView.okayAlert(title: "No se puede completar esta tarea", message: "Sal e intente nuevamente")
                        self.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                
                // Update jugglerTasks Node
                let jugglerTasksRefValues: [String : Any] = [
                    Constants.FirebaseDatabase.taskStatus : 2,
                    Constants.FirebaseDatabase.completionDate : completedDate
                ]
                
                let jugglerTasksRef = Database.database().reference().child(Constants.FirebaseDatabase.jugglerTasksRef).child(jugglerId).child(taskId)
                jugglerTasksRef.updateChildValues(jugglerTasksRefValues) { (err, _) in
                    if let error = err {
                        print("Error updating jugglerTasksNode: \(error)")
                        DispatchQueue.main.async {
                            self.animateAndShowActivityIndicator(false)
                            let alert = UIView.okayAlert(title: "No se puede completar esta tarea", message: "Sal e intente nuevamente")
                            self.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.animateAndShowActivityIndicator(false)
                        self.jugglerAcceptedTasks.remove(at: acceptedIndex)
                        self.collectionView.reloadData()
                        
                        if self.jugglerAcceptedTasks.count == 0 {
                            self.showNoResultsFoundView()
                        }
                        
                        print("Review User")
                    }
                }
            }
        }
    }
    
    func addAssignedTaskToDictionary(forTask task: Task) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("No currentUserId")
            return
        }
        
        if task.userId == currentUserId {
            self.userAcceptedTasksDictionary[task.id] = task
        } else {
            self.jugglerAcceptedTasksDictionary[task.id] = task
        }
    }
}
