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
    
    // Display activity indicator while changing categories
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = UIColor.darkText
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
        queryTasksByDate()
    }
    
    fileprivate func setupTopNavigationBar() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "Ofertas de Trabajo"
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
            queryTasksByDate()
        } else {
            self.fetchFilteredTasksFor(category: self.currentCategory)
        }
    }
    
    fileprivate func queryTasksByDate() {
        if !canFetchTasks {
            return
        }
        self.canFetchTasks = false
        
        let databaseRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef)
        var query = databaseRef.queryOrdered(byChild: Constants.FirebaseDatabase.creationDate)
        
        var numberOfTasksToFetch: UInt = 20
        
        if self.tempAllTasks.count > 0 {
            let value = self.tempAllTasks.last?.creationDate.timeIntervalSince1970
            //Remove last task in array so it does not get duplicated when re-fetching
            self.tempAllTasks.removeLast()
            self.tasksFetched -= 1
            numberOfTasksToFetch = 21
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: numberOfTasksToFetch).observeSingleEvent(of: .value, with: { (taskDataSnapshot) in
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
                
                self.tempAllTasks.sort(by: { (task1, task2) -> Bool in
                    return task1.creationDate.compare(task2.creationDate) == .orderedDescending
                })
                
                if tasksCreated == tasksJSON.count {
                    self.allTasks = self.tempAllTasks
                    self.removeNoResultsView()
                    self.canFetchTasks = true
                    self.animateAndShowActivityIndicator(false)
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
                
                self.tempFilteredTask.sort(by: { (task1, task2) -> Bool in
                    return task1.creationDate.compare(task2.creationDate) == .orderedDescending
                })
                
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
        
        if self.currentCategory == Constants.TaskCategories.all {
            viewTaskCollectionViewCell.task = self.allTasks[indexPath.item]
        } else {
            viewTaskCollectionViewCell.task = self.filteredTasks[indexPath.item]
        }
        
        //Fetch again more tasks if collectionView hits bottom and if there are more tasks to fetch
        if indexPath.item == self.allTasks.count - 1 && (Double(self.tasksFetched % 20) == 0.0)  {
            if self.currentCategory == Constants.TaskCategories.all {
                self.queryTasksByDate()
            }
        }
        
        return viewTaskCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 175)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let taskInteractionVC = TaskInteractionVC(collectionViewLayout: UICollectionViewFlowLayout())
        taskInteractionVC.task = self.currentCategory == Constants.TaskCategories.all ? self.allTasks[indexPath.item] : self.filteredTasks[indexPath.item]
        taskInteractionVC.chatPartnerId = taskInteractionVC.task?.userId
        self.navigationController?.pushViewController(taskInteractionVC, animated: true)
    }
}

extension ViewTasksVC: ViewTasksHeaderCellDelegate {
    func didChangeCategory(to category: String) {
        if category == self.currentCategory {
            return
        }
        
        self.animateAndShowActivityIndicator(true)
        
        self.currentCategory = category
        self.tempFilteredTask.removeAll()
        self.collectionView.reloadData()
        
        if category == Constants.TaskCategories.all {
            self.queryTasksByDate()
        } else {
            self.fetchFilteredTasksFor(category: category)
        }
    }
}
