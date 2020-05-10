//
//  AppDelegate.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-18.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        attemptRegisterForAPNS(withApplication: application)
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Successfully registered for APNS!: \(deviceToken)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for APNS: \(error.localizedDescription)")
    }
    
    fileprivate func attemptRegisterForAPNS(withApplication application: UIApplication) {
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        // User push notification authorization
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (success, err) in
            if let error = err {
                print("Request for push notification auth rejected: \(error)")
                return
            }
            
            print(success ? "APNS auth success" : "APNS auth fail")
        }
        
        application.registerForRemoteNotifications()
    }
    
    // Receive Firebase Cloud Messaging token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Registered to FCM with token: \(fcmToken)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // The data passed through the notification
        let userInfo = response.notification.request.content.userInfo
        guard let type = userInfo["notificationType"] as? String else {
            return
        }
        
        if type == "review" {
            // Sow user reviews
            guard let isFromUserPerspective = userInfo["isFromUserPerspective"] as? String else {
                return
            }
            showReviews(forJuggler: isFromUserPerspective == "true" ? true : false)
        } else if type == "offer" {
            // Show offers in OnGoingTaskInteractionsVC
            guard let taskId = userInfo["taskId"] as? String else {
                return
            }
            showOffer(forTaskId: taskId)
        }
    }
    
    fileprivate func showOffer(forTaskId taskId: String) {
        let tasksRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).child(taskId)
        tasksRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String : Any] else {
                return
            }
            
            let task = Task(id: snapshot.key, dictionary: dictionary)
            let onGoingTaskInteractionsVC = OnGoingTaskInteractionsVC(collectionViewLayout: UICollectionViewFlowLayout())
            onGoingTaskInteractionsVC.task = task
            self.presentVC(vc: onGoingTaskInteractionsVC)
        }) { (error) in
            print("Error fetching task from AppDelegate: \(error)")
        }
    }
    
    fileprivate func showReviews(forJuggler: Bool) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        var userReviews = [Review]()
        var jugglerReviews = [Review]()
        
        let reviewsRef = Database.database().reference().child(Constants.FirebaseDatabase.reviewsRef).child(currentUserId)
        reviewsRef.observeSingleEvent(of: .value
            , with: { (snapshot) in
                guard let reviews = snapshot.value as? [String : [String : Any]] else {
                    return
                }
                
                reviews.forEach { (key, value) in
                    let review = Review(id: key, dictionary: value)
                    
                    if review.isFromUserPerspective {
                        jugglerReviews.append(review)
                        jugglerReviews.sort(by: { (review1, review2) -> Bool in
                            return review1.creationDate.compare(review2.creationDate) == .orderedDescending
                        })
                    } else {
                        userReviews.append(review)
                        userReviews.sort(by: { (review1, review2) -> Bool in
                            return review1.creationDate.compare(review2.creationDate) == .orderedDescending
                        })
                    }
                }
                let userReviewsVC = UserReviewsVC(collectionViewLayout: UICollectionViewFlowLayout())
                userReviewsVC.reviews = forJuggler ? jugglerReviews : userReviews
                self.presentVC(vc: userReviewsVC)
        }) { (error) in
            print("Error fetching reviews from AppDelegate: \(error)")
        }
    }
    
    fileprivate func presentVC(vc: UIViewController) {
        guard let mainTabBarController = SceneDelegate.window?.rootViewController as? MainTabBarController, let viewTasksNavVC = mainTabBarController.viewControllers?.first as? UINavigationController else {
            return
        }
        
        mainTabBarController.selectedIndex = 0
        viewTasksNavVC.pushViewController(vc, animated: true)
    }

    
    //MARK: Listen for user notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

