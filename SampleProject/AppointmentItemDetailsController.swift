//
//  AppointmentItemDetailsController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/6/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Alamofire
import SQLite

class AppointmentItemDetailsController: UITableViewController {

    @IBOutlet var tblItem: UITableView!
    let utilities       = Utilities()
    let dbclass         = DatabaseHelper()
    let dialogUtil      = DialogUtility()
    var objectAppointment:AppointmentList? = nil
    var arrayItems      = [AppointmentItemList]()
    var item_type       = ""
    var clickedPosition = 0
    var transaction_id  = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transaction_id  = (objectAppointment?.id!)!
        arrayItems      = (objectAppointment?.items!)!
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrayItems.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.textColor = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Appointment Services / Products"
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell            = tableView.dequeueReusableCell(withIdentifier: "cellItem", for: indexPath) as! AppointmentItemCell
        let position        = indexPath.row
        let item_name       = arrayItems[position].item_name!.capitalized
        let item_type       = arrayItems[position].item_type!
        let item_quantity   = Int(arrayItems[position].quantity ?? 1)
        let item_status     = arrayItems[position].item_status!
        let item_price      = arrayItems[position].amount!
        let subtotal        = item_price * Double(item_quantity)
        let printTotal      = utilities.convertToStringCurrency(value:"\(subtotal)")
        
        cell.lblCaption1.text   = "Item Name: "
        cell.lblAnswer1.text    =  item_name
        cell.lblCaption2.text   = "Item Type: "
        cell.lblAnswer2.text    = item_type.capitalized
        
//        cell.lblAnswer6.frame.size.height    = 40
        cell.lblAnswer6.textAlignment        = .center
        cell.lblAnswer6.textColor            = UIColor.white
        cell.lblAnswer6.layer.cornerRadius   = 10
        cell.lblAnswer6.layer.masksToBounds  = true
        
        print("ITEM STATUS: \(item_status)")

        if item_status == "reserved"{
            cell.lblAnswer6.backgroundColor  =  #colorLiteral(red: 0.1960784314, green: 0.7725490196, blue: 0.8235294118, alpha: 1)
            cell.btnCancelItem.isHidden      = false
            cell.btnCancelItem.tag = position
            cell.btnCancelItem.addTarget(self, action:#selector(showCancelOption(sender:)), for: .touchUpInside)
        }
        else{
            cell.btnCancelItem.isHidden      = true
            if item_status == "completed"{
                cell.lblAnswer6.backgroundColor =  #colorLiteral(red: 0.5725490196, green: 0.7803921569, blue: 0.2509803922, alpha: 1)
            }
            else if item_status == "expired"{
                cell.lblAnswer6.backgroundColor =  #colorLiteral(red: 1, green: 0.7450980392, blue: 0, alpha: 1)
            }
            else{
                cell.lblAnswer6.backgroundColor =  UIColor.red
            }
        }
       
        if(item_type == "service"){
            
            let serve_time          = utilities.removeDateFromDatetime(stringDateTime: arrayItems[position].serve_time ?? arrayItems[position].book_start_time!)
            let complete_time       = utilities.removeDateFromDatetime(stringDateTime: arrayItems[position].complete_time ?? arrayItems[position].book_end_time!)
            let summary_time        = "\(utilities.getStandardTime(stringTime: serve_time)) - \(utilities.getStandardTime(stringTime: complete_time))"
            cell.lblCaption4.text   = "Summary Time: "
            cell.lblAnswer4.text    = summary_time
            cell.lblCaption5.text   = "Sub-total: "
            cell.lblAnswer5.text    = printTotal
            cell.lblCaption6.text   = "Status: "
            cell.lblAnswer6.text    = item_status.capitalized
            cell.btnCancelItem.setTitle("Cancel Service", for: .normal)
        }
            
        else{
            
            cell.stackViewQuantity.isHidden = false
            let item_info                   = arrayItems[position].item_info
            let item_size                   = item_info?.size ?? "Not Indicated"
            let item_variant                = item_info?.variant ?? "Not Indicated"
            
            cell.lblCaption3.text   = "Quantity: "
            cell.lblAnswer3.text    = "\(item_quantity) item(s)"
            
            cell.lblCaption4.text   = "Size & variant: "
            cell.lblAnswer4.text    = "\(item_size.capitalized) - \(item_variant.capitalized)"
            
            cell.lblCaption5.text   = "Sub-total:"
            cell.lblAnswer5.text    = printTotal
            
            cell.lblCaption6.text   = "Status:"
            cell.lblAnswer6.text    = item_status.capitalized
            cell.btnCancelItem.setTitle("Cancel Item", for: .normal)
        }
        
        return cell
    }
    
    @objc func showCancelOption(sender:UIButton){
        
        let index     = sender.tag
        let item_type = arrayItems[index].item_type!
        if(item_type == "service"){
            let alertView = UIAlertController(title: "Item Cancellation", message: "What is the reason of cancellation? ", preferredStyle: .actionSheet)
            
            let arrayReason = ["Hair Length","Monthly Cycle","Medical Condition","Skin Surface Condition","No show","Multiple Input","Other, Please specify"]
            for rows in arrayReason{
                
                let btnReason = UIAlertAction(title: rows, style: .default) { (action) in
                    self.showCancelConfirmation(reason: rows,position:index)
                }
                alertView.addAction(btnReason)
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                
            }
            alertView.addAction(cancel)
            present(alertView,animated: true,completion: nil)
        }
        else{
            self.showCancelConfirmation(reason:"", position: index)
        }
    }
    
    func showCancelConfirmation(reason:String,position:Int){
        
        var reason_text = ""
    
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
                    self.cancelAppointmentItem(reason:"other",reason_text:reason_text, position: position)
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
            
        }
        else{
            //alert box
            let alertView = UIAlertController(title: "Confirmation", message: "Are you sure you want to cancel this item?", preferredStyle: .alert)
            
            let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
                self.cancelAppointmentItem(reason:"",reason_text:reason_text, position: position)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                
            }
            alertView.addAction(confirm)
            alertView.addAction(cancel)
            present(alertView,animated: true,completion: nil)
        }
    }
    
    
    func cancelAppointmentItem(reason:String,reason_text:String,position:Int){
        
        self.dialogUtil.showActivityIndicator(self.view)
        let SERVER_URL      = dbclass.returnIp()
        let item_id         = arrayItems[position].id!
        let item_type       = arrayItems[position].item_type!
        let token           = utilities.getUserToken()
        var displayReason   = ""
        let requestParams = [
            "id":item_id,
            "item_type":item_type,
            "reason":reason,
            "reason_text":reason_text
            ] as [String : Any]
        if(reason == "other"){
            displayReason = reason_text
        }
        else{
            displayReason = reason
        }
        
        let myURL = URL(string: "\(SERVER_URL)/api/appointment/cancelItem?token=\(token)")
        Alamofire.request(myURL!, method: .post, parameters: requestParams)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again", ifRefresh: false,position: position, reason: "")
                        return
                    }
                    if let responseJSONData = response.data{
                        if(statusCode == 200 || statusCode == 201){
                            self.dialogUtil.hideActivityIndicator(self.view)
                            self.showDialog(title: "Appointment Cancelled", message: "Cancellation of appointment is success! ",ifRefresh:true,position: position, reason: displayReason)
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
                                self.showDialog(title:arrayError[0], message: arrayError[1], ifRefresh: false,position: 0, reason: "")
                            }
                            else{
                                self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again", ifRefresh: false,position: 0, reason: "")
                            }
                        }
                    }
                    else{
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again", ifRefresh: false,position: 0, reason: "")
                    }
                }
                catch{
                    print("error catch: \(error)")
                    self.dialogUtil.hideActivityIndicator(self.view)
                    self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again", ifRefresh: false,position: 0, reason: "")
                }
        }
        
    }
    
    func showDialog(title:String,message:String,ifRefresh:Bool,position:Int,reason:String){
        //alert box
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            if (ifRefresh == true){
                self.refreshAppointment(position: position, reason: reason)
            }
        }
        alertView.addAction(confirm)
        present(alertView,animated: true,completion: nil)
    }
    
    func refreshAppointment(position:Int,reason:String){
        do{
            let date_of_appointment = objectAppointment?.transaction_datetime!
            let datetime            = utilities.getCurrentDateTime(ifDateOrTime: "datetime")
            var countAllReserved    = 0
            var objectItem          = arrayItems[position]
            let item_type           = objectItem.item_type!
            objectItem.item_status  = "cancelled"
            objectItem.item_data!.cancel_by_id      = utilities.getUserID()
            objectItem.item_data!.cancel_by_name    = utilities.getUserName()
            objectItem.item_data!.cancel_by_type    = item_type
            objectItem.item_data!.cancel_datetime   = utilities.getCurrentDateTime(ifDateOrTime: "datetime")
            objectItem.item_data!.cancel_reason     = reason
            
            arrayItems[position] = objectItem;
            
            var index = 0
            for rows in arrayItems{
                let status = rows.item_status
                if(status == "reserved"){
                    countAllReserved+=1
                }
                if(index >= arrayItems.count - 1){
                    if(countAllReserved > 0){
                        objectAppointment?.items    = arrayItems
                        let jsonEncodedData         = try JSONEncoder().encode(objectAppointment)
                        let jsonString              = utilities.convertDataToJSONString(data: jsonEncodedData)
                        self.dbclass.insertOrUpdateAppointment(id: transaction_id, status: "reserved", objectData: jsonString, date: date_of_appointment!, date_updated: datetime)
                    }
                    else{
                        objectAppointment?.transaction_status   = "cancelled"
                        objectAppointment?.items                = arrayItems
                        let jsonEncodedData         = try JSONEncoder().encode(objectAppointment)
                        let jsonString              = utilities.convertDataToJSONString(data: jsonEncodedData)
                        self.dbclass.insertOrUpdateAppointment(id: transaction_id, status: "cancelled", objectData: jsonString, date: date_of_appointment!, date_updated: datetime)
                    }
                }
                index+=1
            }
            tblItem.reloadData()
        }
        catch{
            print("error: \(error)")
        }
    }
    
    func updateAppointmentAsCancelled(){
        
    }
    
  
   

}
