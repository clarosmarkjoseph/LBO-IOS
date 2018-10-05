//
//  MainMenuController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 5/21/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import SQLite
import Alamofire
import Kingfisher
import CoreLocation

class MainMenuController: UIViewController,UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
 
    @IBOutlet weak var pageControl_carousel: UIPageControl!
    @IBOutlet weak var scrollview_carousel: UIScrollView!
    @IBOutlet weak var collectionViewButton: UICollectionView!
    
    let dbclass             = DatabaseHelper()
    let utilities           = Utilities()
    var SERVER_URL          = ""
    let device              = "IOS"
    var devicetype          = UIDevice.current.modelName
    let dialogUtils         = DialogUtility()
    var structArrayBanner   = [ArrayBanner]()
    let arrBtnImage         = ["a_services","a_giftbox","a_location","a_queuing","a_faq"]
    let arrBtnLabel         = ["Services","E-Gift","Branches","Queuing","FAQ's"]
    var ifLoaded            = false
    var timerRotation       = Timer()
    var token               = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        ifLoaded = true
        devicetype                          = devicetype.replacingOccurrences(of: " ", with: "%20")
        collectionViewButton?.delegate      = self
        collectionViewButton?.dataSource    = self
        scrollview_carousel?.delegate       = self
        let retrieve_ip_address             = dbclass.returnIp()
        if(retrieve_ip_address == ""){
            dbclass.deleteIPAddress()
            dbclass.insertIPAddress(url: "https://lbo.lay-bare.com")
            SERVER_URL =  "https://lbo.lay-bare.com"
        }
        else{
            SERVER_URL =  self.dbclass.returnIp()
        }
        token          = utilities.getUserToken()
        self.setTabBarSettings(isEnabled: false)
        getFirstLoad()
        let notification_type = GlobalVariables.sharedInstance.getNotificationType()
        print(notification_type)
        if(notification_type == "chat"){
            let storyBoard = UIStoryboard(name:"ChatStoryboard",bundle:nil)
            let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "ChatInboxController") as! ChatInboxController
            self.navigationController?.pushViewController(appointmentVC, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
        else if(notification_type == "promotion"){
            let storyBoard = UIStoryboard(name:"OtherStoryboard",bundle:nil)
            let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "PromotionController") as! PromotionController
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(appointmentVC, animated: true)
        }
        else if(notification_type == "appointment"){
            let storyBoard      = UIStoryboard(name:"AppointmentStoryboard",bundle:nil)
            let appointmentVC   = storyBoard.instantiateViewController(withIdentifier: "AppointmentTab") as! AppointmentTab
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(appointmentVC, animated: true)
        }
        else if(notification_type == "PLC"){
            let storyBoard = UIStoryboard(name:"PremiereStoryboard",bundle:nil)
            let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "PremiereLoyaltyClientController") as! PremiereLoyaltyClientController
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(appointmentVC, animated: true)
        }
        else if(notification_type == "campaign_manager"){
            let storyBoard = UIStoryboard(name:"OtherStoryboard",bundle:nil)
            let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "NotificationController") as! NotificationController
            self.navigationController?.pushViewController(appointmentVC, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        timerRotation.invalidate()
    }
    override func viewDidAppear(_ animated: Bool) {
        if structArrayBanner.count > 0{
            scheduleBannerRotation()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
       
    }
    
    func setTabBarSettings(isEnabled:Bool){
        let tabBarControllerItems = self.tabBarController?.tabBar.items
        if let tabArray =  tabBarControllerItems {
            let tabBarItem1 = tabArray[0]
            let tabBarItem2 = tabArray[1]
            tabBarItem1.isEnabled = isEnabled
            tabBarItem2.isEnabled = isEnabled
            if(utilities.getUserID() > 0){
                let tabBarItem3 = tabArray[2]
                tabBarItem3.isEnabled = isEnabled
            }
        }
    }
    
    func scheduleBannerRotation(){
        timerRotation    = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.rotateBanner), userInfo: nil, repeats: true)
    }
    
    @objc func rotateBanner(){
        
        let screenWidth             = CGFloat(CGFloat(view.frame.width))
        let totalOffset             = CGFloat(view.frame.width) * CGFloat(structArrayBanner.count)
        let currentScrollPosition   = scrollview_carousel.contentOffset.x
        var totalWidth              = screenWidth + currentScrollPosition
        if (totalWidth >= totalOffset){
            totalWidth      = screenWidth + 0
        }
        let sizeScrollPoint         = CGPoint(x: totalWidth, y: 0)
        scrollview_carousel.setContentOffset(sizeScrollPoint, animated: true)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl_carousel.currentPage = Int(scrollview_carousel.contentOffset.x / CGFloat(view.frame.width))
    }
    
    //button navigation for UICollectionViewDataSource protocol
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return arrBtnImage.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionViewButton.dequeueReusableCell(withReuseIdentifier: "menuButtonCell", for: indexPath) as! MenuButtonCollectionViewCell
        cell.imgButtonCell.image = UIImage(named:arrBtnImage[indexPath.row] )
        cell.lblButtonCell.text  = arrBtnLabel[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigateToNextPage(position:indexPath.row)
    }
    
    func navigateToNextPage(position:Int){
        if(position == 0){
            let storyBoard = UIStoryboard(name:"ServicesStoryboard",bundle:nil)
            let serviceVC  = storyBoard.instantiateViewController(withIdentifier: "ServiceProductController") as! ServiceProductController
            self.navigationController?.pushViewController(serviceVC, animated: true)
        }
        if(position == 1){
            let giftUrl = "https://giftaway.ph/laybare?"
            let newurl = URL(string: giftUrl)
            UIApplication.shared.openURL(newurl!)
        }
        if(position == 2){
            redirectToLocationMap()
        }
        if(position == 3){
            loadQueuing()
        }
        if(position == 4){
            let storyBoard = UIStoryboard(name:"OtherStoryboard",bundle:nil)
            let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "FAQController") as! FAQController
            self.navigationController?.pushViewController(appointmentVC, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    func loadQueuing(){
        self.tabBarController?.tabBar.isHidden = true
        let storyboard      = UIStoryboard(name:"BranchLocationStoryboard", bundle:Bundle.main)
        var viewController  = storyboard.instantiateViewController(withIdentifier: "BranchScheduleController") as! BranchScheduleController
        viewController.isMainView   = true
        viewController.parentView   = nil
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func getFirstLoad(){
        
        self.dialogUtils.showActivityIndicator(self.view)
        var deviceUniqueID = "";
        let deviceToken    = dbclass.returnDeviceToken()
        
        print("TOKEN: \(token)")
        
        guard var appVersion = try Bundle.main.infoDictionary?["CFBundleShortVersionString"] else { return }
        if let getDeviceID =  UIDevice.current.identifierForVendor?.uuidString{
            deviceUniqueID = getDeviceID
        }
        else{
            deviceUniqueID = "N/A"
        }
        
        var myUrlString = SERVER_URL+"/api/mobile/getAppVersion/\(appVersion)/\(device)/\(devicetype)/\(deviceUniqueID)?token=\(token)";
        // Alamofire 4
        let requestParams: Parameters = ["":""]
        Alamofire.request(myUrlString, method: .get, parameters: requestParams)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
                        self.dialogUtils.hideActivityIndicator(self.view)
                        self.loadMainMenu()
                        return
                    }
                    let responseError    = response.error?.localizedDescription
                    if(statusCode == 200 || statusCode == 201){
                        if response.result.value != nil{
                            let dataResponse              = response.data
                            let objectResponse            = try JSONDecoder().decode(AppFirstLoadVersion.self, from: dataResponse!)
                            let ifUpdated:Bool            = objectResponse.ifUpdated!
                            let isValidToken:Bool         = objectResponse.isValidToken!
                            
                            if(ifUpdated == false){
                                self.showAppUpdate()
                            }
                            else{
                                if(isValidToken == false){
                                    if(self.utilities.getUserID() > 0){
                                        self.utilities.deleteAllData()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "MenuTabBarController") as! MenuTabBarController
                                            UIApplication.shared.keyWindow?.rootViewController = viewController
                                        }
                                    }
                                    else{
                                         self.loadMainMenu()
                                    }
                                }
                                else{
                                    let objectProfileAccount    = objectResponse.arrayProfile
                                    let encodedObjectProfile    = try JSONEncoder().encode(objectProfileAccount)
                                    let resultObjectString      = String(data: encodedObjectProfile, encoding: .utf8)!
                                    let date_updated            = self.utilities.getCurrentDateTime(ifDateOrTime: "datetime")
                                    if(self.dbclass.countUserAccount() > 0){
                                        let user_id     = objectProfileAccount?.id
                                        let user_name   = objectProfileAccount?.username
                                        self.dbclass.updateUserProfile(id: user_id!, name: user_name!, token: self.token, object_data: resultObjectString, date_updated: date_updated)
                                    }
                                    self.loadMainMenu()
                                    self.getNotifications()
                                    self.loadChatDetails()
                                }
                            }
                        }
                        return
                        
                    }
                    else if(statusCode == 401){
                        self.logoutUser()
                    }
                    else{
                        print("Error else : \(String(describing: responseError))")
                        //alert error
                        self.loadMainMenu()
                    }
                }
                catch{
                    print("Error: \(error)")
                    self.loadMainMenu()
                }
        }
    }
    
    func logoutUser(){
        
        var objectDictionary        = Dictionary<String,Any>()
        objectDictionary["user_id"] = utilities.getUserID()
        let requestParams:Parameters = ["user_id" : utilities.getUserID()]
        let token     = utilities.getUserToken()
        let stringURL = "\(SERVER_URL)/api/user/destroyToken?token=\(token)"
        let url = URL(string: stringURL)
        NetworkAPI.sharedInstance.logoutUser(url: url!, requestParams: requestParams) { (result, statusCode) in
            self.utilities.deleteAllData()
            self.loadMainMenu()
        }
    }
    
    func loadMainMenu(){
        
        let local_version_carousel      = utilities.getCarouselVersion()
        let local_version_commercial    = utilities.getCommercialVersion()
        let local_version_service       = utilities.getServiceVersion()
        let local_version_package       = utilities.getPackageVersion()
        let local_version_product       = utilities.getProductVersion()
        let local_version_branch        = utilities.getBranchVersion()
        
         // Alamofire 4
        var myUrlString = SERVER_URL+"/api/mobile/getFirstLoadDetails/\(local_version_carousel)/\(local_version_commercial)/\(local_version_service)/\(local_version_package)/\(local_version_product)/\(local_version_branch)";
        let requestParams: Parameters = ["":""]
        
        Alamofire.request(myUrlString, method: .get, parameters: requestParams)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
                        self.dialogUtils.hideActivityIndicator(self.view)
                        self.initiateBanner()
                        return
                    }
                    let responseError    = response.error?.localizedDescription
                    if(statusCode == 200){
                       
                        if let responseJSON = response.data { // deserialized already
                            do {
                                // Decode data to object
                                var version_banner      = 0.0
                                var version_branches    = 0.0
                                var version_commercial  = 0.0
                                var version_services    = 0.0
                                var version_packages    = 0.0
                                var version_products    = 0.0
                                
                                let jsonDecoder     = JSONDecoder()
                                let responseDecoded = try jsonDecoder.decode(MainMenuResponse.self, from: responseJSON)
                                
                                if let versions = responseDecoded.versions {
                                    
                                    version_banner      = versions.version_banner!
                                    version_branches    = versions.version_branches!
                                    version_commercial  = versions.version_commercial!
                                    version_services    = versions.version_services!
                                    version_packages    = versions.version_packages!
                                    version_products    = versions.version_products!
                        
                                    if let arrayCarousel = responseDecoded.arrayBanner{
                                        if(version_banner > local_version_carousel ){
                                            let encoded             = try JSONEncoder().encode(arrayCarousel)
                                            let stringJSONBanner    = String(decoding: encoded, as: UTF8.self)
                                            self.dbclass.deleteCarousel()
                                            self.dbclass.insertCarousel(version_no: local_version_carousel,arrayCarousel: stringJSONBanner)
                                        }
                                    }
                                    
                                    if let arrayServices       = responseDecoded.arrayServices{
                                        if(version_services > local_version_service){
                                            let encoded             = try JSONEncoder().encode(arrayServices)
                                            let stringJSONService    = String(decoding: encoded, as: UTF8.self)
                                            self.dbclass.deleteServices()
                                            self.dbclass.insertServices(insert_version: local_version_service, insert_array: stringJSONService)
                                        }
                                    }
                                    if let arrayPackage        = responseDecoded.arrayPackage{
                                        if(version_packages > local_version_package){
                                            let encoded              = try JSONEncoder().encode(arrayPackage)
                                            let stringJSONPackage    = String(decoding: encoded, as: UTF8.self)
                                            self.dbclass.deletePackages()
                                            self.dbclass.insertPackages(insert_version: local_version_package, insert_array: stringJSONPackage)
                                        }
                                    }
                                    if let arrayProducts       = responseDecoded.arrayProducts{
                                        if(version_products > local_version_product){
                                            let encoded              = try JSONEncoder().encode(arrayProducts)
                                            let stringJSONProduct    = String(decoding: encoded, as: UTF8.self)
                                            self.dbclass.deleteProducts()
                                            self.dbclass.insertProducts(insert_version: local_version_product, insert_array: stringJSONProduct)
                                        }
                                    }
                                    if let arrayBranch         = responseDecoded.arrayBranch{
                                        if(version_branches > local_version_branch){
                                            let encoded              = try JSONEncoder().encode(arrayBranch)
                                            let stringJSONBranch     = String(decoding: encoded, as: UTF8.self)
                                            self.dbclass.deleteBranches()
                                            self.dbclass.insertBranches(insert_version: local_version_branch, insert_array:stringJSONBranch)
                                        }
                                    }
                                    if let arrayCommercial     = responseDecoded.arrayCommercial{
                                        if(version_commercial > local_version_commercial ){
                                            let encoded              = try JSONEncoder().encode(arrayCommercial)
                                            let stringJSONCommercial = String(decoding: encoded, as: UTF8.self)
                                            self.dbclass.deleteCommercial()
                                            self.dbclass.insertCommercial(insert_version: local_version_commercial, insert_array: stringJSONCommercial)
                                        }
                                    }
                                }
                            }
                            catch {
                                print(error)
                            }
                            self.dialogUtils.hideActivityIndicator(self.view)
                            self.initiateBanner()
                        }
                        
                }
                if(responseError != nil){
                    print("Error response: \(responseError)")
                    self.dialogUtils.hideActivityIndicator(self.view)
                    self.initiateBanner()
                }
            }
            catch{
                print("Error1: \(response.error)")
                self.dialogUtils.hideActivityIndicator(self.view)
                self.initiateBanner()
            }
        }
    }
    
    
    func getNotifications(){
        
        let last_notif_id   = dbclass.getLastNotificationID()
        let myUrlString     = SERVER_URL+"/api/mobile/getNotifications/\(last_notif_id)?token=\(token)";
        print(myUrlString)
        // Alamofire 4
        Alamofire.request(myUrlString, method: .get)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
                        self.dialogUtils.hideActivityIndicator(self.view)
                        return
                    }
                    let responseError    = response.error?.localizedDescription
                    if(statusCode == 200 || statusCode == 201){
                        if response.result.value != nil{
                            let dataResponse             = response.data
                            let arrayResponse            = try JSONDecoder().decode([UserNotification].self, from: dataResponse!)
                            for rows in arrayResponse{
                                let id                  = rows.id!
                                let dateTime            = rows.created_at!
                                let notification_type   = rows.notification_type!
                                let isRead              = rows.isRead!
                                let title               = rows.notification_data?.title!
                                let body                = rows.notification_data?.body!
                                let unique_id           = rows.notification_data?.unique_id ?? 0
                                self.dbclass.insertNotification(id: id, datetime: dateTime, type: notification_type, is_seen: isRead, title: title!, body: body!, unique_id: unique_id)
                            }
                        }
                    }
                    else if(statusCode == 401){
                        self.logoutUser()
                    }
                    else{
                        print("Error else : \(String(describing: responseError))")
                    }
                }
                catch{
                    print("Error: \(error)")
                }
        }
    }
    
    //chat retrieval
    func loadChatDetails(){
        ChatDatasource.sharedChatInstance.loadAllChatMessages { (arrayThread,statusCode) in
            if statusCode == 200 || statusCode == 201{
                let array = arrayThread
                for rows in array{
                    self.saveMessages(jsonResult: rows)
                }
            }
        }
    }
    func saveMessages(jsonResult:ArrayChatThread){
        do{
            let chatMessage             = jsonResult.messages!
            let id                      = jsonResult.id!
            let name                    = jsonResult.thread_name ?? "N/A"
            let dateTime                = jsonResult.updated_at ?? "0000-00-00 00:00:00"
            let created_by_id           = jsonResult.created_by_id!
            let user_image              = jsonResult.user_image!
            let participant_ids         = jsonResult.participant_ids!
            let arrayParticipantData    = try JSONEncoder().encode(participant_ids)
            let jsonString              = utilities.convertDataToJSONString(data: arrayParticipantData)
            let clientID                = utilities.getUserID()
            
            dbclass.insertOrUpdateThread(id: id, name: name, dateTime: dateTime, creator_id: created_by_id, chat_participants_id: jsonString,user_image: user_image)
            
            var indexChat = 0
            for rowChat in chatMessage{
                let chat_id         = rowChat.id!
                let sender_id       = rowChat.sender_id!
                let recipient_id    = rowChat.recipient_id!
                let thread_id       = rowChat.message_thread_id!
                let title           = rowChat.title ?? ""
                let body            = rowChat.body ?? ""
                let message_data    = rowChat.message_data ?? "{}"
                let dateTime        = rowChat.created_at!
                let read_at = rowChat.read_at ?? ""
                
                var isRead          = 0
                dbclass.insertOrUpdateChat(chatID: chat_id, chatSenderID: sender_id, chatReceiverID: recipient_id, chatThreadID: thread_id, chatTitle: title, chatBody:body, chatMessageData: message_data, dateTime: dateTime, chatIsRead: read_at, chatStatus: "sent")
                if((read_at == "0000-00-00" || read_at == "null" || read_at == "") && recipient_id == clientID){
                    isRead = 0
                }
                else{
                    isRead = 1
                }
                dbclass.updateThreadTime(threadID: thread_id,datetime: dateTime,isRead:isRead)
                indexChat += 1
            }
        }
        catch{
            print("ERROR parsing chat: \(error)")
        }
    }
    
    //new app updates
    func showAppUpdate(){
        
        //alert box
        self.dialogUtils.hideActivityIndicator(self.view)
        let alertView = UIAlertController(title: "New App version!", message: "New version is detected. Please update your app for better use", preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Update App", style: .default) { (action) in
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id1113862522"),
                UIApplication.shared.canOpenURL(url)
            {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        alertView.addAction(confirm)
        present(alertView,animated: true,completion: nil)
    }
    
    
    func showDialog(title:String,message:String){
        //alert box
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            
        }
        alertView.addAction(confirm)
        present(alertView,animated: true,completion: nil)
    }
    
    
    
    func showRetry(){
        //alert box
        let alertView = UIAlertController(title: "Connection Error!", message: "Sorry, your connection seems slow. Would you like to retry?", preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Retry.", style: .default) { (action) in
            //reload Data
            self.getFirstLoad()
        }
        alertView.addAction(confirm)
        present(alertView,animated: true,completion: nil)
    }
    
    
    
    func initiateBanner()  {
        let carousel_tbl = dbclass.carousel_tbl
        do {
            if let queryBanner = try dbclass.db?.pluck(carousel_tbl){
                let arrayBannerData     = queryBanner[dbclass.carousel_array]
                let jsonData            = arrayBannerData.data(using: .utf8)
                structArrayBanner       = try JSONDecoder().decode([ArrayBanner].self, from: jsonData!)
                var x = 0
                pageControl_carousel.numberOfPages = Int(structArrayBanner.count)
                
                for row in structArrayBanner{
                    
                    let imgSrc              = row.image!
                    let url                 = URL(string:SERVER_URL+"/images/ads/\(imgSrc)")
                    let imageView           = UIImageView()
                    imageView.kf.setImage(with: url)
                    imageView.contentMode   = .scaleToFill
                    let xPosition           = self.view.frame.width * CGFloat(x)
                    imageView.frame         = CGRect(x: xPosition, y: 0, width: self.scrollview_carousel.frame.width, height: self.scrollview_carousel.frame.height)
                    scrollview_carousel.contentSize.width = scrollview_carousel.frame.width * CGFloat(x + 1)
                    scrollview_carousel.addSubview(imageView)
                    x+=1
                }
                self.setTabBarSettings(isEnabled: true)
                self.scheduleBannerRotation()
            }
            else{
                showRetry()
            }
        }
        catch {
            print(error)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    func redirectToLocationMap(){
        let storyBoard      = UIStoryboard(name:"BranchLocationStoryboard",bundle:nil)
        let viewController  = storyBoard.instantiateViewController(withIdentifier: "BranchLocationController") as! BranchLocationController
        self.navigationController?.pushViewController(viewController, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
   
    
    
    
}
