//
//  NotificationController.swift
//  Lay Bare Waxing PH
//
//  Created by Paolo Hilario on 9/11/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import SQLite
import Alamofire

class NotificationController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet var tblNotification: UITableView!
    let dbclass             = DatabaseHelper()
    let utilities           = Utilities()
    var arrayNotifications  = [UserNotification]()
    var SERVER_URL          = ""
    var token               = ""
    let dialogUtil          = DialogUtility()
    
    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor        = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
        refresh.attributedTitle  = NSAttributedString(string: "Loading...")
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SERVER_URL  = dbclass.returnIp()
        token       = utilities.getUserToken()
        self.tblNotification.delegate           = self
        self.tblNotification.dataSource         = self
        self.tabBarController?.tabBar.isHidden  = true
        self.getOfflineNotification()
        
        refreshControl.beginRefreshing()
        self.tblNotification.isScrollEnabled         = true
        self.tblNotification.alwaysBounceVertical    = true
        self.tblNotification.addSubview(refreshControl)
        refreshControl.tag = 1
        self.handleRefresh()
        
    }
    
    //pull to refresh
    @objc func handleRefresh() {
        getNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getNotifications(){
        let last_notif_id   = dbclass.getLastNotificationID()
        let myUrlString     = SERVER_URL+"/api/mobile/getNotifications/\(last_notif_id)?token=\(token)";
        print(myUrlString)
        Alamofire.request(myUrlString, method: .get)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
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
                                let unique_id           = rows.notification_data?.unique_id!
                                
                                self.dbclass.insertNotification(id: id, datetime: dateTime, type: notification_type, is_seen: isRead, title: title!, body: body!, unique_id: unique_id!)
                                self.arrayNotifications.append(rows)
                                
                            }
                            self.sortNotification()
                        }
                    }
                    else{
                        print("Error else : \(String(describing: responseError))")
                        self.refreshControl.endRefreshing()
                    }
                }
                catch{
                    print("Error: \(error)")
                    self.refreshControl.endRefreshing()
                }
        }
    }
    
    func sortNotification(){
        arrayNotifications =  arrayNotifications.sorted(by: {
            let dateArray1 = utilities.convertStringToDateTime(stringDate: $0.created_at!)
            let dateArray2 = utilities.convertStringToDateTime(stringDate: $1.created_at!)
            return dateArray1.compare(dateArray2) == .orderedDescending
        })
        self.refreshControl.endRefreshing()
        self.tblNotification.reloadData()
    }
    
    func getOfflineNotification(){
        let stringArray     = dbclass.returnNotifications()
        let jsonData        = stringArray.data(using: .utf8)
        arrayNotifications  = try! JSONDecoder().decode([UserNotification].self, from: jsonData!)
        tblNotification.reloadData()
    }
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell        = tblNotification.dequeueReusableCell(withIdentifier: "notificationViewCell") as! NotificationViewCell
        let id                   = arrayNotifications[indexPath.row].id!
        let stringDateTime       = arrayNotifications[indexPath.row].created_at!
        let isRead               = arrayNotifications[indexPath.row].isRead!
        let notification_type    = arrayNotifications[indexPath.row].notification_type!
        var title                = arrayNotifications[indexPath.row].notification_data?.title!
        var body                 = arrayNotifications[indexPath.row].notification_data?.body!
        let unique_id            = arrayNotifications[indexPath.row].notification_data?.unique_id!
        let datetime             = utilities.convertStringToDateTime(stringDate: stringDateTime)
        
        if(notification_type == "promotion"){
            body  = title
            title = "Lay Bare: Promotions"
        }
        if(isRead == 0){
            cell.lblBadge.isHidden = false
        }
        else{
            cell.lblBadge.isHidden = true
        }
        cell.lblDatetime.text    = utilities.getTimeAgo(dateSet: datetime,ifSpecific: false)
        cell.lblTitle.text       = title
        cell.lblContent.text     = body
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = self.tblNotification.indexPathForSelectedRow{
            self.tblNotification.deselectRow(at: index, animated: true)
        }
        let objectResult        = arrayNotifications[indexPath.row]
        let notification_type   = objectResult.notification_type ?? "N/A"
        let unique_id           = objectResult.notification_data?.unique_id ?? 0
        let id                  = objectResult.id ?? 0
        let isRead              = objectResult.isRead ?? 1
        
        if(isRead == 0){
            self.markNotificationAsSeen(id:id,indexPath: indexPath)
        }
        if(notification_type == "PLC"){
            let storyBoard = UIStoryboard(name:"PremiereStoryboard",bundle:nil)
            let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "PremiereLoyaltyClientController") as! PremiereLoyaltyClientController
            self.navigationController?.pushViewController(appointmentVC, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
        else if(notification_type == "appointment"){
            
            let stringAppointment = dbclass.getAppointmentString(unique_id:unique_id)
            if(stringAppointment == "{}"){
                self.getAppointment(unique_id: unique_id)
            }
            else{
                let jsonData    = stringAppointment.data(using: .utf8)
                let jsonDecoded = try? JSONDecoder().decode(AppointmentList.self, from: jsonData!)
                if(jsonDecoded?.transaction_status == "completed"){
                    
                    let storyBoard = UIStoryboard(name:"AppointmentStoryboard",bundle:nil)
                    let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "AppointmentDetailsController") as! AppointmentDetailsController
                    appointmentVC.objectDetails = jsonDecoded
                    self.navigationController?.pushViewController(appointmentVC, animated: true)
                    self.tabBarController?.tabBar.isHidden = true
                }
                else{
                    self.getAppointment(unique_id: unique_id)
                }
            }
        }
        else if(notification_type == "promotion"){
            let storyBoard = UIStoryboard(name:"OtherStoryboard",bundle:nil)
            let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "PromotionController") as! PromotionController
            self.navigationController?.pushViewController(appointmentVC, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
        else if(notification_type == "campaign_manager"){
            let storyBoard = UIStoryboard(name:"OtherStoryboard",bundle:nil)
            let notificationVC  = storyBoard.instantiateViewController(withIdentifier: "NotificationDetailsController") as! NotificationDetailsController
            notificationVC.objectNotification = objectResult
            notificationVC.notification_type  = "campaign_manager"
            self.navigationController?.pushViewController(notificationVC, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    func getAppointment(unique_id:Int){
        
        self.dialogUtil.showActivityIndicator(self.view)
        let myUrlString     = SERVER_URL+"/api/appointment/getAppointment/\(unique_id)";
        print(myUrlString)
        Alamofire.request(myUrlString, method: .get)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
                        return
                    }
                    self.dialogUtil.hideActivityIndicator(self.view)
                    let responseError    = response.error?.localizedDescription
                    if(statusCode == 200 || statusCode == 201){
                        if response.result.value != nil{
                            let responseJSONData = response.data
                            if(responseJSONData?.description == "false"){
                                self.showDialog(title: "No Details", message: "Sorry, this transaction has no more details")
                            }
                            else{
                                 let dataResponse             = response.data
                                 let objectResponse            = try JSONDecoder().decode(AppointmentList.self, from: dataResponse!)
                                let id                  = objectResponse.id ?? 0
                                let status              = objectResponse.transaction_status ?? ""
                                let objectData          = self.utilities.convertDataToJSONString(data: dataResponse!)
                                let appointment_date    = objectResponse.transaction_datetime ?? ""
                                let created_at          = objectResponse.created_at ?? ""
                                
                                self.dbclass.insertOrUpdateAppointment(id: id, status: status, objectData: objectData, date: appointment_date, date_updated: created_at)
                                
                                let storyBoard = UIStoryboard(name:"AppointmentStoryboard",bundle:nil)
                                let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "AppointmentDetailsController") as! AppointmentDetailsController
                                appointmentVC.objectDetails = objectResponse
                                self.navigationController?.pushViewController(appointmentVC, animated: true)
                                self.tabBarController?.tabBar.isHidden = true
                            }
                        }
                    }
                    else{
                        self.showDialog(title: "No Details", message: "Sorry, this transaction has no more details")
                    }
                }
                catch{
                    self.showDialog(title: "No Details", message: "Sorry, this transaction has no more details")
                }
        }
    }
    
    func markNotificationAsSeen(id:Int,indexPath:IndexPath)  {
        
        let myUrlString     = "\(SERVER_URL)/api/mobile/setNotificationAsSeen?token=\(token)";
            Alamofire.request(myUrlString, method: .post)
                .responseJSON { response in
                    do{
                        guard let statusCode   = try response.response?.statusCode else {
                            return
                        }
                        let responseError    = response.error?.localizedDescription
                        if(statusCode == 200 || statusCode == 201){
                           print("Success as seen")
                        }
                        self.dbclass.updateNotificationAsSeen(id: id)
                        self.arrayNotifications[indexPath.row].isRead = 1
                        self.tblNotification.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    }
                    catch{
                        print("Error: \(error)")
                        let objectData = self.arrayNotifications[indexPath.row].isRead = 1
                        self.dbclass.updateNotificationAsSeen(id: id)
                        self.arrayNotifications[indexPath.row].isRead = 1
                        self.tblNotification.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    }
            }
    }
    
    func showDialog(title:String,message:String){
        //alert box
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            
        }
        alertView.addAction(confirm)
        present(alertView,animated: true,completion: nil)
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
