//
//  Extensions.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-01-18.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

var userCache = [String : User]()

//MARK: Firebase Auth
extension Auth {
    static func loginUser(withEmail email: String, passcode: String, completion: @escaping (User?, String?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: passcode) { (usr, err) in
            if let error = err {
                completion(nil, error.localizedDescription); return
            }
            
            guard let firebaseData = usr else {
                completion(nil, "Ext/Auth: No firebaseUser returned in closure."); return
            }
            
            Database.fetchUserFromUserID(userID: firebaseData.user.uid, completion: { (usr) in
                guard let user = usr else {
                    completion(nil, "Ext/Auth: No firebaseUser returned in closure."); return
                }
                
                completion(user, nil); return
            })
        }
    }
}

//MARK: Firebase Database
extension Database {
    static func fetchUserFromUserID(userID: String, completion: @escaping (User?) -> Void) {
        // Check if we have already fetched the user
        if let user = userCache[userID] {
            completion(user)
            
            return
        }
        
        Database.database().reference().child(Constants.FirebaseDatabase.usersRef).child(userID).observeSingleEvent(of: .value, with: { (datasnapshot) in

            guard let userDictionary = datasnapshot.value as? [String : Any] else {
                completion(nil)
                print("Ext/Database: Error from fetchUserFromUserID converting datasnapshot.value as [String : Any]")
                
                return
            }

            let user = User(userId: userID, dictionary: userDictionary)
            userCache[userID] = user
            
            completion(user)

        }) { (error) in
            print("Ext/Database: Error from fetchUserFromUserID: ", error)
            completion(nil)
        }
    }
}

//MARK: UIColor
extension UIColor {
    static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
    
    static func mainBlue() -> UIColor {
        return rgb(58, 202, 187)
    }
//
//    static func mainAmarillo() -> UIColor {
//        return rgb(249, 186, 0)
//    }
//
    static func chatBubbleGray() -> UIColor {
        return rgb(240, 240, 240)
    }
}

//MARK: UIView
extension UIView {
    static func okayAlert(title: String, message: String) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .cancel , handler: nil)
        alertController.addAction(okAction)
        
        return alertController
    }
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat?, height: CGFloat?) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: paddingRight).isActive = true
        }
        
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    static func noResultsView(withText text: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        let label = UILabel()
        label.text = text
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        return containerView
    }
}

//MARK: Date
extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "segundo"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "minuto"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hora"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "día"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "semana"
        } else {
            quotient = secondsAgo / month
            unit = "mes"
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "" : (unit != "mes" ? "s" : "es"))"
    }
}

//MARK: UIDevice
extension UIDevice {
    enum DeviceModelName: String {
        
        case undefined
        case iPodTouch5
        case iPodTouch6
        case iPhone4
        case iPhone4s
        case iPhone5
        case iPhone5c
        case iPhone5s
        case iPhone6
        case iPhone6Plus
        case iPhone6s
        case iPhone6sPlus
        case iPhone7
        case iPhone7Plus
        case iPhoneSE
        case iPhone8
        case iPhone8Plus
        case iPhoneX
        case iPhoneXS
        case iPhoneXSMax
        case iPhoneXR
        case iPad2
        case iPad3
        case iPad4
        case iPadAir
        case iPadAir2
        case iPad5
        case iPad6
        case iPadMini
        case iPadMini2
        case iPadMini3
        case iPadMini4
        case iPadPro97Inch
        case iPadPro129Inch
        case iPadPro129Inch2ndGen
        case iPadPro105Inch
        case iPadPro11Inch
        case iPadPro129Inch3rdGen
        case AppleTV
        case AppleTV4K
        case HomePod
        case iPhone11
    }
    
    // pairs the deveice name as the standard name
    var modelName: DeviceModelName {
        
        #if targetEnvironment(simulator)
        let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
        #else
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        #endif
        
        switch identifier {
        case "iPod5,1":                                 return .iPodTouch5
        case "iPod7,1":                                 return .iPodTouch6
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return .iPhone4
        case "iPhone4,1":                               return .iPhone4s
        case "iPhone5,1", "iPhone5,2":                  return .iPhone5
        case "iPhone5,3", "iPhone5,4":                  return .iPhone5c
        case "iPhone6,1", "iPhone6,2":                  return .iPhone5s
        case "iPhone7,2":                               return .iPhone6
        case "iPhone7,1":                               return .iPhone6Plus
        case "iPhone8,1":                               return .iPhone6s
        case "iPhone8,2":                               return .iPhone6sPlus
        case "iPhone9,1", "iPhone9,3":                  return .iPhone7
        case "iPhone9,2", "iPhone9,4":                  return .iPhone7Plus
        case "iPhone8,4":                               return .iPhoneSE
        case "iPhone10,1", "iPhone10,4":                return .iPhone8
        case "iPhone10,2", "iPhone10,5":                return .iPhone8Plus
        case "iPhone10,3", "iPhone10,6":                return .iPhoneX
        case "iPhone11,2":                              return .iPhoneXS
        case "iPhone11,4", "iPhone11,6":                return .iPhoneXSMax
        case "iPhone11,8":                              return .iPhoneXR
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return .iPad2
        case "iPad3,1", "iPad3,2", "iPad3,3":           return .iPad3
        case "iPad3,4", "iPad3,5", "iPad3,6":           return .iPad4
        case "iPad4,1", "iPad4,2", "iPad4,3":           return .iPadAir
        case "iPad5,3", "iPad5,4":                      return .iPadAir2
        case "iPad6,11", "iPad6,12":                    return .iPad5
        case "iPad7,5", "iPad7,6":                      return .iPad6
        case "iPad2,5", "iPad2,6", "iPad2,7":           return .iPadMini
        case "iPad4,4", "iPad4,5", "iPad4,6":           return .iPadMini2
        case "iPad4,7", "iPad4,8", "iPad4,9":           return .iPadMini3
        case "iPad5,1", "iPad5,2":                      return .iPadMini4
        case "iPad6,3", "iPad6,4":                      return .iPadPro97Inch
        case "iPad6,7", "iPad6,8":                      return .iPadPro129Inch
        case "iPad7,1", "iPad7,2":                      return .iPadPro129Inch2ndGen
        case "iPad7,3", "iPad7,4":                      return .iPadPro105Inch
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return .iPadPro11Inch
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return .iPadPro129Inch3rdGen
        case "AppleTV5,3":                              return .AppleTV
        case "AppleTV6,2":                              return .AppleTV4K
        case "AudioAccessory1,1":                       return .HomePod
        case "iPhone12,1", "iPhone12,5", "iPhone12,3":  return .iPhone11
            
        default:                                        return .undefined
        }
    }
    
    func getDeviceSafeAreaInsetsHeightEstimation() -> CGFloat {
        if (self.modelName == .iPhoneX) || (self.modelName == .iPhoneXS) || (self.modelName == .iPhoneXSMax) || (self.modelName == .iPhoneXR) || (self.modelName == .iPhone11) {
            return 88
        } else {
            return 64
        }
    }
}
