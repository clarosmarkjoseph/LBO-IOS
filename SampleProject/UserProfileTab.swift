//
//  ProfileTab.swift
//  SampleProject
//
//  Created by Paolo Hilario on 5/21/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class UserProfileTab: UITableViewController{
    
    @IBOutlet weak var tblProfile: UITableView!
    @IBOutlet var lblCountNotification: UILabel!
    @IBOutlet var lblCountMessage: UILabel!
    
    
    let diagUtil = DialogUtility()
    var client_id  = 0
    let dbclass    = DatabaseHelper()
    let utilities  = Utilities()
    var SERVER_URL = "";
    var isLoaded   = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countMessage()
        countNotification()
        isLoaded = true
    }
    
    func countMessage(){
        let countMessage = dbclass.countMessage()
        if(countMessage > 0){
            lblCountMessage.isHidden = false
            lblCountMessage.text = "\(countMessage)"
        }
        else{
            lblCountMessage.isHidden = true
        }
    }
    
    func countNotification(){
        let countNotification = dbclass.countNotifications()
        if(countNotification > 0){
            lblCountNotification.isHidden = false
            lblCountNotification.text = "\(countNotification)"
        }
        else{
            lblCountNotification.isHidden = true
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        SERVER_URL  = dbclass.returnIp()
        tblProfile.alwaysBounceVertical = false
        client_id   = utilities.getUserID()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
  
        if(client_id <= 0){
            if indexPath.row == 11 {
                return 350
            }
            else{
                return 0.0
            }
        }
        else{
            if indexPath.row == 0 {
                return 0.0
            }
            if indexPath.row == 9{
                return 0.0
            }
            if indexPath.row == 11 {
                return 0.0
            }
            else{
                return 60
            }
        }
    }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let position = indexPath.row
        if let index = self.tblProfile.indexPathForSelectedRow{
            self.tblProfile.deselectRow(at: index, animated: true)
        }
        navigateToNextPage(position:position)
    }
   
    func navigateToNextPage(position:Int){

        if(position == 1){
            let storyBoard = UIStoryboard(name:"TransactionStoryboard",bundle:nil)
            let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "TransactionController") as! TransactionController
            self.navigationController?.pushViewController(appointmentVC, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
        if(position == 2){
            let storyBoard = UIStoryboard(name:"AppointmentStoryboard",bundle:nil)
            let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "AppointmentTab") as! AppointmentTab
            self.navigationController?.pushViewController(appointmentVC, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
        if(position == 3){
            let storyBoard = UIStoryboard(name:"PremiereStoryboard",bundle:nil)
            let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "PremiereLoyaltyClientController") as! PremiereLoyaltyClientController
            self.navigationController?.pushViewController(appointmentVC, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
        if(position == 4){
            let storyBoard = UIStoryboard(name:"OtherStoryboard",bundle:nil)
            let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "PromotionController") as! PromotionController
            self.navigationController?.pushViewController(appointmentVC, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
        if(position == 5){
            let storyBoard = UIStoryboard(name:"OtherStoryboard",bundle:nil)
            let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "NotificationController") as! NotificationController
            self.navigationController?.pushViewController(appointmentVC, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
        if(position == 6){
            let storyBoard = UIStoryboard(name:"ChatStoryboard",bundle:nil)
            let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "ChatInboxController") as! ChatInboxController
            self.navigationController?.pushViewController(appointmentVC, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
        if(position == 7){
            showContactUs()
        }
        if(position == 8){
            utilities.openFacebookPage()
        }
        if(position == 9){
            
        }
        if(position == 10){
            self.logoutConfirmation()
        }
    }
    
    func logoutConfirmation(){
        //alert box
        let alertView = UIAlertController(title: "Log out User", message: "Are you sure you want to logout your account?", preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            self.diagUtil.showActivityIndicator(self.view)
            let token                    = self.utilities.getUserToken()
            let stringURL                = "\(self.SERVER_URL)/api/user/destroyToken?token=\(token)"
            let url                      = URL(string: stringURL)
            var objectDictionary         = Dictionary<String,Any>()
            objectDictionary["user_id"]  =  self.utilities.getUserID()
            let requestParams:Parameters = ["user_id" :  self.utilities.getUserID()]
            
            NetworkAPI.sharedInstance.logoutUser(url: url!, requestParams: requestParams) { (result, statusCode) in
                print("Result Code: \(result) - \(statusCode)")
                self.utilities.deleteAllData()
                self.diagUtil.hideActivityIndicator(self.view)
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "LoginStoryboard", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
                viewController.isLoggedOut    = true
                viewController.sessionExpired = false
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertView.addAction(confirm)
        alertView.addAction(cancel)
        self.present(alertView,animated: true,completion: nil)
    }
    
    
    func showContactUs() {
        
        let alertView = UIAlertController(title: "Contact Us!", message: "Please select on how you want to connect with us.", preferredStyle: .actionSheet)
        
        let btnEmail = UIAlertAction(title: "Via Email", style: .default) { (action) in
            self.showEmailSelection()
        }
        let btnChat = UIAlertAction(title: "Live Chat", style: .default) { (action) in
            self.showChat()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertView.addAction(btnEmail)
        alertView.addAction(btnChat)
        alertView.addAction(cancel)
        present(alertView,animated: true,completion: nil)
    }
    
    func showChat(){
        
        self.diagUtil.showActivityIndicator(self.view)
        let SERVER_URL      = dbclass.returnIp()
        let token           = utilities.getUserToken()
        let url     = "\(SERVER_URL)/api/mobile/contactCustomerService?token=\(token)"
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
                        self.diagUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                        return
                    }
                    if response.data != nil{
                        if(statusCode == 200 || statusCode == 201){
                            let decodedResult = try JSONDecoder().decode(RequestChatThread.self, from: response.data!)
                            self.navigateChatRoom(requestResult: decodedResult)
                        }
                        else if (statusCode == 401){
                            self.diagUtil.hideActivityIndicator(self.view)
                            self.utilities.deleteAllData()
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "LoginStoryboard", bundle: nil)
                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
                            viewController.isLoggedOut      = true
                            viewController.sessionExpired   = true
                            UIApplication.shared.keyWindow?.rootViewController = viewController
                        }
                        else{
                            self.diagUtil.hideActivityIndicator(self.view)
                            let responseValue = response.result.value
                            if responseValue != nil{
                                let arrayError = self.utilities.handleHttpResponseError(objectResponseError: responseValue as! Dictionary<String, Any> ,statusCode:statusCode)
                                self.showDialog(title:arrayError[0], message: arrayError[1])
                            }
                            else{
                                self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                            }
                        }
                    }
                    else{
                        self.diagUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                    }
                }
                catch{
                    print("ERROR schedule: \(error)")
                    self.diagUtil.hideActivityIndicator(self.view)
                    self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                }
        }

    }
    
    func navigateChatRoom(requestResult:RequestChatThread){
        self.tabBarController?.tabBar.isHidden = true
        let storyBoard          = UIStoryboard(name:"ChatStoryboard",bundle:nil)
        let chatVC              = storyBoard.instantiateViewController(withIdentifier: "ChatMessageController") as! ChatMessageController
        chatVC.thread_id        = requestResult.thread_id!
        chatVC.thread_name      = requestResult.thread_details!.thread_name!
        chatVC.recipient_id     = requestResult.recipient_id!
        chatVC.isCameFromInbox  = false
        self.navigationController?.pushViewController(chatVC, animated: true)
        self.diagUtil.hideActivityIndicator(self.view)
    }
    
    
    func showDialog(title:String,message:String){
        //alert box
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            if(self.diagUtil.activityIndicator.isHidden == false){
                self.diagUtil.hideActivityIndicator(self.view)
            }
        }
        alertView.addAction(confirm)
        self.present(alertView,animated: true,completion: nil)
    }
    
    
   
    
    func showEmailSelection(){
        
        var arraySelectionHeader    = ["General Concern","Marketing Concern","Franchising Concern","Customer Service Concern",""]
        
        let arraySelectionEmail     = ["info@lay-bare.com","marketing@lay-bare.com","franchising@lay-bare.com","customercare@lay-bare.com"]
        
        let alertView = UIAlertController(title: "Email US", message: "Please identify your concern.", preferredStyle: .actionSheet)
        
        var index = 0
        for rows in arraySelectionEmail{
            let title = arraySelectionHeader[index]
            let btnEmail = UIAlertAction(title: title, style: .default) { (action) in
                let email = rows
                if let url = URL(string: "mailto:\(email)") {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url)
                    }
                    else {
                        UIApplication.shared.openURL(url)
                    }
                    print("Email: \(email)")
                }
                else{
                    print("Mail Error")
                }
            }
            alertView.addAction(btnEmail)
            index+=1
        }
      
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertView.addAction(cancel)
        present(alertView,animated: true,completion: nil)
    }
    
    
    @IBAction func btnLogin(_ sender: Any) {
        if let viewController = UIStoryboard(name: "LoginStoryboard", bundle: nil).instantiateViewController(withIdentifier: "LoginController") as? LoginController {
            if let navigator = navigationController {
                viewController.sessionExpired = false
                navigator.present(viewController, animated: true)
            }
        }
    }
    
    @IBAction func btnRegister(_ sender: Any) {
        if let viewController = UIStoryboard(name: "LoginStoryboard", bundle: nil).instantiateViewController(withIdentifier: "SignupController") as? SignupController {
            if let navigator = navigationController {
                navigator.present(viewController, animated: true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(isLoaded == true){
            countMessage()
            countNotification()
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
