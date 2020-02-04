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
    
    var userAcceptedTasks = [FilteredTask]()
    var userTempAcceptedTasks = [FilteredTask]()
    
    var userCompletedTasks = [FilteredTask]()
    var userTempCompletedTasks = [FilteredTask]()
    
    //Juggler filteredTask arrays
    var jugglerAcceptedTasks = [FilteredTask]()
    var jugglerTempAcceptedTasks = [FilteredTask]()
    
    var jugglerCompletedTasks = [FilteredTask]()
    var jugglerTempCompletedTasks = [FilteredTask]()
    
    var jugglerSavedTasks = [FilteredTask]()
    var jugglerTempSavedTasks = [FilteredTask]()
    
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
        collectionView.register(AcceptedTaskCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.acceptedTaskCell)
        collectionView.register(CompletedTaskCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.completedTaskCell)
        collectionView.register(SavedTaskCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.savedTaskCell)
        
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
        } else {
            jugglerTempAcceptedTasks.removeAll()
            jugglerTempCompletedTasks.removeAll()
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
        navigationItem.title = "Tablero"
    }
    
    fileprivate func fetchTasks(forUserId userId: String, isUserMode: Bool) {
        if !canFetchTasks {
            return
        }
        canFetchTasks = false
        
        let childReference: String = isUserMode ? Constants.FirebaseDatabase.userTasksRef : Constants.FirebaseDatabase.jugglerTasksRef
        
        let userTasksRef = Database.database().reference().child(childReference).child(userId)
        userTasksRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let filteredTasksDictionary = snapshot.value as? [String : [String : Any]] else {
                print("Error fetching filtered tasks")
                self.canFetchTasks = true
                
                if isUserMode {
                    self.userOnGoingTasks.removeAll()
                    self.userAcceptedTasks.removeAll()
                    self.userTempCompletedTasks.removeAll()
                } else {
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
                    if filteredTask.status == 0 {
                        self.userTempOnGoingTasks.append(filteredTask)
                    } else if filteredTask.status == 1 {
                        self.userTempAcceptedTasks.append(filteredTask)
                    } else if filteredTask.status == 2 {
                        self.userTempCompletedTasks.append(filteredTask)
                    }
                } else { // else if task.mutuallyAcceptedBy == userId
                    if filteredTask.status == 1 {
                        self.jugglerAcceptedTasks.append(filteredTask)
                    } else if filteredTask.status == 2 {
                        self.jugglerTempCompletedTasks.append(filteredTask)
                    }
                }
                
                if filteredTasksCreated == filteredTasksDictionary.count {
                    if self.isUserMode {
                        self.userOnGoingTasks = self.userTempOnGoingTasks
                        self.userAcceptedTasks = self.userTempAcceptedTasks
                        self.userCompletedTasks = self.userTempCompletedTasks
                    } else {
                        self.jugglerAcceptedTasks = self.jugglerTempAcceptedTasks
                        self.jugglerCompletedTasks = self.jugglerTempCompletedTasks
                    }
                    
                    self.canFetchTasks = true
                    self.animateAndShowActivityIndicator(false)
                    self.removeNoResultsView()
                    
                    if self.isUserMode {
                        if self.filterOptionsValue == 1 && self.userTempOnGoingTasks.count == 0 {
                            self.showNoResultsFoundView()
                        } else if self.filterOptionsValue == 2 && self.userTempAcceptedTasks.count == 0 {
                            self.showNoResultsFoundView()
                        } else if self.filterOptionsValue == 3 && self.userTempCompletedTasks.count == 0 {
                            self.showNoResultsFoundView()
                        }
                    } else {
                        if self.filterOptionsValue == 2 && self.jugglerTempAcceptedTasks.count == 0 {
                            self.showNoResultsFoundView()
                        } else if self.filterOptionsValue == 3 && self.jugglerTempCompletedTasks.count == 0 {
                            self.showNoResultsFoundView()
                        } else if self.filterOptionsValue == 3 && self.userTempCompletedTasks.count == 0 {
                            self.showNoResultsFoundView()
                        } else if self.filterOptionsValue == 4 {
                            //FIXME: Does this need to be here?
                            self.showNoResultsFoundView()
                        }
                    }
                }
            }
        }) { (error) in
            print("Error fetching tasks DashboardVC: \(error)")
            self.canFetchTasks = true
            
            if isUserMode {
                self.userOnGoingTasks.removeAll()
                self.userAcceptedTasks.removeAll()
                self.userTempCompletedTasks.removeAll()
            } else {
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
            return self.isUserMode ? self.userOnGoingTasks.count : 0
        } else if self.filterOptionsValue == 2 {
            return self.isUserMode ? self.userAcceptedTasks.count : self.jugglerAcceptedTasks.count
        } else if self.filterOptionsValue == 3 {
            return self.isUserMode ? self.userCompletedTasks.count : self.jugglerCompletedTasks.count
        } else if self.filterOptionsValue == 4 {
            return self.jugglerSavedTasks.count
        } else {
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.filterOptionsValue == 1 {
            
            guard let onGoingTaskCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.onGoingTaskCell, for: indexPath) as? OnGoingTaskCell else {
                return UICollectionViewCell()
            }
            
            onGoingTaskCell.taskId = self.userOnGoingTasks[indexPath.item].id
            
            return onGoingTaskCell
            
        } else if self.filterOptionsValue == 2 {
            
            guard let acceptedTaskCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.acceptedTaskCell, for: indexPath) as? AcceptedTaskCell else {
                return UICollectionViewCell()
            }
            
            return acceptedTaskCell
            
        } else if self.filterOptionsValue == 3 {
            
            guard let completedTaskCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.onGoingTaskCell, for: indexPath) as? OnGoingTaskCell else {
                return UICollectionViewCell()
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
        return CGSize(width: view.frame.width, height: 175)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }
    
    //MARK: DashboardHeaderCell Methods
    // Add section header for collectionView a supplementary kind
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.CollectionViewCellIds.dashboardHeaderCell, for: indexPath) as? DashboardHeaderCell else { fatalError("Unable to dequeue DashboardHeaderCell")}
            
        headerCell.delegate = self
            
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
            if filterValue == 2 && self.jugglerAcceptedTasks.isEmpty {
                self.showNoResultsFoundView()
                return
            } else if filterValue == 3 && self.jugglerCompletedTasks.isEmpty {
                self.showNoResultsFoundView()
                return
            }else if filterValue == 4 && self.jugglerSavedTasks.isEmpty {
                self.showNoResultsFoundView()
                return
            }
        }
        
        self.removeNoResultsView()
        collectionView.reloadData()
    }
}