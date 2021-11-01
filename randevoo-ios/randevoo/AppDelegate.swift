//
//  AppDelegate.swift
//  randevoo
//
//  Created by Lex on 8/11/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseMessaging
import GoogleMaps
import GooglePlaces
import GoogleSignIn
import FirebaseAuth
import FBSDKCoreKit
import Cache
import ObjectMapper
import IQKeyboardManagerSwift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    var gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
                
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false

        let current = Firestore.firestore()
        current.settings = settings
        
        GIDSignIn.sharedInstance().clientID = "replace-your-api-key"
        GIDSignIn.sharedInstance()?.delegate = self
        GMSServices.provideAPIKey("replace-your-api-key")
        GMSPlacesClient.provideAPIKey("replace-your-api-key")
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        // For enable Facebook Authentication
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        application.applicationIconBadgeNumber = 0
        
        let mainTabBarController = MainTabBarController()
        let mainController = MainController()
        mainController.mainTabBarController = mainTabBarController
        let navController = UINavigationController(rootViewController: mainController)
        navController.isNavigationBarHidden = false
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.isTranslucent = false
        navController.navigationBar.barTintColor = UIColor.randevoo.mainLight
        navController.modalPresentationStyle = .fullScreen
        let defaults = UserDefaults.standard
        let signIn = defaults.object(forKey: "signIn")
        if let check = signIn as? [String: Any] {
            let signIn = check["isSignIn"] as! Bool
            if signIn {
                isSignIn = true
                if let personalCache: PersonalAccount = FCache.get("personal"), !FCache.isExpired("personal") {
//                    mainTabBarController.personalAccount = personalCache
                    personalAccount = personalCache
//                    let personalJson = Mapper().toJSONString(personalCache, prettyPrint: true)!
//                    print("Retrieved Cache Personal at AppDelegate: \(personalJson)")
                    if let businessCache: BusinessAccount = FCache.get("business"), !FCache.isExpired("business") {
//                        mainTabBarController.businessAccount = businessCache
                        businessAccount = businessCache
//                        let businessJson = Mapper().toJSONString(businessCache, prettyPrint: true)!
//                        print("Retrieved Cache Business at AppDelegate: \(businessJson)")
                    }
                }
                print("Sign In 1")
                window?.rootViewController = mainTabBarController
            } else {
                print("Sign Out 1")
                window?.rootViewController = mainTabBarController
                window?.rootViewController?.present(navController, animated: false, completion: nil)

            }
        } else {
            print("Sign Out 2")
            window?.rootViewController = mainTabBarController
            window?.rootViewController?.present(navController, animated: false, completion: nil)
        }
        
        // Cloud Messaging
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(MessageController.self)
        return true
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        print("User email: \(user.profile.email ?? "No email")")
        if let error = error {
          if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
            print("The user has not signed in before or they have since signed out.")
          } else {
            print("\(error.localizedDescription)")
          }
          return
        }
        // Perform any operations on signed in user here.
        // For client-side use only!
        let _ = user.userID
        // Safe to send to the server
//        let idToken = user.authentication.idToken
//        let fullName = user.profile.name
//        let givenName = user.profile.givenName
//        let familyName = user.profile.familyName
//        let email = user.profile.email
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // For enable Facebook Authentication
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        return GIDSignIn.sharedInstance().handle(url)
    }
        


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
//        application.applicationIconBadgeNumber = 0
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      if let messageID = userInfo[gcmMessageIDKey] {
        print("Third Message ID: \(messageID)")
      }

      // Print full message.
//      print(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Fourth Message ID: \(messageID)")
      }

      // Print full message.
//      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }
    
}

extension AppDelegate: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            print("No FCM Registration Token")
            return
        }
        print("Firebase registration token: \(String(token))")
//        Messaging.messaging().token { token, error in
//          if let error = error {
//            print("Error fetching FCM registration token: \(error)")
//          } else if let token = token {
//            print("FCM registration token: \(token)")
//          }
//        }
    }
}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("First Message ID: \(messageID)")
        }
        let notification = Mapper<Notification>().map(JSONObject: userInfo)!
        let notificationJson = Mapper().toJSONString(notification, prettyPrint: true)!
        print("Notification Idle: \(notificationJson)")
        
        // Change this to your preferred presentation option
        if notification.senderId == currentMemberId && currentMemberId != "" {
            completionHandler([])
        } else {
            completionHandler([[.alert, .badge, .sound]])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let messagesProvider = MessagesProvider()
        let accountsProvider = AccountsProvider()
        let deviceProvider = DevicesProvider()
        let switchProvider = SwitchProvider()
        let alertHelper = AlertHelper()
        
        
        let userInfo = response.notification.request.content.userInfo
        
        let notification = Mapper<Notification>().map(JSONObject: userInfo)!
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Second Message ID: \(messageID)")
        }
        let notificationJson = Mapper().toJSONString(notification, prettyPrint: true)!
        print("Notification: \(notificationJson)")
        if notification.content == "message" {
            let tabBarController = self.window?.rootViewController as? UITabBarController
            let navController = tabBarController!.selectedViewController as? UINavigationController
            
            if notification.receiverId == currentAccountId {
                messagesProvider.fetchMessenger(messengerId: notification.messengerId).then { (messenger) in
                    print("Check current", currentAccountId)
                    let controller = MessageController()
                    controller.messenger = messenger
                    navController!.pushViewController(controller, animated: true)
                }
            } else {
                if notification.receiverId == personalAccount?.id {
                    guard let user = personalAccount else { return }
                    deviceProvider.validateDeviceToken(accountId: user.id)
                    switchProvider.startSwitchAccount(mainTabBarController: tabBarController!, accountId: user.id, isPersonal: true)
                    messagesProvider.fetchMessenger(messengerId: notification.messengerId).then { (messenger) in
                        print("Checking Personal", String(user.id))
                        print("Check current", currentAccountId)
                        let controller = MessageController()
                        controller.messenger = messenger
                        let currentNavController = tabBarController!.selectedViewController as? UINavigationController
                        currentNavController!.pushViewController(controller, animated: true)
                    }
                } else {
                    accountsProvider.fetchBizAccountIntoCache(businessId: notification.receiverId).then { (check) in
                        if check {
                            guard let business = businessAccount else { return }
                            if business.isBanned {
                                alertHelper.showAlert(title: "Notice😈", alert: "Your store account has been banned!🧐\nPlease contact our support info@randevoo.app", controller: tabBarController!)
                            } else {
                                deviceProvider.validateDeviceToken(accountId: business.id)
                                switchProvider.startSwitchAccount(mainTabBarController: tabBarController!, accountId: business.id, isPersonal: false)
                                messagesProvider.fetchMessenger(messengerId: notification.messengerId).then { (messenger) in
                                    print("Checking Business", String(business.id))
                                    print("Check current", currentAccountId)
                                    let controller = MessageController()
                                    controller.messenger = messenger
                                    let currentNavController = tabBarController!.selectedViewController as? UINavigationController
                                    currentNavController!.pushViewController(controller, animated: true)
                                }
                            }
                        }
                    }
                }

            }
        }
        
        // tell the app that we have finished processing the user’s action / response
        completionHandler()
    }
    
    private func switchAccounts(accountId: String) {
        
    }
    
}
