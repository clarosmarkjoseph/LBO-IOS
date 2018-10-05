//
//  BranchSchedule.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/11/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Alamofire
import SocketIO
class BranchScheduleController: UITableViewController,UICollectionViewDelegate,UICollectionViewDataSource,ProtocolBranch {
    
    @IBOutlet var activityRooms: UIActivityIndicatorView!
    @IBOutlet var activityServing: UIActivityIndicatorView!
    @IBOutlet var tblQueuing: UITableView!
    @IBOutlet var lblBranch: UILabel!
    @IBOutlet var lblSchedStatus: UILabel!
    @IBOutlet var lblSched: UILabel!
    @IBOutlet var lblCaptionForList: UILabel!
    @IBOutlet var lblTotalServing: UILabel!
    @IBOutlet var lblAvailableRoom: UILabel!
    @IBOutlet var collectionQueuing: UICollectionView!
    @IBOutlet var activityQueueList: UIActivityIndicatorView!
    
    let dialogUtil = DialogUtility()
    var objectBranch:ArrayBranch?   = nil
    var arrayQueuing                = [ArrayQueuing]()
    var parentView:UIView?          = nil
    let cellIdentifier              = "cellDetails"
    var SERVER_URL                  = ""
    let utilities                   = Utilities()
    let dbclass                     = DatabaseHelper()
    var totalAvailableRooms         = 0
    var isMainView:Bool             = true
    var isLoaded                    = false
    var socketConnection            = SocketConnection()
    var webSocket:SocketIOClient!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SERVER_URL = dbclass.returnIp()
        collectionQueuing.delegate      = self
        collectionQueuing.dataSource    = self
        tblQueuing.estimatedRowHeight   = 120
        tblQueuing.rowHeight            = UITableViewAutomaticDimension
        if(parentView == nil){
            parentView = self.view
        }
        if self.navigationController?.isNavigationBarHidden == false{
            self.navigationItem.title = "Branch Queuing and Schedule"
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isMainView == true{
            webSocket.disconnect()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isMainView == false{
            if isLoaded == false{
                isLoaded = true
                getBranchSchedule()
                totalAvailableRooms = objectBranch?.rooms_count ?? 0
                getQueueCount()
            }
        }
        else{
            webSocket  = socketConnection.getWebSocket()
            webSocket.connect()
            webSocket.on("refreshAppointments") {data, ack in
                guard let objectSocket = data[0] as? Dictionary<String,Any> else { return }
                print("HAHA QUEUEU: \(objectSocket)")
                let queue_branch    = objectSocket["branch_id"] as! Int
                if(self.objectBranch != nil){
                    let branch_id = self.objectBranch?.id
                    if(queue_branch == branch_id){
                        self.loadQueuing()
                    }
                }
            }
            self.navigationController?.navigationBar.tintColor = UIColor.white;
        }
    }
    
    
    func selectBranch(){
        let viewController = UIStoryboard(name: "OtherStoryboard", bundle: nil).instantiateViewController(withIdentifier: "BranchController") as? BranchController
        viewController?.ifAppointment   = true
        viewController?.delegate        = self
        present(viewController!, animated: true,completion: nil)
    }
    
   
    
    func setBranch(selectedBranch: String, selectedBranchID: Int, objectSelectedBranch: ArrayBranch,arrayIndex: Int) {
        objectBranch        = objectSelectedBranch
        lblBranch.text      = objectSelectedBranch.branch_name ?? "N/A"
        totalAvailableRooms  = objectBranch?.rooms_count ?? 0
        getBranchSchedule()
        getQueueCount()
    }
    
    
    func getBranchSchedule(){
        
        dialogUtil.showActivityIndicator(parentView!)
        let currentDate = utilities.getCurrentDateTime(ifDateOrTime: "date")
        let branch_id   = objectBranch?.id!
        let url         = "\(SERVER_URL)/api/mobile/getBranchSchedules/\(branch_id!)/\(currentDate)"
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                        return
                    }
                    if response.data != nil{
                        if(statusCode == 200 || statusCode == 201){
                            let decodeResult = try JSONDecoder().decode(IterateBranchSchedule.self, from: response.data!)
                            if decodeResult.branch!.count > 0{
                                for rows in decodeResult.branch!{
                                    
                                    let getDaysOfWeek = self.utilities.getDayOfWeek(dateSelected: self.utilities.convertStringToDate(stringDate: currentDate))
                                    let schedule_type = rows.schedule_type
                                    let schedule_data = rows.schedule_data![getDaysOfWeek]
                                    
                                    if(schedule_type == "closed"){
                                        self.lblSchedStatus.backgroundColor  = UIColor.red
                                        self.lblSchedStatus.text             = schedule_type?.uppercased()
                                        self.lblCaptionForList.text          = "No Appointment(s) today!"
                                        self.lblCaptionForList.textAlignment = .center
                                        self.lblSched.text                   = "Sorry, the branch is closed today!"
                                    }
                                    else if schedule_type == "custom"{
                                        self.lblSchedStatus.backgroundColor = #colorLiteral(red: 0.5568627451, green: 0.2666666667, blue: 0.6784313725, alpha: 1)
                                        self.lblSchedStatus.text = "OPEN"
                                        self.lblSched.text = "Opens from \(self.utilities.getStandardTime(stringTime: schedule_data.start!)) - \(self.utilities.getStandardTime(stringTime: schedule_data.end!))"
                                    }
                                    else{
                                        self.lblSchedStatus.backgroundColor = #colorLiteral(red: 0.5725490196, green: 0.7803921569, blue: 0.2509803922, alpha: 1)
                                        self.lblSchedStatus.text = "OPEN"
                                        self.lblSched.text = "Opens from \(self.utilities.getStandardTime(stringTime: schedule_data.start!)) - \(self.utilities.getStandardTime(stringTime: schedule_data.end!))"
                                    }
                                   
                                    self.isLoaded = true
                                    self.collectionQueuing.reloadData()
                                    self.loadQueuing()
                                    self.dialogUtil.hideActivityIndicator(self.view)
                                    break
                                }
                            }
                            else{
                                self.lblCaptionForList.text          = "No Appointment(s) today!"
                                self.lblCaptionForList.isHidden      = false
                                self.lblCaptionForList.textAlignment = .center
                                self.isLoaded = true
                                self.collectionQueuing.reloadData()
                                self.loadQueuing()
                                self.dialogUtil.hideActivityIndicator(self.view)
                            }
                            self.tblQueuing.reloadData()
                        }
                        else{
                            self.dialogUtil.hideActivityIndicator(self.view)
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
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                    }
                }
                catch{
                    print("ERROR schedule: \(error)")
                    self.dialogUtil.hideActivityIndicator(self.view)
                    self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                }
        }
    }
    
    
    func loadQueuing(){
        
        print("Load Queuing")
        activityQueueList.isHidden = false
        collectionQueuing.isHidden = true
        
        let branch_id   = objectBranch?.id!
        let url         = "\(SERVER_URL)/api/kiosk/getQueue/\(branch_id!)"
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                        return
                    }
                    if response.data != nil{
                        if(statusCode == 200 || statusCode == 201){
                            
                            self.arrayQueuing = try JSONDecoder().decode([ArrayQueuing].self, from: response.data!)
                            self.activityQueueList.isHidden = true
                            self.collectionQueuing.isHidden = false
                            self.collectionQueuing.reloadData()
                            self.tblQueuing.reloadData()
                        }
                        else{
                            self.activityQueueList.isHidden = true
                            self.collectionQueuing.isHidden = false
                            self.collectionQueuing.reloadData()
                            let responseValue = response.result.value
                            if responseValue != nil{
                                let arrayError = self.utilities.handleHttpResponseError(objectResponseError: responseValue as! Dictionary<String, Any> ,statusCode:statusCode)
                                self.showDialog(title:arrayError[0], message: arrayError[1])
                            }
                            else{
                                self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                            }
                            self.tblQueuing.reloadData()
                        }
                    }
                    else{
                        self.activityQueueList.isHidden = true
                        self.collectionQueuing.isHidden = false
                        self.collectionQueuing.reloadData()
                        self.tblQueuing.reloadData()
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                    }
                }
                catch{
                    print("ERROR Queuing: \(error)")
                    self.activityQueueList.isHidden = true
                    self.collectionQueuing.isHidden = false
                    self.collectionQueuing.reloadData()
                    self.tblQueuing.reloadData()
                    self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getQueuingCallOrServe(){
        self.lblTotalServing.isHidden   = true
        self.lblAvailableRoom.isHidden  = true
        self.activityServing.isHidden   = false
        self.activityRooms.isHidden     = false
    }
    func setQueuingCallOrServe(){
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.lblTotalServing.isHidden   = false
            self.lblAvailableRoom.isHidden  = false
            self.activityServing.isHidden   = true
            self.activityRooms.isHidden     = true
        }
    }
    
    //it is called once websocket is set up
    func getQueueCount(){
        
        if let branch_id = objectBranch?.id{
            
            self.getQueuingCallOrServe()
            let url_queue   = "https://lbo-express.azurewebsites.net/api/queuing/\(branch_id)"
            Alamofire.request(url_queue, method: .get)
                .responseJSON { response in
                    do{
                        guard let statusCode   = try response.response?.statusCode else {
                            
                            return
                        }
                        if response.data != nil{
                            if(statusCode == 200 || statusCode == 201){
                                let expressResult = try JSONDecoder().decode(QueuingExpressResult.self, from: response.data!)
                                let countServing            = expressResult.serving?.count ?? 0
                                let availableCubicle        = self.totalAvailableRooms - countServing
                                self.lblTotalServing.text   = "\(countServing)"
                                self.lblAvailableRoom.text  = "\(availableCubicle)"
                                if !self.dialogUtil.activityIndicator.isHidden{
                                    self.dialogUtil.hideActivityIndicator(self.view)
                                }
                                self.setQueuingCallOrServe()
                            }
                            else{
                                self.setQueuingCallOrServe()
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
                            self.setQueuingCallOrServe()
                            self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                        }
                    }
                    catch{
                        print("ERROR Queuing: \(error)")
                        self.setQueuingCallOrServe()
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                    }
            }
        }
    }
    
    @IBAction func bookAppointment(_ sender: UIButton) {
        let clientID = utilities.getUserID()
        if(clientID <= 0){
            //alert box
            let alertView = UIAlertController(title: "Chat not available", message: "Chat messaging is not available when not yet login", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "Login", style: .default) { (action) in
                if let viewController = UIStoryboard(name: "LoginStoryboard", bundle: nil).instantiateViewController(withIdentifier: "LoginController") as? LoginController {
                    if let navigator = self.navigationController {
                        viewController.sessionExpired = false
                        navigator.present(viewController, animated: true)
                    }
                }
            }
            let cancel = UIAlertAction(title: "Cancel", style: .default) { (action) in
                
            }
            alertView.addAction(confirm)
            alertView.addAction(cancel)
            present(alertView,animated: true,completion: nil)
            
            return
        }
        else{
            let storyBoard = UIStoryboard(name:"AppointmentStoryboard",bundle:nil)
            let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "AppointmentFirstViewController") as! AppointmentFirstViewController
            appointmentVC.app_reserved  = utilities.getCurrentDateTime(ifDateOrTime: "date")
            appointmentVC.branch_id     = objectBranch?.id ?? 0
            appointmentVC.branch_name   = objectBranch?.branch_name ?? "N/A"
            self.navigationController?.pushViewController(appointmentVC, animated: true)
        }
       
    }
    
    
    @IBAction func viewBranchCalendar(_ sender: Any) {
        self.showDialog(title: "Calendar not available", message: "Sorry, branch calendar is not yet available")
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0{
            
            if indexPath.row == 0{
                if isMainView == true{
                    return 120
                }
                return 0
            }
            else if indexPath.row == 1{
                if isLoaded == false{
                    return 0
                }
                return 180
            }
            else if indexPath.row == 2{
                if isLoaded == false{
                    return 0
                }
                return 145
            }
            else{
                return 60
            }
        }
        
        return CGFloat(arrayQueuing.count * 120)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
       return 2
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let position = indexPath.row
        if indexPath.section == 0{
            if position == 0{
                if let index = self.tblQueuing.indexPathForSelectedRow{
                    self.tblQueuing.deselectRow(at: index, animated: true)
                }
                selectBranch()
            }
        }
        else{
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayQueuing.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell                    = collectionQueuing.dequeueReusableCell(withReuseIdentifier: "cellQueue", for: indexPath) as!  BranchQueuingViewCell
        let position                = indexPath.row
        let first_name              = arrayQueuing[position].first_name ?? "Client"
        let id                      = arrayQueuing[position].client_id ?? 0
        let technician_name         = arrayQueuing[position].technician_name ?? "N/A"
        let transaction_datetime    = arrayQueuing[position].transaction_datetime
        let time                    = utilities.removeDateFromDatetime(stringDateTime: transaction_datetime!)
        let stringStandardTime      = utilities.getStandardTime(stringTime: time)
        
        cell.lblClientName.text     = first_name.capitalized
        cell.lblClientID.text       = "ID: \(id)"
        cell.lblClientTech.text     = "Tech: \(technician_name.capitalized)"
        cell.lblClientTime.text     = "Time: \(stringStandardTime)"
        return cell
    }
   
    
    func showDialog(title:String,message:String){
        //alert box
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            
        }
        alertView.addAction(confirm)
        present(alertView,animated: true,completion: nil)
    }
}
