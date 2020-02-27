//
//  MainTabBarController.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-18.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.firstIndex(of: viewController)
        
        if index == 2 {
            let taskCategoryPickerVC = TaskCategoryPickerVC()
            let taskCategoryPickerNavController = UINavigationController(rootViewController: taskCategoryPickerVC)
            taskCategoryPickerNavController.modalPresentationStyle = .fullScreen
            
            self.present(taskCategoryPickerNavController, animated: true, completion: nil)
            
            return false
        } else {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        //Must be on main thread to present view from root view
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let logInVC = LoginVC()
                let loginNavController = UINavigationController(rootViewController: logInVC)
                loginNavController.modalPresentationStyle = .fullScreen

                self.present(loginNavController, animated: true, completion: nil)
                
                return
            }
        } else {
            setupViewControllers()
        }
    }
    
    func setupViewControllers() {
        //View Tasks
        let viewTasksNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "viewTasksTab"), selectedImage: #imageLiteral(resourceName: "viewTasksTab"), title: "Tareas", rootViewController: ViewTasksVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //Notifications
        let notificationsNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "notificationsTab"), selectedImage: #imageLiteral(resourceName: "notificationsTab"), title: "Notificaciones", rootViewController: NotificationsVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //Post a Task
        let postATaskVC = templateNavController(unselectedImage: #imageLiteral(resourceName: "postATaskTab"), selectedImage: #imageLiteral(resourceName: "postATaskTab"), title: "")
        
        //Dashboard
        let dashboardNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "dashboardTab"), selectedImage: #imageLiteral(resourceName: "dashboardTab"), title: "Mis Tareas", rootViewController: DashboardVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //Profile
        let profileNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "profileTab"), selectedImage: #imageLiteral(resourceName: "profileTab"), title: "Perfil", rootViewController: ProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        
        tabBar.tintColor = UIColor.mainBlue()
        self.viewControllers = [
            viewTasksNavController,
            notificationsNavController,
            postATaskVC,
            dashboardNavController,
            profileNavController
        ]
    }
    
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, title: String, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let vC = rootViewController
        let navVC = UINavigationController(rootViewController: vC)
        navVC.tabBarItem.image = unselectedImage
        navVC.tabBarItem.selectedImage = selectedImage
        navVC.tabBarItem.title = title
        
        return navVC
    }
}
