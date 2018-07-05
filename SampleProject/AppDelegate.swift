//
//  AppDelegate.swift
//  SampleProject
//
//  Created by itadmin on 09/05/2017.
//  Copyright © 2017 itadmin. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import UserNotifications
import UserNotificationsUI
import Alamofire
import SQLite
//import Firebase
//import FirebaseMessaging
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate{
    
    var alamoFireManager : SessionManager?
    var window: UIWindow?
    
    var clientID = ""
    var countUser = 0
    
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
   
    
    //variable of locations url
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:
        [NSObject: AnyObject]?) -> Bool {
    
        FBSDKApplicationDelegate .sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
//        UIApplication.shared.isStatusBarHidden = false
//        UIApplication.shared.statusBarStyle = .lightContent
//        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
//        statusBar.backgroundColor = #colorLiteral(red: 0.5725490196, green: 0.7803921569, blue: 0.2509803922, alpha: 1)
        
//        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.makeKeyAndVisible()
//        let mainVC = MenuTabBarController()
//        window?.rootViewController = mainVC
        
        return true
    }
    

    func application(_ app: UIApplication, open url: URL, options:[UIApplicationOpenURLOptionsKey:Any] = [:]) -> Bool{
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url,sourceApplication: options [UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        return handled
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
//        print("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        doBackgroundTask();
        print("applicationDidEnterBackground")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    var backgroundUpdateTask : UIBackgroundTaskIdentifier!
    
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

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("applicationWillEnterForeground FOREGROUND")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
//        print("applicationDidBecomeActive ACTIVE")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
      
        // Call the 'activate' method to log an app event for use
        // in analytics and advertising reporting.
        //AppEventsLogger.activate(application)
        
    }
    
    
    //============================ Comment Azure ===============================\\
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        
        print("Registering for remote notification with device token");
        var token:String = String(describing: deviceToken)
        var hub : SBNotificationHub = SBNotificationHub(connectionString: "Endpoint=sb://test-laybare-hub.servicebus.windows.net/;SharedAccessKeyName=DefaultFullSharedAccessSignature;SharedAccessKey=wXcb4hwKEpoDIYVUGn0ndM3MbtVRyIGnAGyY5igqVmo=", notificationHubPath: "Test-Laybare-Hub")
        
//        countUser = con.returnCountUser()
//        if(countUser > 0){
//             clientID = con.returnUser()
//        }
//        else{
//             clientID = ""
//        }
//        print("Client ID : : \(clientID)")
        
        var myLeague: [AnyObject] = [AnyObject]()
        myLeague.insert(clientID as AnyObject, at: 0)
        let tagSet: NSSet = NSSet(array: myLeague)
    
        hub.registerNative(withDeviceToken: deviceToken, tags: tagSet as! Set<NSObject> ) { (error) -> Void in
            if (error != nil){
                print("Error registering for notifications: %@", error);
            }else{
                print("Successfully registered to remote notifications \(tagSet)");
                //                self.generateNotification()
                let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
                print(token.uppercased())
            }
        }
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        var isCalled = ""
//        var isType   = ""
//        var appointment_id = ""
//        var pageUrl  = ""
//        var titleDesc = ""
//
//        print(userInfo)
//
//        // Capture payload here something like:
//        // Do something for every state
//        if (application.applicationState == UIApplicationState.active){
//            print("Active")
//            // App is foreground and notification is recieved,
//            // Show a alert.
//        }
//        else if( application.applicationState == UIApplicationState.background){
//            print("Background")
//            // App is in background and notification is received,
//            // You can fetch required data here don't do anything with UI.
//        }
//        else if( application.applicationState == UIApplicationState.inactive){
//            print("Inactive")
//
//            if let data = userInfo["data"] as? NSDictionary {
//                if let appointment_id1 = data["appointment_id"] as? String {
//                    appointment_id = appointment_id1
//                    print(isType)
//                }
//                if let branchID1 = data["branch_id"] as? String {
//                    branchID = branchID1
//                    print(branchID)
//                }
//            }
//            if let aps = userInfo["aps"] as? NSDictionary {
//                if let alert = aps["alert"] as? NSDictionary {
//                    if let titleDesc1 = alert["title"] as? String {
//                        titleDesc = titleDesc1
//                        print("Title: \(titleDesc)")
//                    }
//                }
//            }
//
//            if(titleDesc == "Appointment is expired" || titleDesc == "Appointment is cancelled"){
//                pageUrl = "appointmentbranches.php?t=3"
//            }
//            else if(titleDesc == "Appointment Booking" || titleDesc == "Be ready"){
//                pageUrl = "queuing.php?id=" +  branchID
//            }
//            else{
//                pageUrl = "promotions.php"
//            }

            // App came in foreground by used clicking on notification,
            // Use userinfo for redirecting to specific view controller.
//            let mainStoryboard: UIStoryboard = UIStoryboard(name: "MainMenu", bundle: nil)
//            let vc  = mainStoryboard.instantiateViewController(withIdentifier:  "mainmenu") as! MainMenuController
//            let pass_url = pageUrl
//            vc.stringUrl = pass_url
//            let navigationController = UINavigationController(rootViewController: vc)
//            self.window?.rootViewController = navigationController
//            self.window?.makeKeyAndVisible()
        }
//        completionHandler(.noData)
    }
  
    
    public func application(_ application: UIApplication, didReceive notification: UILocalNotification){
        
        var titleDesc = notification.alertTitle
        var titleDescUrl = ""
        print("didReceive na")
//        if(titleDesc == "Appointment is expired" || titleDesc == "Appointment is cancelled"){
//            titleDescUrl = "appointmentbranches.php?t=3"
//        }
//        else if(titleDesc == "Appointment Booking" || titleDesc == "Be ready"){
//            titleDescUrl = "queuing.php?id=" +  branchID
//        }
//        else{
//            titleDescUrl = "promotions.php"
//        }
//        print(notification.index(ofAccessibilityElement: 0))
//        if (application.applicationState == UIApplicationState.active){
//            print("Active")
//            // App is foreground and notification is recieved,
//            // Show a alert.
//        }
//        else if( application.applicationState == UIApplicationState.background){
//            print("Background")
//            // App is in background and notification is received,
//            // You can fetch required data here don't do anything with UI.
//        }
//        else if( application.applicationState == UIApplicationState.inactive){
//            print("Inactive")
//            // App came in foreground by used clicking on notification,
//            // Use userinfo for redirecting to specific view controller.
////            let mainStoryboard: UIStoryboard = UIStoryboard(name: "MainMenu", bundle: nil)
////            let vc  = mainStoryboard.instantiateViewController(withIdentifier:  "mainmenu") as! MainMenuController
////            let pass_url = titleDescUrl
////            vc.stringUrl = pass_url
////            let navigationController = UINavigationController(rootViewController: vc)
////            self.window?.rootViewController = navigationController
////            self.window?.makeKeyAndVisible()
//        }
    }
    
    
    public func application( application: UIApplication!, didFailToRegisterForRemoteNotificationsWithError error: NSError! ) {
        print( "Failed to register to remote notification" )
    }
    

    
//    @available(iOS 10.0, *)
//    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void){
//        print("Handle push from foreground \(notification.request.content.userInfo)")
//        
//        let dict = notification.request.content.userInfo["aps"] as! NSDictionary
//        let d: [String: Any] = dict["alert"] as! [String:Any]
//        let body:String = d["body"] as! String
//        let title:String = d["title"] as! String
//        print("Title: \(title) + body: \(body)")
//        
//    }
    
    
    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from applicationDidFinishLaunching:.
    @available(iOS 10.0, *)
//    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void){
//        print("Handle push from background or closed \(response.notification.request.content.userInfo)")
//    }
//    
    
 
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void){
        //Called when a notification is delivered to a foreground app.
        let userInfo = notification.request.content.userInfo as? NSDictionary
        print("\(userInfo)")
        
    }
  
 
 
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
 
    
    public func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Swift.Void){
        print("handleActionWithIdentifier")
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("Kuya aries  \(UIBackgroundFetchResult.newData)")
        completionHandler(UIBackgroundFetchResult.newData)
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
    }
    
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
        }
    }
    

    ///===========For local notification ready ===================//
   
    func generateNotification(isCalled:String,isType:String,appointmentID:String,pageUrl:String){
        print(isCalled)
//        if(countUser > 0){
//            clientID = con.returnUser()
//            print("Client ID: \(clientID)")
//                let urlString = URL(string:"https://system.lay-bare.com/laybare_mobile/JSONgetNotifications3.php")
//                let requestParams: Parameters = [
//                    "uid":clientID,
//                    "type": isType,
//                    "appointmentID" : appointmentID]
//                Alamofire.request(urlString!, method: .get, parameters: requestParams)
//                    .responseJSON { response in
//                    if(response.error != nil){
//                        print("ANG ERROR AY: \(response.error)")
////                        self.generateNotification(isCalled:isCalled, isType: "call")
//                    }
//                    else{
//                        let data = response.result.value
//                        print("DATA Mo to : \(data)")
//                        if let responseJSON = data! as? [String:Any]{
//                            //iterate call
//                            if(isType=="call"){
//                                if(isCalled == "yes"){
//                                    print("call na")
//                                    if let result_call = responseJSON["call"] as? [[String:Any]] {
//                                        for callRow in result_call{
//                                            if let fname = callRow["fname"] as? String{
//                                            self.fname = fname
//                                            }
//                                            if let branch = callRow["branchname"] as? String{
//                                                self.branch = branch
//                                            }
//                                            if let branch_id = callRow["branchid"] as? String{
//                                                self.branchID = branch_id
//                                            }
//                                            let content = "Hi \(self.fname), please proceed to the branch counter (\(self.branch)) and we are ready to serve you!"
//                                            var title = "Appointment Booking"
//
//                                        }
//                                    }
//                                }
//                                else{
//                                    print("no call")
//                                }
//
//                            }
//                            else if(isType == "cancelled"){
//                                print("cancelled")
//                                //iterate expired appointments AND cancelled appointments
//                                if let result_expired = responseJSON["expireNotif"] as? [[String:Any]] {
//                                    for expiredRow in result_expired{
//                                        if let expdate = expiredRow["exdate"] as? String{
//
//                                            self.expDate = expdate
//                                        }
//                                        if let expservice = expiredRow["service_name"] as? String{
//
//                                            self.expService = expservice
//                                        }
//                                        if let typeAppointment = expiredRow["type"] as? String{
//                                            self.type = typeAppointment
//                                        }
//                                        var content = ""
//                                        if(self.type == "cancelled"){
//                                            content = "Your reserved appointment (\(self.expService))  \(self.expDate) is cancelled!"
//                                        }
//                                        else{
//                                            content = "Your reserved appointment (\(self.expService)) last \(self.expDate) has expired!"
//                                        }
//                                        let title = "Appointment is " + self.type
//                                        self.showAllNotif(title: title, subtitle: "", body: content,identifier:self.expService)
//                                    }
//                                }
//
//                            }
//                            else{
//                                print("15mins")
//                                //iterate 15 mins before the actual service
//                                if let result_before = responseJSON["appointment"] as? Int {
//                                    print(result_before)
//                                    if(result_before>0){
//                                        let content = "Hi, your appointment will start after 15 minutes!"
//                                        var title = "Be ready."
//                                        self.showAllNotif(title: title, subtitle: "", body: content,identifier:"before15mins")
//                                    }
//                                }
//                            }
//
//
//                        }
//                    }
//
//                }
//        }
        
    }
    
    func showAllNotif(title:String, subtitle:String, body:String,identifier:String) {
        if #available(iOS 10.0, *) {
            let content      = UNMutableNotificationContent()
            content.title    = title
            content.subtitle = subtitle
            content.body     = body
//            content.attachments  = [attachment]
//            content.badge    = 1
            content.sound    = UNNotificationSound.default()
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval:3, repeats:false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            UNUserNotificationCenter.current().add(request) { (error: Error?) in
                if let error = error{
                    print("ERROR sa Local Notif: \(error.localizedDescription)")
                }
            }
        }else {
            // Fallback on earlier versions
            
        }
    }

    
    
    



