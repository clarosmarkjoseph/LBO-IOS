//
//  AppointmentFirstViewController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/5/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Alamofire

class AppointmentFirstViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,ProtocolForAppointment,ProtocolBranch,ProtocolTechnician,ProtocolTimeForAppointment {
    
    @IBOutlet var tblAppointment: UITableView!
    
    var arrayTitle  = ["Date of Appointment","Branch","Technician","Appointment Time","Promo Code"]
    var arrayValue  = ["Select Date","Select Branch","Select Technician","Select Time","Enter Promo Code"]
    var arrayImages = ["a_calendar","a_location","a_tech","a_clock","a_promocode"]
    let footerMsg           = "Note: Same day bookings will be alloted a 2-hour advance lead time for proper appointment slot allocation."
    var branch_id           = 0
    var technician_id       = 0
    let transaction_type    = "branch_booking"
    let platform            = "APP - IOS"
    var app_time            = ""
    var branch_name         = ""
    var technician_name     = ""
    var app_reserved        = ""
    var selectedTime        = ""
    var dateSelected:Date   = Date()
    var datePickerView      = UIDatePicker()
    let utilities           = Utilities()
    let dbclass             = DatabaseHelper()
    let dialogUtil          = DialogUtility()
    var SERVER_URL          = ""
    var objectBranch:ArrayBranch? = nil
    var responseSchedules:IterateBranchSchedule? = nil
    var objectBranchSchedule      = Dictionary<String,Any>()
    var objectTechSchedule        = Dictionary<String,Any>()
    var objectAppointment         = Dictionary<String,Any>()
    var appointmentQueuing:[StructTransactionQueuing]? = nil
    let screenSize: CGRect  = UIScreen.main.bounds
    
    let dateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat    = "yyyy-MM-dd"
        formatter.timeZone      = Calendar.current.timeZone
        formatter.locale        = Calendar.current.locale
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.5725490196, green: 0.7803921569, blue: 0.2509803922, alpha: 1)
        UINavigationBar.appearance().tintColor    = #colorLiteral(red: 0.5725490196, green: 0.7803921569, blue: 0.2509803922, alpha: 1)
        tblAppointment.delegate     = self
        tblAppointment.dataSource   = self
        SERVER_URL = dbclass.returnIp()
        loadPickerDate()
    }
   
    func loadPickerDate(){
     
        if(app_reserved != "" || app_reserved != nil){
            dateFormatter.dateFormat    = "MMMM dd yyyy"
            dateFormatter.timeZone      = Calendar.current.timeZone
            dateFormatter.locale        = Calendar.current.locale
            dateSelected                = utilities.convertStringToDate(stringDate: app_reserved)
            let completeDateMonthString = dateFormatter.string(from: dateSelected)
            arrayValue[0]               = completeDateMonthString
            
            if(branch_id > 0){
                arrayValue[1].append(branch_name)
                getSchedules()
            }
            
            tblAppointment.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tblAppointment.indexPathForSelectedRow{
            self.tblAppointment.deselectRow(at: index, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayValue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let position    = indexPath.row
        let cell        = tblAppointment.dequeueReusableCell(withIdentifier: "cellAppointment") as! AppointmentTableDetails
        
        cell.lblTitle.text      = arrayTitle[position]
        cell.lblValue.text      = arrayValue[position]
        cell.imgDetails.image   = UIImage(named: arrayImages[position])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let position = indexPath.row
        if let index = self.tblAppointment.indexPathForSelectedRow{
            self.tblAppointment.deselectRow(at: index, animated: true)
        }
        if(position == 0){
            showDateDialog()
        }
        if(position == 1){
            showBranches()
        }
        if(position == 2){
            showTechnicians()
        }
        if(position == 3){
            showTime()
        }
        if(position == 4){
            self.showDialog(title: "Not available", message: "Sorry, this feature is not yet available.")
        }
    }
  
    //Date Configurations
    //show cell actions (when clicked)
    func showDateDialog(){
        let viewController = UIStoryboard(name: "DialogStoryboard", bundle: nil).instantiateViewController(withIdentifier: "DateDialogController") as? DateDialogController
        viewController?.selected_date = app_reserved
        viewController?.modalTransitionStyle = .crossDissolve
        present(viewController!, animated: true,completion: nil)
        viewController?.selected_date = app_reserved
        viewController?.delegateOfAppointment = self
        viewController?.popoverPresentationController?.sourceView = view
        viewController?.popoverPresentationController?.sourceRect = view.frame
    }
    
    func setSelectedDate(selectedDate: String) {
        app_reserved = selectedDate
        setLabels(type: "date")
        loadPickerDate()
    }
    
    //Branch Configurations
    func showBranches(){
        if(app_reserved == nil || app_reserved == ""){
            self.showDialog(title: "Incomplete Details!", message: "Please provide your date of appointment before selecting your Branch.")
            return
        }
        else{
            let viewController = UIStoryboard(name: "OtherStoryboard", bundle: nil).instantiateViewController(withIdentifier: "BranchController") as? BranchController
            viewController?.ifAppointment   = true
            viewController?.delegate        = self
            present(viewController!, animated: true,completion: nil)
        }
    }
    
    func setBranch(selectedBranch: String, selectedBranchID: Int,objectSelectedBranch:ArrayBranch,arrayIndex: Int) {
        branch_id           = selectedBranchID
        branch_name         = selectedBranch
        self.objectBranch   = objectSelectedBranch
        setLabels(type: "branch")
        getSchedules()
    }
    
    
    func showTechnicians(){
        if(branch_id == 0 || branch_id == nil){
            self.showDialog(title: "Incomplete Details!", message: "Please provide your Branch before selecting a Technician")
            return
        }
        else{
            let viewController = UIStoryboard(name: "OtherStoryboard", bundle: nil).instantiateViewController(withIdentifier: "TechnicianController") as? TechnicianController
            viewController?.ifAppointment   = true
            viewController?.delegate        = self
            viewController?.arrayTechnician = (responseSchedules?.technician)!
            present(viewController!, animated: true,completion: nil)
        }
    }
    
    func setTechnician(id:Int,techName:String,start_time:String,end_time:String,employee_id:String){
        
        let branch_classification = objectBranch?.branch_classification ?? "company-owned"
        var url = ""
        if(branch_classification == "franchised"){
            url = "https://emsf.lay-bare.com/api/getTechnicianAttendance/\(employee_id)/\(app_reserved)"
        }
        else{
            url = "https://ems.lay-bare.com/api/getTechnicianAttendance/\(employee_id)/\(app_reserved)"
        }
        dialogUtil.showActivityIndicator(self.view)
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                        return
                    }
                    if(statusCode == 200 || statusCode == 201){
                        if let responseJSONData = response.data{
                            self.dialogUtil.hideActivityIndicator(self.view)
                            let responseDecoded   = try JSONDecoder().decode(GetTechnicianRequest.self, from: responseJSONData)
                            let arrayLeave = responseDecoded.leave!
                            if(arrayLeave.count > 0){
                                for rows in arrayLeave{
                                    let status = rows.request_data?.status!
                                    if(status == "approved"){
                                        self.showDialog(title: "Technician not available!", message: "Sorry, the technician that you've selected is not available. Please choose other technician.")
                                        return
                                    }
                                }
                            }
                            self.setTechnicianSchedule(id: id, techName: techName, start_time: start_time, end_time: end_time, employee_id: employee_id)
                        }
                        else{
                            self.setTechnicianSchedule(id: id, techName: techName, start_time: start_time, end_time: end_time, employee_id: employee_id)
                        }
                    }
                    else{
                        self.setTechnicianSchedule(id: id, techName: techName, start_time: start_time, end_time: end_time, employee_id: employee_id)
                    }
                }
                catch{
                    print("ERROR NA: \(error)")
                    self.setTechnicianSchedule(id: id, techName: techName, start_time: start_time, end_time: end_time, employee_id: employee_id)
                }
        }
    }
    
    func setTechnicianSchedule(id:Int,techName:String,start_time:String,end_time:String,employee_id:String){
        technician_id                    = id
        technician_name                  = techName
        objectTechSchedule["start_time"] = start_time
        objectTechSchedule["end_time"]   = end_time
        arrayValue[2]                    = technician_name
        setLabels(type: "technician")
    }
    
    func showTime(){
        if(branch_id == 0){
            self.showDialog(title: "Incomplete Details!", message: "Please provide your Branch or Technician before selecting the time of your appointment")
            return
        }
        else{
            var start_time = ""
            var end_time   = ""
            
            if(objectTechSchedule.count > 0){
                start_time  = objectTechSchedule["start_time"] as! String
                end_time    = objectTechSchedule["end_time"] as! String
                print("start tech: \(start_time) - \(end_time)")
            }
            else{
                start_time  = objectBranchSchedule["start_time"] as! String
                end_time    = objectBranchSchedule["end_time"] as! String
            }
            let viewController = UIStoryboard(name: "DialogStoryboard", bundle: nil).instantiateViewController(withIdentifier: "TimeDialogController") as? TimeDialogController
            viewController?.selected_date   = app_reserved
            viewController?.start_time      = start_time
            viewController?.end_time        = end_time
            viewController?.hasTech         = true
            viewController?.delegateTime    = self
            viewController?.modalTransitionStyle = .crossDissolve
            viewController?.popoverPresentationController?.sourceView = view
            viewController?.popoverPresentationController?.sourceRect = view.frame
            present(viewController!, animated: true,completion: nil)
        }
    }
    
    func setTime(selectedDateTime:String) {
        dateSelected    = utilities.convertStringToDateTime(stringDate: selectedDateTime)
        let time        = utilities.removeDateFromDatetime(stringDateTime: selectedDateTime)
        let stringTime  = utilities.getStandardTime(stringTime: time)
        arrayValue[3]   = stringTime
        tblAppointment.reloadData()
    }
    
    func setLabels(type:String){
        if(type == "date"){
            branch_name     = ""
            technician_name = ""
            selectedTime    = ""
            dateSelected    = Date()
            technician_id   = 0
            branch_id       = 0
            objectBranch = nil
            objectBranchSchedule.removeAll()
            objectTechSchedule.removeAll()
            arrayValue[1]           = "Select Branch"
            arrayValue[2]           = "Select Technician"
            arrayValue[3]           = "Select Time"
            arrayValue[4]           = "Enter Promo Code"
        }
        if(type == "branch"){
            objectTechSchedule.removeAll()
            selectedTime            = ""
            technician_name         = ""
            technician_id           = 0
            arrayValue[2]           = "Select Technician"
            arrayValue[3]           = "Select Time"
        }
        if(type == "technician"){
            selectedTime    = ""
            arrayValue[3]           = "Select Time"
        }
        tblAppointment.reloadData()
    }

    func getSchedules(){
        
        dialogUtil.showActivityIndicator(self.view)
        let schedUrl = "https://lbo.lay-bare.com/api/mobile/getBranchSchedules/\(branch_id)/\(app_reserved)"
        Alamofire.request(schedUrl, method: .get)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                        return
                    }
                    if let responseJSONData = response.data{
                        self.dialogUtil.hideActivityIndicator(self.view)
                        if(statusCode == 200 || statusCode == 201){
                            self.responseSchedules   = try JSONDecoder().decode(IterateBranchSchedule.self, from: responseJSONData)
                            let resultBranchSched   = self.responseSchedules?.branch!
                            let resultTechSched     = self.responseSchedules?.technician!
                            self.appointmentQueuing = self.responseSchedules?.transactions
                            self.checkIfBranchScheduleIsConflict(resultBranchSched:resultBranchSched!)
                        }
                        else{
                            self.branch_id   = 0
                            self.branch_name = ""
                            self.setLabels(type: "branch")
                            let objectResponse = response.result.value as! Dictionary<String, Any>
                            let arrayError = self.utilities.handleHttpResponseError(objectResponseError: objectResponse ,statusCode:statusCode)
                            self.showDialog(title:arrayError[0], message: arrayError[1])
                        }
                    }
                    else{
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.branch_id   = 0
                        self.branch_name = ""
                        self.setLabels(type: "branch")
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                    }
                }
                catch{
                    print(response.error)
                    self.branch_id   = 0
                    self.branch_name = ""
                    self.setLabels(type: "branch")
                    self.dialogUtil.hideActivityIndicator(self.view)
                    self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                }
        }
    }
    
    
    func checkIfBranchScheduleIsConflict(resultBranchSched:[Branch_Schedule]){

        var index = 0
        for row in resultBranchSched{
            let sched_type      = row.schedule_type
            let dayOfWeek       = utilities.getDayOfWeek(dateSelected: dateSelected)
            let arraySchedTime  = row.schedule_data
 
            if(sched_type == "closed"){
                self.showDialog(title: "Branch is closed!", message: "Sorry, the branch is closed on this day")
                break
            }
            else{
                if((arraySchedTime?.count)! > 0){
                    objectBranchSchedule["start_time"]  = arraySchedTime![dayOfWeek].start
                    objectBranchSchedule["end_time"]    = arraySchedTime![dayOfWeek].end
                }
                else{
                    self.showDialog(title: "No Schedule!", message: "Sorry, there is no schedule on this date")
                    break
                }
            }
            if(index == resultBranchSched.count - 1){
                arrayValue[1] = branch_name
                tblAppointment.reloadData()
            }
            index+=1
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
    
    
    @IBAction func btnPress(_ sender: Any) {
        validateAction()
    }
    
    func validateAction(){
        if(arrayValue[0] == "Select Date"){
            self.showDialog(title: "Date Required!", message: "Sorry, date of Appointment is required. Please pick your date.")
            return
        }
        if(arrayValue[1] == "Select Branch"){
            self.showDialog(title: "Branch Required!", message: "Sorry, selection of branch is required. Please pick your branch.")
            return
        }
        if(arrayValue[3] == "Select Time"){
            self.showDialog(title: "Time Required!", message: "Sorry, selection time of your appointment is required. Please pick your time.")
            return
        }
            
        else{
            print("Date selected: \(utilities.convertDateTimeToString(date: dateSelected))")
            
            var objectAppointmentBranch = Dictionary<String,Any>()
            objectAppointmentBranch["value"] = branch_id
            objectAppointmentBranch["label"] = branch_name
            
            var objectAppointmentTechnician = Dictionary<String,Any>()
            objectAppointmentTechnician["value"] = technician_id
            objectAppointmentTechnician["label"] = technician_name
            
            var objectAppointmentClient = Dictionary<String,Any>()
            objectAppointmentClient["value"] = utilities.getUserID()
            objectAppointmentClient["label"] = utilities.getUserName()
            
            objectAppointment["branch"]             = objectAppointmentBranch
            objectAppointment["technician"]         = objectAppointmentTechnician
            objectAppointment["client"]             = objectAppointmentClient
            objectAppointment["services"]           = [Dictionary<String,Any>]()
            objectAppointment["products"]           = [Dictionary<String,Any>]()
            objectAppointment["platform"]           = platform
            objectAppointment["transaction_date"]   = utilities.convertDateTimeToString(date: dateSelected)
            objectAppointment["transaction_type"]   = transaction_type
            
            let storyBoard = UIStoryboard(name:"AppointmentStoryboard",bundle:nil)
            let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "AppointmentSecondViewController") as! AppointmentSecondViewController
            appointmentVC.objectAppointment  = self.objectAppointment
            appointmentVC.appointmentQueuing = appointmentQueuing
            appointmentVC.rooms_count        = objectBranch?.rooms_count ?? 0
            appointmentVC.selectedDateTime   = dateSelected
            
//            appointmentVC.arrayServices      = objectBranch?.services ?? [Int]()
//            appointmentVC.arrayProducts      = objectBranch?.products ?? [Int]()
            
            GlobalVariables.sharedInstance.setAvailableServices(array: objectBranch?.services ?? [Int]())
            GlobalVariables.sharedInstance.setAvailableProducts(array: objectBranch?.products ?? [Int]())
            
            var startBranch = Date()
            var endBranch   = Date()
            if(objectTechSchedule.count > 0){
                startBranch  = utilities.convertStringToDateTime(stringDate: "\(app_reserved) \(objectTechSchedule["start_time"] as! String):00")
                endBranch    = utilities.convertStringToDateTime(stringDate: "\(app_reserved) \(objectTechSchedule["end_time"] as! String):00")
            }
            else{
                startBranch  = utilities.convertStringToDateTime(stringDate: "\(app_reserved) \(objectBranchSchedule["start_time"] as! String):00")
                endBranch    = utilities.convertStringToDateTime(stringDate: "\(app_reserved) \(objectBranchSchedule["end_time"] as! String):00")
            }
            print("start tech: \(utilities.convertDateTimeToString(date: startBranch)) - \(utilities.convertDateTimeToString(date: endBranch))")
            appointmentVC.branchStart        = dateSelected
            appointmentVC.branchStart        = startBranch
            appointmentVC.branchEnd          = endBranch
            self.navigationController?.pushViewController(appointmentVC, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return footerMsg
    }

    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.textColor = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
    }
    
    
    
//    func setupFooter(){
//        let headerView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.tblAppointment.frame.width, height: 100))
//        let lblFooter: UILabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: self.tblAppointment.frame.width, height: 100))
//        lblFooter.text = footerMsg
//        lblFooter.textAlignment = .left
//        lblFooter.text          = footerMsg
//        lblFooter.numberOfLines = 0
//        lblFooter.textColor     = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
//        lblFooter.font          = UIFont.italicSystemFont(ofSize: 14)
//        headerView.addSubview(lblFooter)
//        self.tblAppointment.tableFooterView = headerView
//
//    }
    
    
   

    
}



