//
//  AppDelegate.swift
//  SampleProject
//
//  Created by itadmin on 09/05/2017.
//  Copyright © 2017 itadmin. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Alamofire
import SQLite
import GoogleMaps

import UserNotifications
import UserNotificationsUI


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate{
    
    var alamoFireManager : SessionManager?
    var window: UIWindow?
    
    var clientID = 0

    //variable of promotions
    var proContent = ""
    var proTitle   = ""
    
   //variable of called appointments 
    var fname = ""
    var lname = ""
    var branch = ""
    var date = ""
    var time = ""
    var branchID = ""
    
    //variable of expiration of appoint
    var expDate = ""
    var expService = ""
    var type = ""
    
    var dbclass         = DatabaseHelper()
    var orientationLock = UIInterfaceOrientationMask.portrait
    var backgroundUpdateTask : UIBackgroundTaskIdentifier!

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        FBSDKApplicationDelegate .sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        let APIKey = Utilities().returnGoogleAPIKey()
        GMSServices.provideAPIKey(APIKey)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        let tabBarController            = MenuTabBarController()
        tabBarController.selectedIndex  = 0
        window?.rootViewController      = tabBarController
        registerForPushNotifications(application)
        return true
    }
    
    func registerForPushNotifications(_ application: UIApplication) {
        //      iOS 10 support
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
            // iOS 9 support
        else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 8 support
        else if #available(iOS 8, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 7 support
        else {
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let hub : SBNotificationHub = SBNotificationHub(connectionString: "Endpoint=sb://laybarenamespace.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=wzShMuMA31Vfz48q7A1VHZDBhcK/WHA8qFoL0SUDgFY=", notificationHubPath: "LayBareNotificationHub")
        clientID = Utilities().getUserID()
        let token:String = String(describing: deviceToken)
        print("Device Token for APN's: \(token)")
        
        var deviceID     = ""
        if let device_id =  UIDevice.current.identifierForVendor?.uuidString{
            deviceID = device_id
        }
        else{
            deviceID = "N/A"
        }
        
        let mySet = [deviceID,"tags-campaign-manager","tags-announcement","tags-promotion"]  // Set<String>
        var arrayTag: [AnyObject] = [AnyObject]()
        for eachleague in mySet {
            arrayTag.insert(eachleague as AnyObject, at: 0)
        }
        let tagSet: NSSet = NSSet(array: arrayTag)
        hub.registerNative(withDeviceToken: deviceToken,tags:tagSet as! Set<AnyHashable> ) { (error) -> Void in
            if (error != nil){
                print("Error registering for notifications: %@", error);
            }
            else{
                print("Successfully registered to remote notifications ");
                let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
                print(token.uppercased())
                let existingToken = self.dbclass.returnDeviceToken()
                if(existingToken != ""){
                    if(existingToken != token){
                        self.dbclass.deleteDeviceToken()
                        self.dbclass.insertDeviceToken(deviceToken: token)
                    }
                }
            }
        }
    }
    
    public func application( application: UIApplication!, didFailToRegisterForRemoteNotificationsWithError error: Error!) {
        print( "Failed to register to remote notification \(error)" )
    }
    
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
            print("registered ")
        }
    }
    
    //this will be called when you have silent push: parameters:content_available:1
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("Entire MEssage: \(userInfo)")
        let state: UIApplicationState = application.applicationState
        if(state == UIApplicationState.active){
            //notify or cast observers
            print("active")
        
        }
        else if(state == UIApplicationState.background){
            print("background")
//            let objectNotif         = userInfo as! Dictionary<String,Any>
//            let notification_type   = objectNotif["notification_type"] as! String
//            GlobalVariables.sharedInstance.setNotificationType(notif: notification_type)
//            window = UIWindow(frame: UIScreen.main.bounds)
//            window?.makeKeyAndVisible()
//            let tabBarVC = MenuTabBarController()
//            tabBarVC.selectedIndex      = 0
//            window?.rootViewController  = tabBarVC
//            setNotification()
            
        }
        else if(state == UIApplicationState.inactive){
            print("inactive")
//            let objectNotif         = userInfo as! Dictionary<String,Any>
//            let notification_type   = objectNotif["notification_type"] as! String
//            GlobalVariables.sharedInstance.setNotificationType(notif: notification_type)
//            window = UIWindow(frame: UIScreen.main.bounds)
//            window?.makeKeyAndVisible()
//            let tabBarVC = MenuTabBarController()
//            tabBarVC.selectedIndex      = 0
//            window?.rootViewController  = tabBarVC
//            setNotification()
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }

    // For handling tap and user actions
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print(response.actionIdentifier)
        switch response.actionIdentifier {
        case "action1":
            print("Action First Tapped")
        case "action2":
            print("Action Second Tapped")
        default:
            print("Action Default Tapped")
            
            let userInfo            = response.notification.request.content.userInfo
            let objectNotif         = userInfo as! Dictionary<String,Any>
            let notification_type   = objectNotif["notification_type"] as! String
            GlobalVariables.sharedInstance.setNotificationType(notif: notification_type)
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.makeKeyAndVisible()
            let tabBarVC = MenuTabBarController()
            tabBarVC.selectedIndex      = 0
            window?.rootViewController  = tabBarVC
            
            break
        }
        completionHandler()
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo as? NSDictionary
        print("INFO WILL PRESENT \(userInfo)")
        completionHandler([.alert, .badge, .sound])
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        print("performFetchWithCompletionHandler  \(UIBackgroundFetchResult.newData)")
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
  
    
    func application(_ app: UIApplication, open url: URL, options:[UIApplicationOpenURLOptionsKey:Any] = [:]) -> Bool{
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url,sourceApplication: options [UIApplicationOpenURLOptionsKey.sourceApplication] as! String?, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return handled
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        doBackgroundTask();
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground FOREGROUND")
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}


extension AppDelegate{
    
    func doBackgroundTask(){
        beginBackgroundDownload()
        let queue   = DispatchQueue.global(qos: .background)
        queue.async{
            sleep(2)
            self.endBackgroundDownload()
        }
    }
    
    func beginBackgroundDownload(){
        backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(withName: "DownloadImages"){
            print("background");
            self.endBackgroundDownload()
        }
    }
    
    func endBackgroundDownload(){
        UIApplication.shared.endBackgroundTask(backgroundUpdateTask)
        backgroundUpdateTask = UIBackgroundTaskInvalid
    }
}

    
    
    



