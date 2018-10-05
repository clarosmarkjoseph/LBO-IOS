//
//  AppointmentDetailsController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/5/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Alamofire
import SQLite
import EventKit

class AppointmentDetailsController: UITableViewController,AppointmentReview {
    
    @IBOutlet var tblAppointmentDetails: UITableView!
    let utilities = Utilities()
    var objectDetails:AppointmentList? = nil
    var arraySection1Caption = ["Date:","Reference No:","Type:","Branch:","Technician:","Platform:","Appointment Starts At:"]
    var arraySection1Answer  = [String]()
    var arraySection2Caption = ["Status: ","Transaction Items:","Total Price:"]
    var arraySection2Answer  = [String]()
    var arrayItems           = [AppointmentItemList]()
    let dbclass              = DatabaseHelper()
    let dialogUtil           = DialogUtility()
    var ifLoaded = false
    var transaction_status   = ""
    var SERVER_URL           = ""
//    let store                = EKEventStore()
    var ifEventPermissionGranted:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SERVER_URL         = dbclass.returnIp()
        transaction_status = (objectDetails?.transaction_status)!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(ifLoaded == true){
            getLatestAppointment(transaction_id:(objectDetails?.id!)!)
        }
        else{
            computeTotalPrice()
        }
        if transaction_status == "completed"{
            self.getAppointmentReview()
        }
    }
    
//    func checkCalendarPermission() {
//
//        store.requestAccess(to: .event) { (success, error) in
//
//            if success && error == nil {
//                self.ifEventPermissionGranted = true
//            }
//            else {
//                self.ifEventPermissionGranted = false
//                print("error = \(String(describing: error?.localizedDescription))")
//            }
//        }
//    }
    
    func getAppointmentReview(){
        
        let token           = utilities.getUserToken()
        let myURL           = URL(string: "\(SERVER_URL)/api/mobile/getAppointmentReview?token=\(token)")
        
        Alamofire.request(myURL!, method: .get)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
                        self.dialogUtil.hideActivityIndicator(self.view)
                        return
                    }
                    if let responseJSONData = response.data{
                        print("status code: \(statusCode)")
                        if(statusCode == 200 || statusCode == 201){
                            let jsonDictionary = response.result.value as! Dictionary<String,Any>
                            if(jsonDictionary.count > 0){
                                if let review_id = jsonDictionary["review_id"] as? Int{
                                    self.dbclass.deleteSpecificBranchRating(review_id: review_id)
                                    self.dbclass.insertBranchRating(review_id: review_id)
                                }
                                else{
                                    self.showReviewPopup(review_id: 0)
                                }
                            }
                            self.dialogUtil.hideActivityIndicator(self.view)
                        }
                        else if (statusCode == 401){
                            self.dialogUtil.hideActivityIndicator(self.view)
                            self.utilities.deleteAllData()
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "LoginStoryboard", bundle: nil)
                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
                            viewController.isLoggedOut      = true
                            viewController.sessionExpired   = true
                            UIApplication.shared.keyWindow?.rootViewController = viewController
                        }
                        else{
                            self.dialogUtil.hideActivityIndicator(self.view)
                        }
                    }
                    else{
                        self.dialogUtil.hideActivityIndicator(self.view)
                    }
                }
                catch{
                    print("error catch: \(error)")
                    self.dialogUtil.hideActivityIndicator(self.view)
                }
        }
                
    }
    
    func showReviewPopup(review_id:Int){
        let viewController      = UIStoryboard(name: "DialogStoryboard", bundle: nil).instantiateViewController(withIdentifier: "AppointmentPopupController") as? AppointmentPopupController
        viewController?.appointmentObject       = objectDetails
        viewController?.review_id               = review_id
        viewController?.delegate                = self
        viewController?.modalTransitionStyle    = .crossDissolve
        present(viewController!, animated: true,completion: nil)
        viewController?.popoverPresentationController?.sourceView = view
        viewController?.popoverPresentationController?.sourceRect = view.frame
    }
    
    
    func getLatestAppointment(transaction_id:Int){
        let appointment_tbl = dbclass.appointment_tbl
        do{
            let filterUpdate = appointment_tbl.filter(dbclass.appointment_id == transaction_id)
            let query        = try dbclass.db!.pluck(filterUpdate)
            
            let objectRows  = try query?.get(dbclass.appointment_object)
            let jsonData    = objectRows?.data(using: .utf8)
            objectDetails   = try JSONDecoder().decode(AppointmentList.self, from: jsonData!)
            let status      = objectDetails?.transaction_status ?? ""
            
            let arrayItems           = objectDetails?.items!
            var ifHasService         = false
            let stringDatetime       = objectDetails?.transaction_datetime!
            let transaction_datetime = utilities.convertStringToDateTime(stringDate: stringDatetime!)
            var transaction_endtime  = Date()
            
            for rows in arrayItems!{
                if let item_type = rows.item_type {
                    print("item type: \(item_type)")
                    if(item_type == "service"){
                        ifHasService = true
                        let resultEndTime = rows.book_end_time!
                        transaction_endtime = utilities.convertStringToDateTime(stringDate: resultEndTime)
                    }
                }
            }
            
            if(ifEventPermissionGranted == true){
                if(ifHasService == true){
                    print("item status: \(status)")
                    if(status != "reserved"){
                        EventCalendarForAppointmentClass.sharedInstance.removeAllEventsMatchingPredicate(startDate: transaction_datetime,endDate:transaction_endtime)
                    }
                }
            }
            arraySection1Answer.removeAll()
            arraySection2Answer.removeAll()
            self.computeTotalPrice()
          
        }
        catch{
            print("ERROR appointment Date: \(error)")
        }
    }
    
    func computeTotalPrice(){
        
        arrayItems      = (objectDetails?.items)!
        var total_price = 0.0
        for rows in arrayItems{
            let qty         = Double(rows.quantity!) ?? 1.0
            let price       = rows.amount ?? 0.0
            let subTotal    = qty * price
            total_price+=subTotal
        }
        let printTotal  = utilities.convertToStringCurrency(value: "\(total_price)")
        loadDetails(printTotal: printTotal)
    }

    func loadDetails(printTotal:String) {
        let dateOnly = utilities.removeTimeFromDatetime(stringDateTime: (objectDetails?.transaction_datetime)!)
        let timeOnly = utilities.removeDateFromDatetime(stringDateTime: (objectDetails?.transaction_datetime)!)
        let quantity = objectDetails?.items!.count ?? 0
        var qtyCaption = ""
        if quantity <= 1{
            qtyCaption = "\(quantity) item"
        }
        else{
            qtyCaption = "\(quantity) items"
        }
        
        arraySection1Answer.append(utilities.getCompleteDateString(stringDate: dateOnly))
        arraySection1Answer.append((objectDetails?.reference_no!)!)
        arraySection1Answer.append((objectDetails?.transaction_type!.capitalized)!)
        arraySection1Answer.append((objectDetails?.branch_name!)!)
        arraySection1Answer.append((objectDetails?.technician_name!)!)
        arraySection1Answer.append((objectDetails?.platform!)!)
        arraySection1Answer.append(utilities.getStandardTime(stringTime: timeOnly))
        
        arraySection2Answer.append((objectDetails?.transaction_status?.capitalized)!)
        arraySection2Answer.append("View \(qtyCaption)")
        arraySection2Answer.append(printTotal)
        
        tblAppointmentDetails.reloadData()
        ifLoaded = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return arraySection1Caption.count
        }
        return arraySection2Caption.count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Transaction Summary"
        }
        return "Transaction Details"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.textColor = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblAppointmentDetails.dequeueReusableCell(withIdentifier: "cellAppointmentDetails", for: indexPath) as! AppointmentDetailsCell
        
        let transaction_status  = objectDetails?.transaction_status!
        let sectionIndex        = indexPath.section
        let position            = indexPath.row
        
        print("transaction status: \(transaction_status)")
        
        if(sectionIndex == 0){
            if(position == 6 && transaction_status == "reserved"){
                cell.btnCancelAppointment.isHidden = false
                cell.btnCancelAppointment.addTarget(self, action:#selector(showCancelOption(sender:)), for: .touchUpInside)
            }
            else{
                cell.btnCancelAppointment.isHidden = true
            }
            cell.lblCaption.text = arraySection1Caption[position]
            cell.lblAnswer.text  = arraySection1Answer[position]
        }
        else{
            cell.lblCaption.text = arraySection2Caption[position]
            cell.lblAnswer.text  = arraySection2Answer[position]
            if position == 0{
                cell.lblAnswer.frame.size.height    = 40
                cell.lblAnswer.textAlignment        = .center
                cell.lblAnswer.textColor            = UIColor.white
                cell.lblAnswer.layer.cornerRadius   = 10
                cell.lblAnswer.layer.masksToBounds  = true
                if transaction_status == "reserved"{
                    cell.lblAnswer.backgroundColor =  #colorLiteral(red: 0.1960784314, green: 0.7725490196, blue: 0.8235294118, alpha: 1)
                }
                else if transaction_status == "completed"{
                    cell.lblAnswer.backgroundColor =  #colorLiteral(red: 0.5725490196, green: 0.7803921569, blue: 0.2509803922, alpha: 1)
                }
                else if transaction_status == "expired"{
                    cell.lblAnswer.backgroundColor =  #colorLiteral(red: 1, green: 0.7450980392, blue: 0, alpha: 1)
                }
                else{
                    cell.lblAnswer.backgroundColor =  UIColor.red
                }
            }
            if position == 1{
                cell.selectionStyle          = .default
                cell.accessoryType           = UITableViewCellAccessoryType.disclosureIndicator
                cell.lblAnswer.font          = UIFont.italicSystemFont(ofSize: 16)
                cell.lblAnswer.textAlignment = .right
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let index = self.tblAppointmentDetails.indexPathForSelectedRow{
            self.tblAppointmentDetails.deselectRow(at: index, animated: true)
        }
        
        let sectionIndex    = indexPath.section
        let position        = indexPath.row
        if(sectionIndex == 1){
            if position == 1{
                let storyBoard = UIStoryboard(name:"AppointmentStoryboard",bundle:nil)
                let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "AppointmentItemDetailsController") as! AppointmentItemDetailsController
                appointmentVC.objectAppointment = self.objectDetails!
                appointmentVC.arrayItems        = self.arrayItems
                self.navigationController?.pushViewController(appointmentVC, animated: true)
            }
        }
    }
    
    @objc func showCancelOption(sender:UIButton){
        
        let alertView = UIAlertController(title: "Appointment Cancelation", message: "What is the reason of cancellation? ", preferredStyle: .actionSheet)
        
        let arrayReason = ["Hair Length","Monthly Cycle","Medical Condition","Skin Surface Condition","No show","Multiple Input","Other, Please specify"]

        for rows in arrayReason{
            let btnReason = UIAlertAction(title: rows, style: .default) { (action) in
                self.showCancelConfirmation(reason: rows)
            }
            alertView.addAction(btnReason)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertView.addAction(cancel)
        present(alertView,animated: true,completion: nil)
    }
    
    func showCancelConfirmation(reason:String){
        var reason_text = ""
        print("value : \(reason)")
        
        if(reason == "Other, Please specify"){
            
            let alertController = UIAlertController(title: "Confirmation", message: "Are you sure you want to cancel appointment? Please type your reason", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "Type reason here..."
            }
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak alertController] _ in
                let textField           = alertController?.textFields![0] as! UITextField
                textField.placeholder   = "Type your reason here"
                reason_text             = textField.text!
                if(reason_text == "" || textField.text!.isEmpty){
                    return
                }
                else{
                    self.cancelAppointment(reason:"other",reason_text: reason_text)
                }
            }
         
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
            
        }
        else{
            //alert box
            let alertView = UIAlertController(title: "Confirmation", message: "Are you sure you want to cancel appointment?", preferredStyle: .alert)
            
            let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
                self.cancelAppointment(reason:reason,reason_text: "")
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                
            }
            alertView.addAction(confirm)
            alertView.addAction(cancel)
            present(alertView,animated: true,completion: nil)
        }
      
    }
    
    
    func cancelAppointment(reason:String,reason_text:String){
        
        self.dialogUtil.showActivityIndicator(self.view)
       
        let transaction_id  = objectDetails?.id!
        let token           = utilities.getUserToken()
        let requestParams = [
            "id":transaction_id!,
            "reason":reason,
            "reason_text":reason_text
            ] as [String : Any]
        print("parameters: \(requestParams)")
        
        let myURL = URL(string: "\(SERVER_URL)/api/appointment/cancelAppointment?token=\(token)")
        Alamofire.request(myURL!, method: .post, parameters: requestParams)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again", ifRefresh: false, reason: "")
                        return
                    }
                    if let responseJSONData = response.data{
                        print("status code: \(statusCode)")
                        if(statusCode == 200 || statusCode == 201){
                            self.dialogUtil.hideActivityIndicator(self.view)
                            self.showDialog(title: "Appointment Cancelled", message: "Cancellation of appointment is success! ",ifRefresh:true, reason: reason)
                        }
                        else if (statusCode == 401){
                            self.dialogUtil.hideActivityIndicator(self.view)
                            self.utilities.deleteAllData()
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "LoginStoryboard", bundle: nil)
                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
                            viewController.isLoggedOut      = true
                            viewController.sessionExpired   = true
                            UIApplication.shared.keyWindow?.rootViewController = viewController
                        }
                        else{
                            self.dialogUtil.hideActivityIndicator(self.view)
                            let responseValue = response.result.value
                            if responseValue != nil{
                                let arrayError = self.utilities.handleHttpResponseError(objectResponseError: responseValue as! Dictionary<String, Any> ,statusCode:statusCode)
                                self.showDialog(title:arrayError[0], message: arrayError[1], ifRefresh: false, reason: "")
                            }
                            else{
                                self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again", ifRefresh: false, reason: "")
                            }
                        }
                    }
                    else{
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again", ifRefresh: false, reason: "")
                    }
                }
                catch{
                    print("error catch: \(error)")
                    self.dialogUtil.hideActivityIndicator(self.view)
                    self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again", ifRefresh: false, reason: "")
                }
        }
        
    }
    
    func showDialog(title:String,message:String,ifRefresh:Bool,reason:String){
        //alert box
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            if (ifRefresh == true){
                self.refreshAppointment(reason:reason)
            }
        }
        alertView.addAction(confirm)
        present(alertView,animated: true,completion: nil)
    }
    
    func refreshAppointment(reason:String){
        do{
            let transaction_id  = objectDetails?.id!
            let datetime        = utilities.getCurrentDateTime(ifDateOrTime: "datetime")
            var index           = 0
            var ifHasService         = false
            let stringDatetime       = objectDetails?.transaction_datetime!
            let transaction_datetime = utilities.convertStringToDateTime(stringDate: stringDatetime!)
            var transaction_endtime  = Date()
            var arrayItems      = objectDetails?.items!
            
            for rows in arrayItems!{
                
                if let item_type = rows.item_type {
                    print("item type: \(item_type)")
                    if(item_type == "service"){
                        ifHasService = true
                        let resultEndTime = rows.book_end_time!
                        transaction_endtime = utilities.convertStringToDateTime(stringDate: resultEndTime)
                    }
                }
                
                var objectItem   = rows
                objectItem.item_status = "cancelled"
                objectItem.item_data!.cancel_by_name    = utilities.getUserName()
                objectItem.item_data!.cancel_datetime   = datetime
                objectItem.item_data!.cancel_reason     = reason
                arrayItems![index]                   = objectItem
                index+=1
            }
            
            objectDetails?.transaction_status!   = "cancelled"
            objectDetails?.items!                = arrayItems!
            
            let date_of_appointment              = objectDetails?.transaction_datetime!
            let jsonEncodedData                  = try JSONEncoder().encode(objectDetails)
            let jsonString                       = utilities.convertDataToJSONString(data: jsonEncodedData)
   
            dbclass.insertOrUpdateAppointment(id: transaction_id!, status: "cancelled", objectData: jsonString, date: date_of_appointment!, date_updated: datetime)
            
            if(ifEventPermissionGranted == true){
                if(ifHasService == true){
                    EventCalendarForAppointmentClass.sharedInstance.removeAllEventsMatchingPredicate(startDate: transaction_datetime,endDate:transaction_endtime)
                }
            }
            
            arraySection1Answer.removeAll()
            arraySection2Answer.removeAll()
            self.computeTotalPrice()
        }
        catch{
            print("Error: \(error)")
        }
    }
    
    func setAppointmentReview(review_id: Int, review_count: Double) {
        let storyBoard = UIStoryboard(name:"AppointmentStoryboard",bundle:nil)
        let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "AppointmentReviewController") as! AppointmentReviewController
        appointmentVC.appointmentObject = self.objectDetails!
        appointmentVC.review_id         = review_id
        appointmentVC.clientRating      = review_count
        self.navigationController?.pushViewController(appointmentVC, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
   
    
   
    


}


