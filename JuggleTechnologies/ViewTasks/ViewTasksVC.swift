//
//  ViewTasksVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-18.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class ViewTasksVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //MARK: Stored properties
    var currentCategory = Constants.TaskCategories.all
    var tasksFetched = 0
    var canFetchTasks = true
    
    var allTasks = [Task]()
    var tempAllTasks = [Task]()
    
    var filteredTasks = [Task]()
    var tempFilteredTask = [Task]()
    
    let sortOptionsView = SortOptionsView()
    var isSortOptionsViewPresent: Bool = false
    var selectedSortOption = 0 // 0 == recientes, 1 == antiguos, 2 == presupuesto mayor, 3 == presupuesto menor
    
    lazy var sortBlurrViewButton: UIButton = {
        let  button = UIButton()
        button.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        button.addTarget(self, action: #selector(handleSortBlurrViewButton), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleSortBlurrViewButton() {
        sortBlurrViewButton.removeFromSuperview()
        sortOptionsView.removeFromSuperview()
        isSortOptionsViewPresent = false
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
        let view = UIView.noResultsView(withText: "No hay nuevas tareas en este momento.")
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
        collectionView?.alwaysBounceVertical = true
        
        //Register the collectionViewCells
        collectionView.register(ViewTasksHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.CollectionViewCellIds.viewTasksHeaderCell)
        collectionView.register(ViewTaskCollectionViewCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.viewTaskCollectionViewCell)
        
        // Manualy refresh the collectionView
        let refreshController = UIRefreshControl()
        refreshController.tintColor = UIColor.darkText
        refreshController.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshController
        
        setupActivityIndicator()
        animateAndShowActivityIndicator(true)
        
        setupTopNavigationBar()
        queryTasks()
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        Database.fetchLikedTasks(forUserId: currentUserId) { (refresh) in
            if refresh && self.canFetchTasks {
                self.collectionView.reloadData()
            }
        }
    }
    
    fileprivate func setupTopNavigationBar() {
        navigationItem.title = "Juggle"
        navigationController?.navigationBar.tintColor = .black
    }
    
    fileprivate func setupActivityIndicator() {
        view.addSubview(self.activityIndicator)
        self.activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc fileprivate func handleRefresh() {
        if !canFetchTasks {
            return
        }
        
        //Empty all temp arrays to allow new values to be stored
        self.tempAllTasks.removeAll()
        self.tempFilteredTask.removeAll()
        self.tasksFetched = 0
        
        if self.currentCategory == Constants.TaskCategories.all {
            queryTasks()
        } else {
            self.fetchFilteredTasksFor(category: self.currentCategory)
        }
    }
    
    fileprivate func queryTasks() {
        if !canFetchTasks {
            return
        }
        self.canFetchTasks = false
        
        let databaseRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef)
        
        var queryChild = ""

        if self.selectedSortOption == 0 || self.selectedSortOption == 1 {
            queryChild = Constants.FirebaseDatabase.creationDate
        } else if self.selectedSortOption == 2 || self.selectedSortOption == 3 {
            queryChild = Constants.FirebaseDatabase.taskBudget
        }
        
        var query = databaseRef.queryOrdered(byChild: queryChild)
        
        var numberOfTasksToFetch: UInt = 20
        
        if self.tempAllTasks.count > 0 {
            let creationDate = self.tempAllTasks.last?.creationDate.timeIntervalSince1970
            let budget = self.tempAllTasks.last?.budget
            
            //Remove last task in array so it does not get duplicated when re-fetching
            self.tempAllTasks.removeLast()
            self.tasksFetched -= 1
            numberOfTasksToFetch = 21
            query = (self.selectedSortOption == 0 || self.selectedSortOption == 2) ? query.queryEnding(atValue: self.selectedSortOption <= 1 ? creationDate : budget) : query.queryStarting(atValue: self.selectedSortOption <= 1 ? creationDate : budget)
            query = (self.selectedSortOption == 0 || self.selectedSortOption == 2) ? query.queryLimited(toLast: numberOfTasksToFetch) : query.queryLimited(toFirst: numberOfTasksToFetch)
        } else if self.tempAllTasks.count == 0 {
            query = (self.selectedSortOption == 0 || self.selectedSortOption == 2) ? query.queryLimited(toLast: numberOfTasksToFetch) : query.queryLimited(toFirst: numberOfTasksToFetch)
        }
        
        query.observeSingleEvent(of: .value, with: { (taskDataSnapshot) in
            guard let tasksJSON = taskDataSnapshot.value as? [String : [String : Any]] else {
                self.filteredTasks.removeAll()
                self.allTasks.removeAll()
                self.showNoResultsFoundView()
                self.canFetchTasks = true
                self.animateAndShowActivityIndicator(false)
                return
            }
            
            var tasksCreated = 0
            tasksJSON.forEach { (taskId, taskDictionary) in
                let task = Task(id: taskId, dictionary: taskDictionary)
                
                tasksCreated += 1
                self.tasksFetched += 1
                
                if task.status == 0 {
                    self.tempAllTasks.append(task)
                }
                
                if self.selectedSortOption == 0 { //Reciente a Antiguo
                    self.tempAllTasks.sort(by: { (task1, task2) -> Bool in
                        return task1.creationDate.compare(task2.creationDate) == .orderedDescending
                    })
                }  else if self.selectedSortOption == 1 { //Antiguo a Reciente
                    self.tempAllTasks.sort(by: { (task1, task2) -> Bool in
                        return task1.creationDate.compare(task2.creationDate) == .orderedAscending
                    })
                } else if self.selectedSortOption == 2 { //Presupuesto Mayor a Menor
                    self.tempAllTasks.sort(by: { (task1, task2) -> Bool in
                        return task1.budget > task2.budget
                    })
                } else if self.selectedSortOption == 3 { //Presupuesto Menor a Mayor
                    self.tempAllTasks.sort(by: { (task1, task2) -> Bool in
                        return task1.budget < task2.budget
                    })
                }
                
                if tasksCreated == tasksJSON.count {
                    self.allTasks = self.tempAllTasks
                    self.removeNoResultsView()
                    self.canFetchTasks = true
                    self.animateAndShowActivityIndicator(false)
                    
                    if self.allTasks.count == 0 {
                        self.showNoResultsFoundView()
                    }
                    
                    return
                }
            }
        }) { (error) in
            print("queryAllTasksByDate(): Error fetching tasks: ", error)
            self.allTasks.removeAll()
            self.filteredTasks.removeAll()
            self.showNoResultsFoundView()
            self.animateAndShowActivityIndicator(false)
        }
    }
    
    fileprivate func fetchFilteredTasksFor(category: String) {
        if !canFetchTasks {
            return
        }
        
        self.canFetchTasks = false
        
        let query = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).queryOrdered(byChild: Constants.FirebaseDatabase.taskCategory).queryEqual(toValue: category)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let tasksJSON = snapshot.value as? [String : [String : Any]] else {
                self.filteredTasks.removeAll()
                self.showNoResultsFoundView()
                self.canFetchTasks = true
                self.animateAndShowActivityIndicator(false)
                return
            }
            
            var tasksCreated = 0
            tasksJSON.forEach { (taskId, taskDictionary) in
                let task = Task(id: taskId, dictionary: taskDictionary)
                
                tasksCreated += 1
                
                if task.status == 0 && task.category == category {
                    self.tempFilteredTask.append(task)
                }
                
                if self.selectedSortOption == 0 { //Reciente a Antiguo
                    self.tempFilteredTask.sort(by: { (task1, task2) -> Bool in
                        return task1.creationDate.compare(task2.creationDate) == .orderedDescending
                    })
                } else if self.selectedSortOption == 1 { //Antiguo a Reciente
                    self.tempFilteredTask.sort(by: { (task1, task2) -> Bool in
                        return task1.creationDate.compare(task2.creationDate) == .orderedAscending
                    })
                } else if self.selectedSortOption == 2 { //Presupuesto Mayor a Menor
                    self.tempFilteredTask.sort(by: { (task1, task2) -> Bool in
                        return task1.budget > task2.budget
                    })
                } else if self.selectedSortOption == 3 { //Presupuesto Menor a Mayor
                    self.tempFilteredTask.sort(by: { (task1, task2) -> Bool in
                        return task1.budget < task2.budget
                    })
                }
                
                if tasksCreated == tasksJSON.count {
                    self.filteredTasks = self.tempFilteredTask
                    self.removeNoResultsView()
                    self.canFetchTasks = true
                    self.animateAndShowActivityIndicator(false)
                    
                    if self.tempFilteredTask.count == 0 {
                        self.showNoResultsFoundView()
                        return
                    }
                    
                    return
                }
            }
        }) { (error) in
            print("fetchFilteredTasksFor(category \(category): Error fetching tasks: ", error)
            self.allTasks.removeAll()
            self.filteredTasks.removeAll()
            self.showNoResultsFoundView()
            self.animateAndShowActivityIndicator(false)
        }
    }
    
    //MARK: UserProfileHeaderCell Methods
    // Add section header for collectionView a supplementary kind
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.CollectionViewCellIds.viewTasksHeaderCell, for: indexPath) as? ViewTasksHeaderCell else { fatalError("Unable to dequeue ViewTasksHeaderCell")}
        
        headerCell.delegate = self
        headerCell.selectedSortOption = self.selectedSortOption
        
        return headerCell
    }
    
    // Need to provide a size or the header will not render out
    // Define the size of the section header for the collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    //MARK: CollectionView methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.currentCategory == Constants.TaskCategories.all {
            return self.allTasks.count
        } else {
            return self.filteredTasks.count
        }
    }
    
    // What's the vertical spacing between each cell ?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewTaskCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.viewTaskCollectionViewCell, for: indexPath) as? ViewTaskCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let task = self.currentCategory == Constants.TaskCategories.all ? self.allTasks[indexPath.item] : self.filteredTasks[indexPath.item]
        viewTaskCollectionViewCell.task = task
        viewTaskCollectionViewCell.delegate = self
        
        //Fetch again more tasks if collectionView hits bottom and if there are more tasks to fetch
        if indexPath.item == self.allTasks.count - 1 && (Double(self.tasksFetched % 20) == 0.0)  {
            if self.currentCategory == Constants.TaskCategories.all {
                self.queryTasks()
            }
        }
        
        return viewTaskCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 175)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let task = self.currentCategory == Constants.TaskCategories.all ? self.allTasks[indexPath.item] : self.filteredTasks[indexPath.item]
        
        let taskInteractionVC = TaskInteractionVC(collectionViewLayout: UICollectionViewFlowLayout())
        taskInteractionVC.chatPartner = userCache[task.userId]
        taskInteractionVC.task = task
        self.navigationController?.pushViewController(taskInteractionVC, animated: true)
    }
}

extension ViewTasksVC: ViewTasksHeaderCellDelegate {
    func didChangeCategory(to category: String) {
        if category == self.currentCategory {
            return
        }
        
        self.animateAndShowActivityIndicator(true)
        self.removeNoResultsView()
        
        self.currentCategory = category
        self.tempFilteredTask.removeAll()
        self.collectionView.reloadData()
        
        if category == Constants.TaskCategories.all {
            self.queryTasks()
        } else {
            self.fetchFilteredTasksFor(category: category)
        }
    }
    
    func handleMapViewUIOption() {
        let alert = UIView.okayAlert(title: "Espera a la próxima versión de Juggle para ver el mapa", message: "")
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func handleSortButton() {
        if self.isSortOptionsViewPresent {
            self.sortOptionsView.removeFromSuperview()
            self.sortBlurrViewButton.removeFromSuperview()
            self.isSortOptionsViewPresent = false
            
            return
        }
        
        view.addSubview(sortBlurrViewButton)
        sortBlurrViewButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        
        view.addSubview(sortOptionsView)
        sortOptionsView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width * 0.66, height: 265)
        
        sortOptionsView.headerDelegate = self
        sortOptionsView.delegate = self
        sortOptionsView.selectedSortOption = self.selectedSortOption
        self.isSortOptionsViewPresent = true
    }
}

extension ViewTasksVC: SortOptionsViewDelegate {
    func sort(forSortOption sortOption: Int) {
        self.selectedSortOption = sortOption
        self.animateAndShowActivityIndicator(true)
        self.handleRefresh()
    }
}

extension ViewTasksVC: ViewTaskCollectionViewCellDelegate {
    fileprivate func updateLikedTasks(forUser user: User, task: Task, completion: @escaping (Bool) -> Void) {
        let values = [task.id : task.creationDate.timeIntervalSince1970]
        
        let likedTasksRef = Database.database().reference().child(Constants.FirebaseDatabase.likedTasksRef).child(user.userId)
        likedTasksRef.updateChildValues(values) { (err, _) in
            if let error = err {
                print("Error liking task: \(error)")
                let alert = UIView.okayAlert(title: "Error al Grabar", message: "Sal e intente nuevamente")
                self.present(alert, animated: true, completion: nil)
                completion(false)
                
                return
            }
            
            likedTasksCache[task.id] = task.creationDate.timeIntervalSince1970 as Double
            completion(true)
        }
    }
    
    func likeTask(_ task: Task, completion: @escaping (Bool) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            let alert = UIView.okayAlert(title: "Error al Grabar", message: "Sal e intente nuevamente")
            self.present(alert, animated: true, completion: nil)
            completion(false)
            
            return
        }
        
        if currentUserId == task.userId {
            completion(false)
            return
        }
        
        self.animateAndShowActivityIndicator(true)
        
        Database.fetchUserFromUserID(userId: currentUserId) { (usr) in
            guard let user = usr else {
                self.animateAndShowActivityIndicator(false)
                let alert = UIView.okayAlert(title: "Error al Grabar", message: "Sal e intente nuevamente")
                self.present(alert, animated: true, completion: nil)
                completion(false)
                
                return
            }
            
            if user.isJuggler {
                self.updateLikedTasks(forUser: user, task: task) { (succes) in
                    self.animateAndShowActivityIndicator(false)
                    completion(succes)
                }
            } else {
                DispatchQueue.main.async {
                    self.animateAndShowActivityIndicator(false)
                    
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
                }
                
                completion(false)
            }
        }
    }
    
    func unLikeTask(_ task: Task, completion: @escaping (Bool) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            let alert = UIView.okayAlert(title: "Error al Grabar", message: "Sal e intente nuevamente")
            self.present(alert, animated: true, completion: nil)
            completion(false)
            
            return
        }
        
        if currentUserId == task.userId {
            completion(false)
            return
        }
        
        self.animateAndShowActivityIndicator(true)
        
        let likedTaskRef = Database.database().reference().child(Constants.FirebaseDatabase.likedTasksRef).child(currentUserId).child(task.id)
        likedTaskRef.removeValue { (err, _) in
            
            self.animateAndShowActivityIndicator(false)
            
            if let error = err {
                print("Error unLiking task: \(error)")
                let alert = UIView.okayAlert(title: "Error al Grabar", message: "Sal e intente nuevamente")
                self.present(alert, animated: true, completion: nil)
                completion(false)
                
                return
            }
            
            likedTasksCache.removeValue(forKey: task.id)
            completion(true)
        }
    }
}
