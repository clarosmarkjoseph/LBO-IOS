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
    var arrayImages = ["a_calendar","a_location","a_home","a_clock","a_promo"]
    
    let footerMsg           = "PS: if you booked an appointment within current date, we will automatically add 2 hours from current time to ensure the slot of other clients who booked earlier"
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
        setupFooter()
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
    
    func setBranch(selectedBranch: String, selectedBranchID: Int,objectBranch:ArrayBranch) {
        branch_id           = selectedBranchID
        branch_name         = selectedBranch
        self.objectBranch   = objectBranch
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
    func setTechnician(id:Int,techName:String,start_time:String,end_time:String){
        technician_id                    = id
        technician_name                  = techName
        objectTechSchedule["start_time"] = start_time
        objectTechSchedule["end_time"]   = end_time
        arrayValue[2]                    = technician_name
        setLabels(type: "technician")
    }
    
    func showTime(){
        if(branch_id == 0 || branch_id == nil){
            self.showDialog(title: "Incomplete Details!", message: "Please provide your Branch or Technician before selecting the time of your appointment")
            return
        }
        else{
            var start_time = ""
            var end_time   = ""
            
            if(objectTechSchedule.count > 0){
                start_time  = objectTechSchedule["start_time"] as! String
                end_time    = objectTechSchedule["end_time"] as! String
            }
            else{
                start_time  = objectBranchSchedule["start_time"] as! String
                end_time    = objectBranchSchedule["end_time"] as! String
            }
            
            let viewController = UIStoryboard(name: "DialogStoryboard", bundle: nil).instantiateViewController(withIdentifier: "TimeDialogController") as? TimeDialogController
            viewController?.selected_date   = app_reserved
            viewController?.start_time      = start_time
            viewController?.end_time        = end_time
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
        let schedUrl = SERVER_URL+"/api/mobile/getBranchSchedules/\(branch_id)/\(app_reserved)"
        Alamofire.request(schedUrl, method: .get)
            .responseJSON { response in
                do{
                    self.dialogUtil.hideActivityIndicator(self.view)
                    guard let statusCode    = try response.response?.statusCode else { return }
                    let responseError       = response.error?.localizedDescription
                    if let responseJSONData = response.data{
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
            appointmentVC.rooms_count        = (objectBranch?.rooms_count!)!
            self.navigationController?.pushViewController(appointmentVC, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func setupFooter(){
        let headerView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.tblAppointment.frame.width, height: 100))
        let lblFooter: UILabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: self.tblAppointment.frame.width, height: 100))
        lblFooter.text = footerMsg
        lblFooter.textAlignment = .left
        lblFooter.text          = footerMsg
        lblFooter.numberOfLines = 0
        lblFooter.textColor     = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
        lblFooter.font          = UIFont.italicSystemFont(ofSize: 14)
        headerView.addSubview(lblFooter)
        self.tblAppointment.tableFooterView = headerView
        
    }
    
    
   

    
}



