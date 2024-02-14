//
//  AppDelegate.swift
//  TSADMChat
//
//  Created by Jose Ignacio Trasobares Ibor on 1/2/24.
//
import SwiftUI
import CloudKit

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        Thread.sleep(forTimeInterval: 2.0)
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) {
            completionHandler(.newData)
        }
        NotificationCenter.default.post(name: NSNotification.Name("Download"), object: self)
    }
    
    // Handle remote notification registration.
    func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenComponents = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let deviceTokenString = tokenComponents.joined()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        NotificationCenter.default.post(name: NSNotification.Name("Download"), object: self)
        completionHandler(.list)
    }
    
    
    
    
}
