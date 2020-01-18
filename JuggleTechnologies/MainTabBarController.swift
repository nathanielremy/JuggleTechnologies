//
//  MainTabBarController.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-18.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import Foundation
import UIKit

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
        DispatchQueue.main.async {
            //If user is logged out, present the login VC
        }
        
        setupViewControllers()
    }
    
    func setupViewControllers() {
        //View Tasks
        let viewTasksNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "ViewTasksPH"), selectedImage: #imageLiteral(resourceName: "ViewTasksPH"), rootViewController: ViewTasksVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //Notifications
        let notificationsNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "NotificationsPH"), selectedImage: #imageLiteral(resourceName: "NotificationsPH"), rootViewController: NotificationsVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //Post a Task
        let postATaskVC = templateNavController(unselectedImage: #imageLiteral(resourceName: "PostATaskPH"), selectedImage: #imageLiteral(resourceName: "PostATaskPH"))
        
        //My Tasks
        let myTasksNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "MyTasksPH"), selectedImage: #imageLiteral(resourceName: "MyTasksPH"), rootViewController: MyTasksVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //Profile
        let profileNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "ProfilePH"), selectedImage: #imageLiteral(resourceName: "ProfilePH"), rootViewController: ProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        
        //FIXME: Fix tabBar's tint color
        self.viewControllers = [
            viewTasksNavController,
            notificationsNavController,
            postATaskVC,
            myTasksNavController,
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
