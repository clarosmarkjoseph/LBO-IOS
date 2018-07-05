//
//  AppointmentSecondViewController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/11/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Kingfisher

class AppointmentSecondViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,ProtocolAddItem {
  
    @IBOutlet var tblItemList: UITableView!
    @IBOutlet var lblTotalQty: UILabel!
    @IBOutlet var lblTotalPrice: UILabel!
    let utilities         = Utilities()
    let dbclass           = DatabaseHelper()
    var objectAppointment = Dictionary<String,Any>()
    var appointmentQueuing:[StructTransactionQueuing]? = nil
    var arrayList         = [Dictionary<String, Any>]()
    var SERVER_URL        = ""
    var totalQty:Int      = 0
    var totalPrice:Double = 0.0
    var rooms_count       = 0
    let dialogUtil        = DialogUtility()
    var selectedDateTime:Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SERVER_URL = dbclass.returnIp()
        tblItemList.delegate        = self
        tblItemList.dataSource      = self
        let selectedDatetimeString  = objectAppointment["transaction_date"] as! String
        selectedDateTime            = utilities.convertStringToDateTime(stringDate: selectedDatetimeString)
//        self.navigationItem.rightBarButtonItem              = self.editButtonItem
//        self.navigationItem.rightBarButtonItem?.tintColor   = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnAddAction(_ sender: Any) {
        let storyBoard = UIStoryboard(name:"ServicesStoryboard",bundle:nil)
        let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "ServiceProductController") as! ServiceProductController
        appointmentVC.viewType              = "appointment"
        appointmentVC.delegateAppointment   = self
        self.navigationController?.pushViewController(appointmentVC, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let position        = indexPath.row
        let cell            = tblItemList.dequeueReusableCell(withIdentifier: "cellAppointmentItem") as! AppointmentItemListViewCell
        var objectItems     = arrayList[indexPath.row] as! Dictionary<String,Any>
        let item_id         = objectItems["item_id"] as! Int
        let item_name       = objectItems["item_name"] as! String
        let item_quantity   = objectItems["item_quantity"] as! Int
        let item_price      = objectItems["item_price"] as! Double
        let item_duration   = objectItems["item_duration"] as! Int
        let item_type       = objectItems["item_type"] as! String
        let item_image      = objectItems["item_image"] as! String
        let item_size       = objectItems["item_size"] as! String
        var stringUrl       = ""
        let subTotal:Double = Double(item_quantity) * item_price

        if(item_type == "services" || item_type == "packages"){
            let item_start      = utilities.convertStringToDateTime(stringDate: objectItems["item_start_time"] as! String)
            let item_end        = utilities.convertStringToDateTime(stringDate: objectItems["item_end_time"] as! String)
            cell.lblSecondTitle.text = "Duration: "
            cell.lblSecondValue.text = "\(item_duration) mins"
            stringUrl                = SERVER_URL+"/images/services/\(item_image)"
            cell.lblThirdTitle.text  = "Time: "
            
            let formatter           = DateFormatter()
            formatter.dateFormat    = "hh:mm a"
            let datetimeStart    = formatter.string(from: item_start)
            let datetimeEnd      = formatter.string(from: item_end)
            cell.lblThirdValue.text  = "\(datetimeStart) - \(datetimeEnd)"
        }
        else{
            let item_variation  = objectItems["item_variation"] as! String
            cell.lblSecondTitle.text = "Size"
            cell.lblSecondValue.text = item_size
            stringUrl                = SERVER_URL+"/images/products/\(item_image)"
            cell.lblThirdTitle.text  = "Item Color/Variation: "
            cell.lblThirdValue.text  = item_variation
        }
        
        let myURL           = URL(string:stringUrl)
      
        cell.imgItem.kf.setImage(with: myURL)
        cell.lblQty.text        = String(item_quantity)
        cell.lblPrice.text      = "Php \(String(item_price))"
        cell.lblSubtotal.text   = "Php \(String(subTotal))"
        cell.lblItemName.text   = item_name
        
        cell.btnMinus.tag       = position
        cell.btnAdd.tag         = position
        cell.btnRemove.tag      = position
        
        cell.btnMinus.addTarget(self, action:#selector(subtractItem(sender:)), for: .touchUpInside)
        cell.btnAdd.addTarget(self, action: #selector(addItem(sender:)), for: .touchUpInside)
        cell.btnRemove.addTarget(self, action: #selector(removeItem(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func subtractItem(sender:UIButton){
        let index       = sender.tag
        let indexPath   = IndexPath(row: index, section: 0)
        let currentCell = tblItemList.cellForRow(at:indexPath)! as! AppointmentItemListViewCell
        var objectItem  = arrayList[index] as! Dictionary<String,Any>
        
        let itemType     = objectItem["item_type"] as! String
        var itemQty      = objectItem["item_quantity"] as! Int
        let itemPrice    = objectItem["item_price"] as! Double
        var initSubTotal = Double(itemQty) * itemPrice
        
        if(itemType == "services" ){
             self.showDialog(title: "Only 1 service!", message: "Sorry, you can only select service one at a time")
        }
        else{
            if(itemQty <= 1){
                self.showDialog(title: "No less than 1", message: "Sorry, quantity must not less than 1")
            }
            else{
                itemQty-=1
                objectItem["item_quantity"] = itemQty
                arrayList[index]            = objectItem
                totalQty-=1
                totalPrice-=initSubTotal
                lblTotalQty.text    = String(totalQty)
                lblTotalPrice.text  = "Php \(String(totalPrice))"
                tblItemList.reloadData()
            }
        }
    }

    @objc func addItem(sender:UIButton){
        let index       = sender.tag
        let indexPath   = IndexPath(row: index, section: 0)
        let currentCell = tblItemList.cellForRow(at:indexPath)! as! AppointmentItemListViewCell
        var objectItem  = arrayList[index] as! Dictionary<String,Any>
        
        let itemType     = objectItem["item_type"] as! String
        let itemPrice    = objectItem["item_price"] as! Double
        var itemQty      = objectItem["item_quantity"] as! Int
        var initSubTotal = Double(itemQty) * itemPrice
        
        if(itemType == "services" ){
            self.showDialog(title: "Only 1 service!", message: "Sorry, you can only select service one at a time")
        }
        else{
            if(itemQty > 5){
                self.showDialog(title: "No greater than 5", message: "Sorry, quantity must not greater than 5")
            }
            else{
                
                itemQty+=1
                objectItem["item_quantity"] = itemQty
                arrayList[index]            = objectItem
                
                initSubTotal                = Double(itemQty) * itemPrice

                totalQty+=1
                totalPrice+=initSubTotal
                
                lblTotalQty.text    = String(totalQty)
                lblTotalPrice.text  = "Php \(String(totalPrice))"
                
                tblItemList.reloadData()
            }
        }
    }
    
    @objc func removeItem(sender:UIButton){
        
        let index           = sender.tag
        let objectItem      = arrayList[index] as! Dictionary<String,Any>
        let itemQty         = objectItem["item_quantity"] as! Int
        let itemPrice       = objectItem["item_price"] as! Double
        
        let initSubtotal    = Double(itemQty) * itemPrice
        
        arrayList.remove(at: index)
        
        totalQty-=itemQty
        totalPrice-=initSubtotal
        
        lblTotalQty.text    = String(totalQty)
        lblTotalPrice.text  = "Php \(String(totalPrice))"
        reCalculateTime()
       
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 171
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = self.tblItemList.indexPathForSelectedRow{
            self.tblItemList.deselectRow(at: index, animated: true)
        }
        let position = indexPath.row
        
    }
    
    func setNewItems(id: Int, itemName: String, quantity: Int, price: Double, duration: Int, item_type: String,item_image:String,item_size:String,type_id:Int,type_data:String,item_variation:String) {
        
        dialogUtil.showActivityIndicator(self.view)
        
        var calendar       = Calendar.current
        calendar.timeZone  = Calendar.current.timeZone
        calendar.locale    = Calendar.current.locale
        
        var ifItemIsValidated:Bool = true
        var start_time:Date = Date()
        var end_time        = Date()
        var stringStart     = ""
        var stringEnd       = ""
    
        if(item_type != "products"){
            start_time  = getLastAppointmentTime()
            end_time    = calendar.date(byAdding: .minute, value: duration, to: start_time)!
            stringStart = utilities.convertDateTimeToString(date: start_time)
            stringEnd   = utilities.convertDateTimeToString(date: end_time)
        }
        
        if(arrayList.count > 0){
            
            if(self.checkIfListHasPackage() == true && item_type == "packages"){
                ifItemIsValidated = false
                self.showDialog(title: "Only 1 package at a time", message: "Sorry, you can only select atleast one (1) package at a time")
                return;
            }
            if(self.checkIfItemIsAlready(id: id,item_type: item_type) == true){
                ifItemIsValidated = false
                self.showDialog(title: "Already in the list", message: "Sorry, the selected \(item_type) is already in the list. Please choose another to continue")
                return;
            }
            if(self.validateAllItems(id: id, itemName: itemName, quantity: quantity, price: price, duration: duration, item_type: item_type, item_image: item_image, item_size: item_size, type_id: type_id, type_data: type_data) == true){
                ifItemIsValidated = false
                self.showDialog(title: "Already in the list", message: "Sorry, the selected item (\(itemName)) is conflict and cannot be combined to other service in your list.")
                return;
            }
            if(ifItemIsValidated == true){
                addToList(id: id, itemName: itemName, quantity: quantity, price: price, duration: duration, item_type: item_type,item_image:item_image,item_size:item_size,type_id:type_id,type_data:type_data, start_time: stringStart,end_time:stringEnd, item_variation: item_variation)
            }
        }
        else{
            addToList(id: id, itemName: itemName, quantity: quantity, price: price, duration: duration, item_type: item_type,item_image:item_image,item_size:item_size,type_id:type_id,type_data:type_data, start_time: stringStart,end_time:stringEnd, item_variation: item_variation)
        }
    }
    
    
    
    func getLastAppointmentTime() -> Date{
        var returnLastDatetime:Date? = nil
        if(arrayList.count > 0){
            
            var index           = 0
            for rows in arrayList{
                let listType        = rows["item_type"] as! String
                
                if(listType == "products"){
                    continue
                }
                else{
                    let list_start_time     = rows["item_start_time"] as! String
                    let list_end_time       = rows["item_end_time"] as! String
                    returnLastDatetime      = utilities.convertStringToDateTime(stringDate: list_end_time)
                }
                index+=1
            }
            if(returnLastDatetime != nil){
                return returnLastDatetime!
            }
            return selectedDateTime
        }
        return selectedDateTime
    }
    
    func reCalculateTime(){
      
        var start_time          = selectedDateTime
        var calendar            = Calendar.current
        calendar.timeZone       = Calendar.current.timeZone
        calendar.locale         = Calendar.current.locale
  
        var index = 0
        for rows in arrayList{
            var objectItem      = rows
            let listType        = rows["item_type"] as! String
            if(listType != "products"){
                let listDuration    = rows["item_duration"] as! Int
                let end_time        = calendar.date(byAdding: .minute, value: listDuration, to: start_time)!
                
                let stringStart     = utilities.convertDateTimeToString(date: start_time)
                let stringEnd       = utilities.convertDateTimeToString(date: end_time)
                
                objectItem["item_start_time"]   = stringStart
                objectItem["item_end_time"]     = stringEnd
                
                arrayList[index]                = objectItem
                start_time = end_time
            }
            
            index+=1
        }
        tblItemList.reloadData()
       
    }
    
    func checkIfListHasPackage() -> Bool{
        var returnList = false;
        if(arrayList.count > 0){
            for rows in arrayList{
                let item_type = rows["item_type"] as! String
                if(item_type == "packages"){
                    returnList = true
                    return returnList
                }
            }
        }
        else{
            return returnList
        }
        return returnList
    }
    
    func validateAllItems(id: Int, itemName: String, quantity: Int, price: Double, duration: Int, item_type: String,item_image:String,item_size:String,type_id:Int,type_data:String) -> Bool{
        var returnStatement = false
        if(item_type == "products"){
            returnStatement = false
            return returnStatement
        }
        else{
            for rows in arrayList{
                let list_type_id        = rows["item_type_id"] as! Int
                let list_type_data      = rows["item_type_data"] as! String
                let list_type           = rows["item_type"] as! String
                let jsonDataList        = utilities.convertJSONStringToData(arrayString: list_type_data)
                let jsonDataSelected    = utilities.convertJSONStringToData(arrayString: type_data)
                
                do{
                    
                    if(list_type == "products"){
                        continue
                    }
                    if(list_type == "packages"){
                        let arrayListPackage        = try JSONDecoder().decode([Int].self, from: jsonDataList)
                        for rows in arrayListPackage{
                            if(rows == type_id){
                                returnStatement = true
                                return returnStatement
                            }
                        }
                    }
                    if(list_type == "services"){
                        
                        let arrayListService        = try JSONDecoder().decode(StructServiceTypeData.self, from: jsonDataList)
                        for rowList in arrayListService.restricted!{
                            if(rowList == type_id){
                                returnStatement = true
                                return returnStatement
                            }
                            if(rowList == 0){
                                returnStatement = true
                                return returnStatement
                            }
                        }
                        
                    }
                    if(item_type == "packages"){
                        let arraySelectedPackage        = try JSONDecoder().decode([Int].self, from: jsonDataSelected)
                        for rows in arraySelectedPackage{
                            if(rows == list_type_id){
                                returnStatement = true
                                return returnStatement
                            }
                        }
                    }
                    if(item_type == "services"){
                        let arrayListService        = try JSONDecoder().decode(StructServiceTypeData.self, from: jsonDataList)
                        for rowList in arrayListService.restricted!{
                            if(rowList == type_id){
                                returnStatement = true
                                return returnStatement
                            }
                            if(rowList == 0){
                                returnStatement = true
                                return returnStatement
                            }
                        }
                    }
                    
                }
                catch{
                    print("error Package catch: \(error)")
                    return returnStatement;
                }
            }
            return returnStatement
        }
        
        return returnStatement
    }
    
    func checkIfItemIsAlready(id: Int, item_type: String) -> Bool{
        var returnStatement = false
        
        for rows in arrayList{
            let list_id        = rows["item_id"] as! Int
            let list_type      = rows["item_type"] as! String
            if(list_id == id && item_type == list_type){
                returnStatement = true
                return returnStatement
            }
        }
        return returnStatement
    }
    
    func checkIfItemIsRestricted(id: Int,item_type:String,type_id:Int,type_data:String) -> Bool{
        var returnStatement = false
        
        for rows in arrayList{
            let list_type      = rows["item_type"] as! String
            let list_type_data = rows["item_type_data"] as! String
    
            if(list_type == "services"){
                let arrayListRestrictedData = utilities.convertJSONStringToData(arrayString: list_type_data)
                do{
                    let arrayListRestricted     = try JSONDecoder().decode(StructServiceTypeData.self, from: arrayListRestrictedData)
                    for rowList in arrayListRestricted.restricted!{
                        if(rowList == 0){
                            returnStatement = true
                            return returnStatement
                        }
                        if(rowList == type_id){
                            returnStatement = true
                            return returnStatement
                        }
                    }
                }
                catch{
                      print("error services catch: \(error)")
                     return returnStatement
                }
                
            }
            if(item_type == "packages"){
                 returnStatement = true
                 return returnStatement
            }
            else{
                continue;
            }
            
        }
        return returnStatement
    }
        
        
    func addToList(id: Int, itemName: String, quantity: Int, price: Double, duration: Int, item_type: String,item_image:String,item_size:String,type_id:Int,type_data:String,start_time:String,end_time:String,item_variation:String){
        
        var objectItems                 = Dictionary<String,Any>()
        objectItems["item_id"]          = id
        objectItems["item_name"]        = itemName
        objectItems["item_quantity"]    = quantity
        objectItems["item_price"]       = price
        objectItems["item_duration"]    = duration
        objectItems["item_type"]        = item_type
        objectItems["item_type_id"]     = type_id
        objectItems["item_type_data"]   = type_data
        objectItems["item_image"]       = item_image
        objectItems["item_size"]        = item_size
        
        if(item_type == "products" ){
            objectItems["item_variation"]  = item_variation
        }
        else{
            objectItems["item_start_time"]  = start_time
            objectItems["item_end_time"]    = end_time
        }
        
        let itemInitPrice = Double(quantity) * price
        totalQty+=quantity
        totalPrice+=itemInitPrice
        lblTotalQty.text    = String(totalQty)
        lblTotalPrice.text  = "Php \(String(totalPrice))"
        arrayList.append(objectItems)
        tblItemList.reloadData()
        dialogUtil.hideActivityIndicator(self.view)
    }
    
    
    
    func showDialog(title:String,message:String){
        //alert box
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            if(self.dialogUtil.activityIndicator.isHidden == false){
                self.dialogUtil.hideActivityIndicator(self.view)
            }
        }
        alertView.addAction(confirm)
        self.present(alertView,animated: true,completion: nil)
    }
    
    
    @IBAction func nextQuestion(_ sender: Any) {
        
        var arrayServices           = [Dictionary<String,Any>]()
        var arrayProducts           = [Dictionary<String,Any>]()
        var datetimeStart           = selectedDateTime
        var totalDuration           = 0
        var dateComponent           = DateComponents()
        var dateEndSelected         = Date()
        var countQueuingConflict    = 0
        
        if(arrayList.count <= 0){
            self.showDialog(title: "List is empty!", message: "Please choose service / product before continue. Add item is located at the top right side of the screen.")
            return;
        }
        else{

            var loopIndex = 0
            for rowList in arrayList{
                var objectParams        = Dictionary<String,Any>()
                let item_id             = rowList["item_id"] as! Int
                let item_price          = rowList["item_price"] as! Double
                let item_start          = rowList["item_start_time"] as! String
                let item_end            = rowList["item_end_time"] as! String
                let item_quantity       = rowList["item_quantity"] as! Int
                let item_type           = rowList["item_type"] as! String
                
                if(item_type == "services" || item_type == "packages"){
                    let item_duration = rowList["item_duration"] as! Int
                    totalDuration+=item_duration
                    objectParams["id"]      = item_id
                    objectParams["price"]   = item_price
                    objectParams["start"]   = item_start
                    objectParams["end"]     = item_end
                    arrayServices.append(objectParams)
                }
                else{
                    objectParams["id"]          = item_id
                    objectParams["price"]       = item_price
                    objectParams["quantity"]    = item_quantity
                    arrayProducts.append(objectParams)
                   
                }
                
                if(loopIndex == arrayList.count - 1){
                    
                    if(totalDuration <= 0){
                        self.showDialog(title: "Select atleast 1 service", message: "Please choose atleast 1 service to continue.")
                        break;
                    }
                    else{
                       
                        dateComponent.minute    = totalDuration
                        dateEndSelected         = Calendar.current.date(byAdding: dateComponent, to:selectedDateTime)!
                        if((appointmentQueuing?.count)! > 0){
                            
                            for rowSchedule in appointmentQueuing!{
                                
                                let queue_tech      = rowSchedule.technician_id!
                                let queue_duration  = rowSchedule.duration!
                                let queue_start     = utilities.convertStringToDateTime(stringDate: rowSchedule.transaction_datetime!)
                                dateComponent           = DateComponents()
                                dateComponent.minute    = queue_duration
                                let queue_end           = Calendar.current.date(byAdding: dateComponent, to:queue_start)!
                                
                                if( (selectedDateTime >= queue_start && selectedDateTime <= queue_end ) ||  (dateEndSelected >= queue_start && dateEndSelected <= queue_end )){
                                    
                                    if(queue_tech > 0){
                                        self.showDialog(title: "Time is Conflict!", message: "Sorry, the time that youve selected is already reserved! Please choose another time")
                                        break;
                                    }
                                    if(queue_tech == 0 && rooms_count <= countQueuingConflict){
                                        self.showDialog(title: "No more rooms!", message: "Sorry, there is no room(s) available on this date/time")
                                        break;
                                    }
                                    else{
                                        nextAction(arrayServices:arrayServices,arrayProducts:arrayProducts)
                                    }
                                }
                                else{
                                    nextAction(arrayServices:arrayServices,arrayProducts:arrayProducts)
                                }
                            }
                        }
                        else{
                            nextAction(arrayServices:arrayServices,arrayProducts:arrayProducts)
                        }
                    }
                }
                loopIndex+=1
            }
        }
    }
    
    
    func nextAction(arrayServices:[Dictionary<String,Any>],arrayProducts:[Dictionary<String,Any>]){
        objectAppointment["products"] = arrayProducts
        objectAppointment["services"] = arrayServices
        
        let storyBoard = UIStoryboard(name:"AppointmentStoryboard",bundle:nil)
        let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "AppointmentThirdViewController") as! AppointmentThirdViewController
        appointmentVC.objectAppointment  = self.objectAppointment
        self.navigationController?.pushViewController(appointmentVC, animated: true)
        
    }
    

}
