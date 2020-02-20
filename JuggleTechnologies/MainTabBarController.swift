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
        let viewTasksNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "viewTasksUnselected"), selectedImage: #imageLiteral(resourceName: "viewTasksUnselected"), rootViewController: ViewTasksVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //Notifications
        let notificationsNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "NotificationsPH"), selectedImage: #imageLiteral(resourceName: "NotificationsPH"), rootViewController: NotificationsVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //Post a Task
        let postATaskVC = templateNavController(unselectedImage: #imageLiteral(resourceName: "PostATaskPH"), selectedImage: #imageLiteral(resourceName: "PostATaskPH"))
        
        //Dashboard
        let dashboardNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "MyTasksPH"), selectedImage: #imageLiteral(resourceName: "MyTasksPH"), rootViewController: DashboardVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //Profile
        let profileNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "ProfilePH"), selectedImage: #imageLiteral(resourceName: "ProfilePH"), rootViewController: ProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        
        //FIXME: Fix tabBar's tint color
        self.viewControllers = [
            viewTasksNavController,
            notificationsNavController,
            postATaskVC,
            dashboardNavController,
            profileNavController
        ]
    }
    
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let vC = rootViewController
        let navVC = UINavigationController(rootViewController: vC)
        navVC.tabBarItem.image = unselectedImage
        navVC.tabBarItem.selectedImage = selectedImage
        
        return navVC
    }
}
