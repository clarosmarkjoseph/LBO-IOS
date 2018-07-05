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


class AppointmentTab: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var uiLogin: UIView!
    @IBOutlet weak var uiAppointment: UIView!
    @IBOutlet var tblAppointment: UITableView!
    @IBOutlet var btnNext: UIButton!
    @IBOutlet var btnPrev: UIButton!
    var ifTermsAgree = false
    let utilities = Utilities()
    let dbclass   = DatabaseHelper()
    var client_id = 0
    var date_selected = ""
    var arrayLBOAppointment:[LBOAppointmentData]? =  [LBOAppointmentData]()
    let dialogUtil = DialogUtility()
    var SERVER_URL = ""
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor        = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
        refreshControl.attributedTitle  = NSAttributedString(string: "Get latest appointments.")
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        return refreshControl
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
        if(client_id <= 0){
            uiLogin.isHidden        = false
            uiAppointment.isHidden  = true
        }
        else{
            uiLogin.isHidden        = true
            uiAppointment.isHidden  = false
            setupCalendarView()
        }
        self.tblAppointment.addSubview(refreshControl)
        
        
    }
    
    //pull to refresh
    @objc func handleRefresh(_ handleRefresh: UIRefreshControl) {
        refreshControl.beginRefreshing()
        fetchAppointment()
    }
    
    //fetch appointment
    func fetchAppointment() {
        
        let client_id = utilities.getUserID()
        self.dialogUtil.showActivityIndicator(self.view)
        let promoURL = "\(SERVER_URL)/api/appointment/getAppointments/\(client_id)/allData"
        Alamofire.request(promoURL, method: .get)
            .responseJSON { response in
                do{
                    self.dialogUtil.hideActivityIndicator(self.view)
                    guard let statusCode    = try response.response?.statusCode else { return }
                    if let responseJSONData = response.data{
                        if(statusCode == 200 || statusCode == 201){
                            
                            do{
                                let date_updated    = self.utilities.getCurrentDateTime(ifDateOrTime: "datetime")
                                
                                
                                self.dbclass.insertOrUpdateAppointment(id: <#T##Int#>, status: <#T##String#>, objectData: <#T##String#>, date: <#T##String#>, date_updated: <#T##String#>)
                               
                                
                            }
                            catch{
                                print("ERROR DB Branch \(error)")
                            }
                        }
                        else{
//                            self.loadPromotions()
                            let objectResponse = response.result.value as! Dictionary<String, Any>
                            let arrayError = self.utilities.handleHttpResponseError(objectResponseError: objectResponse ,statusCode:statusCode)
//                            self.showDialog(title:arrayError[0], message: arrayError[1])
                        }
                    }
                    else{
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                        
                    }
                }
                catch{
                    print(response.error)
                    self.dialogUtil.hideActivityIndicator(self.view)
                    self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { // change 2 to desired number of seconds
            self.tblAppointment.reloadData()
            self.refreshControl.endRefreshing()
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
    
    func setupViewsOfCalendar(from visibleDates:DateSegmentInfo){
        let date = visibleDates.monthDates.first!.date
        dateFormatter.dateFormat = "MMMM"
        lblMonth.text = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "yyyy"
        lblYear.text = dateFormatter.string(from: date)
    }

    func handleCellTextColor(cell:CustomCalendarViewCell, cellState:CellState){
        
        let todaysDate       = Date()
        dateFormatter.dateFormat = "yyyy MM dd"
        let todaysDateString = dateFormatter.string(from: todaysDate)
        let monthDateString  = dateFormatter.string(from: cellState.date)

        if cellState.isSelected{
            cell.lblDate.textColor     = UIColor.lightGray
        }
        else{
            if(cellState.dateBelongsTo == .thisMonth){
                cell.lblDate.textColor     = UIColor.black
            }
            else{
                cell.lblDate.textColor     =  UIColor.lightGray
            }
        }
    }


    func handleCellSelected(cell:CustomCalendarViewCell, cellState:CellState){
       
        if cell.isSelected {
            cell.selectedView.isHidden = false
        }
        else{
            cell.selectedView.isHidden = true
        }
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
        return (arrayLBOAppointment?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblAppointment.dequeueReusableCell(withIdentifier: "cellAppointmentCalendar") as!
        AppointmentCalendarDetails
        
        return cell
        
    }
    
    @IBAction func btnPress(_ sender: Any) {
        showSheetView()
    }
    
    func showSheetView(){
        let alertView = UIAlertController(title: "Select Action", message: "What would you like to do? ", preferredStyle: .actionSheet)
        
        let btnEvent = UIAlertAction(title: "Create Event / Reminders", style: .default) { (action) in
            let alert = UIAlertController(title: "Not Available", message: "Sorry, this feature is not yet available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        let btnAppointment = UIAlertAction(title: "Book Appointment ", style: .default) { (action) in
            let storyBoard = UIStoryboard(name:"AppointmentStoryboard",bundle:nil)
            let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "AppointmentFirstViewController") as! AppointmentFirstViewController
            appointmentVC.app_reserved  = self.date_selected
            self.navigationController?.pushViewController(appointmentVC, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertView.addAction(btnAppointment)
        alertView.addAction(btnEvent)
        alertView.addAction(cancel)
        present(alertView,animated: true,completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    
}


extension AppointmentTab:JTAppleCalendarViewDataSource{
    
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {

    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let startDate       = dateFormatter.date(from: "2017 01 01")
        var dateComponent   = DateComponents()
        dateComponent.month = 6
        let endDate         = Calendar.current.date(byAdding: dateComponent, to: Date())
        let parameters      = ConfigurationParameters(startDate: startDate!, endDate: endDate!)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }

}

extension AppointmentTab:JTAppleCalendarViewDelegate{
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCalendarViewCell", for: indexPath) as! CustomCalendarViewCell
        cell.lblDate.text = cellState.text
        
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
    
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CustomCalendarViewCell else { return }
        handleCellSelected(cell: validCell, cellState: cellState)
        handleCellTextColor(cell: validCell, cellState: cellState)
       
        let formatter           = DateFormatter()
        formatter.dateFormat    = "yyyy-MM-dd"
        date_selected           = formatter.string(from: cellState.date)
  
        if(cellState.dateBelongsTo == .followingMonthOutsideBoundary || cellState.dateBelongsTo == .followingMonthWithinBoundary){
            calendarView.scrollToSegment(.next)
        }
        
        if(cellState.dateBelongsTo == .previousMonthWithinBoundary || cellState.dateBelongsTo == .previousMonthOutsideBoundary){
            calendarView.scrollToSegment(.previous)
        }
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CustomCalendarViewCell else { return }
        handleCellSelected(cell: validCell, cellState: cellState)
        handleCellTextColor(cell: validCell, cellState: cellState)
    }
    
    
    
}

