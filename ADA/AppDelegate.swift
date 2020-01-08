//
//  AppDelegate.swift
//  ADA
//
//  Created by Azmi Muhammad on 18/09/19.
//  Copyright © 2019 Azmi Muhammad. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationController: UINavigationController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupCKNotification(application)
        setupRoot()
        return true
    }
    
    func findMe(uuid: String, completion: @escaping ((CKSubscription?, Error?)->Void)) {
        unsubscribeNotification()
        var subscription: CKQuerySubscription
        subscription = CKQuerySubscription(recordType: "Notifications", predicate: NSPredicate(format: "uuid == %@", uuid), options: .firesOnRecordCreation)
        
        let info = CKSubscription.NotificationInfo()
        
        info.titleLocalizationKey = "%1$@"
        info.titleLocalizationArgs = ["title"]
        
        info.alertLocalizationKey = "%1$@"
        info.alertLocalizationArgs = ["content"]
        
        info.shouldBadge = true
        info.soundName = "default"
        
        subscription.notificationInfo = info
        
        CKContainer.default().publicCloudDatabase.save(subscription, completionHandler: completion)
    }
    
    func unsubscribeNotification() {
        CKContainer.default().publicCloudDatabase.fetchAllSubscriptions(completionHandler: { subscriptions, error in
            if error != nil {
                return
            }
            
            if let subscriptions = subscriptions {
                for subscription in subscriptions {
                    CKContainer.default().publicCloudDatabase.delete(withSubscriptionID: subscription.subscriptionID, completionHandler: { string, error in
                        if(error != nil) {
                            print(error ?? "nil")
                            // deletion of subscription failed, handle error here
                        }
                    })
                }
            }
        })
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    private func setupCKNotification(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self

        // Request permission from user to send notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { authorized, error in
          if authorized {
            DispatchQueue.main.async(execute: {
              application.registerForRemoteNotifications()
            })
          }
        })
    }
    
    private func setupRoot() {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if let window = window {
            if Preference.isFaceIdDone() && Preference.isAccessGranted() {
                let homeVC = HomeVC()
                setRoot(window, homeVC)
            } else if Preference.isFaceIdDone() {
                let locVC = LocationVC()
                setRoot(window, locVC)
            } else {
                let faceIdVC = FaceIdVC()
                setRoot(window, faceIdVC)
            }
        }
    }
    
    private func setRoot<T: UIViewController>(_ window: UIWindow, _ vc: T) {
        navigationController = UINavigationController(rootViewController: vc)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
}

extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate{
    
  // This function will be called when the app receive notification
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    
    // show the notification alert (banner), and with sound
    completionHandler([.alert, .sound])
  }
  
  // This function will be called right after user tap on the notification
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    
    // tell the app that we have finished processing the user’s action (eg: tap on notification banner) / response
    completionHandler()
  }
}
