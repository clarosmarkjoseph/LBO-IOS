//
//  AppointmentTab.swift
//  SampleProject
//
//  Created by Paolo Hilario on 5/21/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import JTAppleCalendar
import PopupDialog
import Alamofire
import EventKit

class AppointmentTab: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet var tblAppointment: UITableView!
    @IBOutlet var btnNext: UIButton!
    @IBOutlet var btnPrev: UIButton!
    
    let utilities           = Utilities()
    let dbclass             = DatabaseHelper()
    let dialogUtil          = DialogUtility()
    var client_id           = 0
    var SERVER_URL          = ""
    var appointmentResult   = [AppointmentList]()
    var stringDateSelected  = ""
    var arrayDateOfAppointment:[String:String] = [:]
    var ifLoaded            = false

    
    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor        = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
        refresh.attributedTitle  = NSAttributedString(string: "Loading...")
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    let dateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat    = "yyyy MM dd"
        formatter.timeZone      = Calendar.current.timeZone
        formatter.locale        = Calendar.current.locale
        return formatter
    }()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        SERVER_URL = dbclass.returnIp()
        btnPrev.imageView?.tintColor    = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
        btnNext.imageView?.tintColor    = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
        tblAppointment.delegate         = self
        tblAppointment.dataSource       = self
        client_id                       = utilities.getUserID()
        
        refreshControl.beginRefreshing()
        setupCalendarView()
        self.tblAppointment.isScrollEnabled         = true
        self.tblAppointment.alwaysBounceVertical    = true
        self.tblAppointment.addSubview(refreshControl)
        refreshControl.tag = 1
        self.handleRefresh()
        self.dialogUtil.showActivityIndicator(self.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        GlobalVariables.sharedInstance.setAvailableServices(array: [Int]())
        GlobalVariables.sharedInstance.setAvailableProducts(array: [Int]())
        if(ifLoaded == true){
            self.displayData(date_selected: stringDateSelected)
        }
    }
    
    //pull to refresh
    @objc func handleRefresh() {
        fetchAppointment()
    }
    
    //fetch appointment
    func fetchAppointment() {
        let client_id   = utilities.getUserID()
        let url         = "\(SERVER_URL)/api/appointment/getAppointments/client/\(client_id)/allData"
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
                        if self.dialogUtil.activityIndicator.isAnimating{
                            self.dialogUtil.hideActivityIndicator(self.view)
                        }
                        self.refreshControl.endRefreshing()
                        return
                    }
                    if let responseJSONData = response.data{
                        if(statusCode == 200 || statusCode == 201){
                            self.dbclass.deleteAppointments()
                            self.iterateResult(responseJSONData:responseJSONData)
                        }
                        else{
                            if self.dialogUtil.activityIndicator.isAnimating{
                                self.dialogUtil.hideActivityIndicator(self.view)
                            }
                            self.refreshControl.endRefreshing()
                            
                        }
                    }
                    else{
                        if self.dialogUtil.activityIndicator.isAnimating{
                            self.dialogUtil.hideActivityIndicator(self.view)
                        }
                        self.refreshControl.endRefreshing()
                    }
                }
                catch{
                    if self.dialogUtil.activityIndicator.isAnimating{
                        self.dialogUtil.hideActivityIndicator(self.view)
                    }
                    self.refreshControl.endRefreshing()
                }
        }
    }
    
    
    func iterateResult(responseJSONData:Data){
        do{
            let date_updated        = self.utilities.getCurrentDateTime(ifDateOrTime: "date")
            let jsonDecoded         = try JSONDecoder().decode([AppointmentList].self, from: responseJSONData)
            self.appointmentResult  = jsonDecoded
    
            for rows in appointmentResult{
                var ifHasService            = false
                let jsonDataObject          = try JSONEncoder().encode(rows)
                let transaction_id          = rows.id!
                let transaction_status      = rows.transaction_status!
                let technician_name         = rows.technician_name ?? "N/A"
                let transaction_datetime    = rows.transaction_datetime!
                let branch_name             = rows.branch_name!
                let start_time              = utilities.convertStringToDateTime(stringDate: transaction_datetime)
                let transaction_items       = rows.items
                var end_time                = start_time
               
                dateFormatter.dateFormat    = "yyyy-MM-dd"
                let appointment_date        = utilities.convertStringToDate(stringDate: dateFormatter.string(from: start_time))
                let currentDate             = utilities.convertStringToDate(stringDate: utilities.getCurrentDateTime(ifDateOrTime: "date"))
                
                self.dbclass.insertOrUpdateAppointment(id: transaction_id, status: transaction_status, objectData: self.utilities.convertDataToJSONString(data: jsonDataObject), date: transaction_datetime, date_updated: date_updated)
                let stringDate    = utilities.removeTimeFromDatetime(stringDateTime: transaction_datetime)
                self.arrayDateOfAppointment[stringDate] = stringDate
                
                for row in transaction_items!{
                    let item_type = row.item_type
                    if item_type == "service"{
                        ifHasService    = true
                        end_time        = utilities.convertStringToDateTime(stringDate: row.book_end_time!)
                    }
                }
                
//                if(transaction_status == "reserved"){
//                    if ifHasService == true{
////                        if(ifEventPermissionGranted == true){
////                            print("\(currentDate.compare(appointment_date))")
////                            if(currentDate.compare(appointment_date) == .orderedAscending || currentDate.compare(appointment_date) == .orderedSame){
////                                self.addCalendarEvent(withtitle: "Appointment Booking", eventStartDate: start_time, eventEndDate: end_time, branchName: branch_name, status: transaction_status, technician: technician_name)
////                            }
////                        }
//                    }
//                }
            }
            
            calendarView.reloadData()
            displayData(date_selected: stringDateSelected)
        }
        catch{
            print("WEW: \(error)")
        }
    }
    
    func displayData(date_selected:String){
        
        appointmentResult.removeAll()
        let appointment_tbl = dbclass.appointment_tbl
        do{
            let filterUpdate = appointment_tbl.filter(dbclass.appointment_date.like("\(date_selected)%"))
            let query        = try dbclass.db!.prepare(filterUpdate)

            for rows in query {
                let objectRows  = try rows.get(dbclass.appointment_object)
                let jsonData    = objectRows.data(using: .utf8)
                let jsonDecoded = try JSONDecoder().decode(AppointmentList.self, from: jsonData!)
                appointmentResult.append(jsonDecoded)
            }
            if self.dialogUtil.activityIndicator.isAnimating{
                self.dialogUtil.hideActivityIndicator(self.view)
            }
            self.refreshControl.endRefreshing()
            self.tblAppointment.reloadData()
            ifLoaded = true
        }
        catch{
            print("ERROR appointment Date: \(error)")
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
    
    @IBAction func showPrev(_ sender: Any) {
        calendarView.scrollToSegment(.previous)
    }
    @IBAction func showNext(_ sender: Any) {
        calendarView.scrollToSegment(.next)
    }
    
    
    @IBAction func btnLogin(_ sender: Any) {
        if let viewController = UIStoryboard(name: "LoginStoryboard", bundle: nil).instantiateViewController(withIdentifier: "LoginController") as? LoginController {
            if let navigator = navigationController {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if appointmentResult.count <= 0{
            var emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            emptyLabel.text             = "No appointment on this day.\n\n Click (+) to add item"
            emptyLabel.textColor        = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
            emptyLabel.numberOfLines    = 0
            emptyLabel.textAlignment    = NSTextAlignment.center
            self.tblAppointment.backgroundView = emptyLabel
            self.tblAppointment.separatorStyle = UITableViewCellSeparatorStyle.none
            return 0
        }
        else {
            self.tblAppointment.backgroundView = nil
            return appointmentResult.count
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.textColor = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblAppointment.dequeueReusableCell(withIdentifier: "cellAppointmentCalendar") as!
        AppointmentCalendarDetails
        let position = indexPath.row
        let dateTime            = appointmentResult[position].transaction_datetime!
        let dateOnly            = utilities.removeTimeFromDatetime(stringDateTime: dateTime)
        let timeOnly            = utilities.removeDateFromDatetime(stringDateTime: dateTime)
        
        let branch_name         = appointmentResult[position].branch_name ?? "N/A"
        let tech_name           = appointmentResult[position].technician_name ?? "No Technician"
        let status              = appointmentResult[position].transaction_status
        
        cell.lblDate.text       = utilities.getCompleteDateString(stringDate: dateOnly)
        cell.lblTime.text       = utilities.getStandardTime(stringTime: timeOnly)
        cell.lblBranch.text     = branch_name
        cell.lblTechnician.text = tech_name
        cell.lblStatus.text     = status?.capitalized
        
        if(status == "completed"){
            cell.lblStatus.backgroundColor = #colorLiteral(red: 0.5725490196, green: 0.7803921569, blue: 0.2509803922, alpha: 1)
        }
        else if(status == "reserved"){
            cell.lblStatus.backgroundColor = #colorLiteral(red: 0.1960784314, green: 0.7725490196, blue: 0.8235294118, alpha: 1)
        }
        else if(status == "expired"){
            cell.lblStatus.backgroundColor = #colorLiteral(red: 1, green: 0.7450980392, blue: 0, alpha: 1)
        }
        else if(status == "cancelled"){
            cell.lblStatus.backgroundColor = UIColor.red
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = self.tblAppointment.indexPathForSelectedRow{
            self.tblAppointment.deselectRow(at: index, animated: true)
        }
        let storyBoard = UIStoryboard(name:"AppointmentStoryboard",bundle:nil)
        let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "AppointmentDetailsController") as! AppointmentDetailsController
        appointmentVC.objectDetails  = appointmentResult[indexPath.row]
        self.navigationController?.pushViewController(appointmentVC, animated: true)
    }
    
    
    @IBAction func btnPress(_ sender: Any) {
        showSheetView()
    }
    
    func showSheetView(){
        let alertView = UIAlertController(title: "Select Action", message: "What would you like to do? ", preferredStyle: .actionSheet)
        let btnAppointment          = UIAlertAction(title: "Book Appointment ", style: .default) { (action) in
            self.validateAppointment()
        }
//        let btnViewAppointmentList = UIAlertAction(title: "View Appoinment List", style: .default) { (action) in
//            self.validateAppointment()
//        }
        let btnEvent = UIAlertAction(title: "Create Event / Reminders", style: .default) { (action) in
            let alert = UIAlertController(title: "Not Available", message: "Sorry, this feature is not yet available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertView.addAction(btnAppointment)
        alertView.addAction(btnEvent)
        alertView.addAction(cancel)
        present(alertView,animated: true,completion: nil)
    }
    
    
    func validateAppointment(){
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selected_date       = dateFormatter.date(from: stringDateSelected)!
        let currentDateString   = utilities.getCurrentDateTime(ifDateOrTime: "date")
        let today_date          = dateFormatter.date(from: currentDateString)
        
        if (today_date!.compare(selected_date) == .orderedSame) || (today_date!.compare(selected_date) == .orderedAscending){
            if checkIfAppointmentExist() == true{
                self.showDialog(title: "Already have appointment", message: "Sorry, you already have pending appointment. Please finish your appointment or cancel it first.")
            }
            else{
                showAppointment()
            }
        }
        else{
            self.showDialog(title: "Date is not available.", message: "Sorry, the selected date must equal or greater than current date.")
        }
    }
    
    func checkIfAppointmentExist() -> Bool{
        
        if appointmentResult.count > 0{
            for rows in appointmentResult{
                let status = rows.transaction_status
                if status == "reserved"{
                    return true
                }
            }
            return false
        }
        return false
    }
    
    func showAppointment(){
        print("currentDateTime same as selected date")
        let storyBoard = UIStoryboard(name:"AppointmentStoryboard",bundle:nil)
        let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "AppointmentFirstViewController") as! AppointmentFirstViewController
        appointmentVC.app_reserved  = self.stringDateSelected
        self.navigationController?.pushViewController(appointmentVC, animated: true)
    }
    
    func setupCalendarView(){
        
        calendarView.minimumLineSpacing         = 0
        calendarView.minimumInteritemSpacing    = 0
        
        calendarView.calendarDelegate   = self
        calendarView.calendarDataSource = self
        
        calendarView.scrollToDate(Date(),animateScroll:false)
        calendarView.selectDates([Date()])
        calendarView.visibleDates{ visibleDates in
            self.setupViewsOfCalendar(from:visibleDates)
        }
    }
    
    //configuration of calendar cell
    func configureCell(cell:JTAppleCell?, cellState:CellState){
        guard let myCustomcell      = cell as? CustomCalendarViewCell else{ return }
        dateFormatter.dateFormat    = "yyyy MM dd"
        handleCellTextColor(cell: myCustomcell, cellState: cellState)
        handleCellVisibility(cell: myCustomcell, cellState: cellState)
        handleCellSelection(cell: myCustomcell, cellState: cellState)
        handleCellEvents(cell: myCustomcell, cellState: cellState)
    }
    
    func handleCellTextColor(cell:CustomCalendarViewCell, cellState:CellState){
        let todaysDate       = Date()
        dateFormatter.dateFormat = "yyyy MM dd"
        let todaysDateString = dateFormatter.string(from: todaysDate)
        let monthDateString  = dateFormatter.string(from: cellState.date)
        
        if todaysDateString == monthDateString{
            cell.lblDate.textColor              = UIColor.black
            cell.selectedView.backgroundColor   = UIColor.brown
        }
        else{
            cell.lblDate.textColor = cellState.isSelected ? UIColor.white : UIColor.black
        }
    }
    
    func handleCellVisibility(cell:CustomCalendarViewCell, cellState:CellState){

        cell.isHidden = cellState.dateBelongsTo == .thisMonth ? false : true
    }
    
    func handleCellSelection(cell:CustomCalendarViewCell, cellState:CellState){
        cell.selectedView.isHidden = cellState.isSelected  ? false : true
    }
    
    func handleCellEvents(cell:CustomCalendarViewCell, cellState:CellState){
       
        dateFormatter.dateFormat = "yyyy-MM-dd"
        cell.uiviewEvent.isHidden = !arrayDateOfAppointment.contains( where: {$0.key == dateFormatter.string(from: cellState.date)} )
    }
    
    
}


extension AppointmentTab:JTAppleCalendarViewDataSource,JTAppleCalendarViewDelegate{
   
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        dateFormatter.dateFormat = "yyyy MM dd"
        let startDate       = dateFormatter.date(from: "2017 01 01")
        var dateComponent   = DateComponents()
        dateComponent.month = 6
        let endDate         = Calendar.current.date(byAdding: dateComponent, to: Date())
        let parameters      = ConfigurationParameters(startDate: startDate!, endDate: endDate!)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
        let validCell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCalendarViewCell", for: indexPath) as! CustomCalendarViewCell
        validCell.lblDate.text = cellState.text
        configureCell(cell: validCell, cellState: cellState)
        return validCell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(cell: cell, cellState: cellState)
        dateFormatter.dateFormat    = "yyyy-MM-dd"
        stringDateSelected = dateFormatter.string(from: date)
        displayData(date_selected: stringDateSelected)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
         configureCell(cell: cell, cellState: cellState)
    }
    

    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
    
    func setupViewsOfCalendar(from visibleDates:DateSegmentInfo){
        let date = visibleDates.monthDates.first!.date
        dateFormatter.dateFormat = "MMMM"
        lblMonth.text = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "yyyy"
        lblYear.text = dateFormatter.string(from: date)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Appointment on this day"
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
    }
    
}









