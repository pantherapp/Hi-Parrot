//
//  AppDelegate.swift
//  Parrot
//
//  Created by AngelDev on 4/27/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import CoreLocation
import EBBannerView
import GoogleMobileAds


var myUDID = String()
var deviceTokenString = ""
var userLocation = CLLocationCoordinate2D()
var myAddress = ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 13.0, *) {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.backgroundColor = .white
            window.makeKeyAndVisible()
            self.window = window
        }
        
//        application.applicationIconBadgeNumber = 0
        initLocationManager()
        FirebaseApp.configure()
        
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [
//            kGADSimulatorID as! String
//        ]

        // Initialize Google Mobile Ads SDK
//        GADMobileAds.sharedInstance().start()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert,UIUserNotificationType.badge, UIUserNotificationType.sound]
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)

        application.registerUserNotificationSettings(pushNotificationSettings)
        registerForPushNotifications()

        if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
           myUDID = deviceID
        }
        
        print("myUDID ===> ", myUDID)
        
        return true
    }

    
    //MARK:-   UISceneSession Lifecycle
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

    //MARK:-   set push notifations
    func registerForPushNotifications() {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .sound, .badge]//[.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {(granted, error) in
                if granted {
                    print("Permission granted: \(granted)")
                    DispatchQueue.main.async() {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            })
            
            Messaging.messaging().delegate = self
            Messaging.messaging().shouldEstablishDirectChannel = true
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }
    
    func getRegisteredPushNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            switch settings.authorizationStatus {
                case .authorized, .provisional:
                    print("The user agrees to receive notifications.")
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                case .denied:
                    print("Permission denied.")
                    // The user has not given permission. Maybe you can display a message remembering why permission is required.
                case .notDetermined:
                    print("The permission has not been determined, you can ask the user.")
                    self.getRegisteredPushNotifications()
                default:
                    return
            }
        })
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != [] {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        if let refreshedToken = InstanceID.instanceID().token() {
//            print("InstanceID token: \(refreshedToken)")
//        }
        print("Successfully registered for notifications!")
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""

        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
//        print("tokenString: \(tokenString)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
    
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager!.delegate = (self as CLLocationManagerDelegate)
        locationManager!.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager!.requestAlwaysAuthorization()
        locationManager!.startUpdatingLocation()
    }
    
}

extension AppDelegate : CLLocationManagerDelegate {
    
    // MARK:- CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
        if let location = locations.last{
//            print("my location lat: \(location.coordinate.latitude) lng: \(location.coordinate.longitude)")
            userLocation = location.coordinate
        }
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        let aps             = userInfo["aps"] as? [AnyHashable : Any]
        let badgeCount      = aps!["badge"] as? Int ?? 0
        let alertMessage    = aps!["alert"] as? [AnyHashable : Any]
        let bodyMessage     = alertMessage!["body"] as! String
        let titleMessage    = alertMessage!["title"] as! String
        
        
        if badgeCount > 0 {
            UIApplication.shared.applicationIconBadgeNumber = badgeCount
        } else {
            UIApplication.shared.applicationIconBadgeNumber += 1
        }
        
      
        NotificationCenter.default.post(name: Notification.Name("changedBadgeCount"), object: nil)
        
        let banner = EBBannerView.banner({ (make) in
            make?.style     = EBBannerViewStyle(rawValue: 12)
            make?.icon      = UIImage(named: "AppIcon")
            make?.title     = titleMessage
            make?.content   = bodyMessage
            make?.date      = "Now"
        })
         
        banner?.show()
        completionHandler([])
    }
}
//
extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        Messaging.messaging().subscribe(toTopic: "/topics/all")
        deviceTokenString = fcmToken
        print("fcmToken: ", fcmToken)
        
//        let sender = PushNotificationSender()
//        let tk = "ffK7OmRn30cRt2vja4kT9P:APA91bEsrvHzlqF3k6iLNNVJJuU4DuXqNxfrICShG5sOK1HkAGaKKN6Sr6vM85VII2Av31D-QdLGwGCuCRREQAyqTwZoXGn8j1oHFLc3kzg8vd3oDHNzKLdiVrBrQUuddkNvuKzGWI1Y"
//        sender.sendPushNotification(to: tk, title: APP_NAME, body: CONSTANT.NOTI_BODY, badgeCount: 5)
    }
}
