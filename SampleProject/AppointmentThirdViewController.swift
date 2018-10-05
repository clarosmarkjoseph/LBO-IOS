//
//  AppointmentThirdViewController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/18/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Alamofire
import SocketIO

class AppointmentThirdViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tblWaiver: UITableView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var lblBday: UILabel!
    @IBOutlet var lblGender: UILabel!
    @IBOutlet var lblMobile: UILabel!
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var lblBranch: UILabel!
    let utilities         = Utilities()
    let dialogUtil        = DialogUtility()
    var SERVER_URL        = ""
    let dbclass           = DatabaseHelper()
    var gender            = ""
    var objectWaiverData        = Dictionary<String,Any>()
    var objectAppointment       = Dictionary<String,Any>()
    var arrayWaiverQuestion     = [Dictionary<String,Any>]()
    var arrayDisabledServices   = [Int]()
    var ifHasMonthlyCycle       = false
    var socketConnection        = SocketConnection()
    var webSocket:SocketIOClient!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webSocket = socketConnection.getWebSocket()
        webSocket.connect()
        
        tblWaiver.delegate           = self
        tblWaiver.dataSource         = self
        tblWaiver.rowHeight          = UITableViewAutomaticDimension
        tblWaiver.estimatedRowHeight = 100
        SERVER_URL              = dbclass.returnIp()
        gender                  = utilities.getUserGender()
        getClientDetails()
        loadWaiver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        webSocket.disconnect()
    }
    
    func getClientDetails(){
        lblName.text     = utilities.getUserName()
        lblAddress.text  = utilities.getUserAddress()
        lblBday.text     = utilities.getCompleteDateString(stringDate: utilities.getUserBirthday())
        lblEmail.text    = utilities.getUserEmail()
        lblMobile.text   = utilities.getUserMobile()
        lblGender.text   = utilities.getUserGender().uppercased()
        let objectBranch = objectAppointment["branch"] as! Dictionary<String,Any>
        lblBranch.text   = objectBranch["label"] as! String
    }
    
    func loadWaiver(){
    
        dialogUtil.showActivityIndicator(self.view)
        let waiver_tbl = dbclass.waiver_tbl
        do{
            if let queryWaiver          = try dbclass.db?.pluck(waiver_tbl) {
                let arrayStringWaiver   = queryWaiver[dbclass.waiver_data]
                let jsonData            = utilities.convertJSONStringToData(arrayString: arrayStringWaiver)
                let encodedJSON         = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [Dictionary<String,Any>]
               
                for rowWaiver in encodedJSON{
                
                    let waiver_question   = rowWaiver["question"] as! String
                    let waiver_gender     = rowWaiver["target_gender"] as! String
                    let waiver_type       = rowWaiver["question_type"] as! String
                    let waiver_data       = rowWaiver["question_data"] as! Dictionary<String,Any>
                    let default_selected  = waiver_data["default_selected"] as! String
                    let placeholder       = waiver_data["placeholder"] as! String
                    var ifSelected        = false
                    
                    
                    if(waiver_gender.lowercased() == gender.lowercased() || waiver_gender == "both"){
                        var appendWaiverObject      = Dictionary<String,Any>()
                        var appendWaiverData        = Dictionary<String,Any>()
                        var arrayOptions            = [Dictionary<String,Any>()]
                        var message                 = ""
                        
                        if(default_selected == "YES"){
                            ifSelected = true
                        }
                        else{
                            ifSelected = false
                        }
                        
                        if waiver_data.keys.contains("message"){
                            message = waiver_data["message"] as! String
                        }
                        if waiver_data.keys.contains("options"){
                            arrayOptions = waiver_data["options"] as! [Dictionary<String,Any>]
                            var index           = 0
                            var selected_option = 0
                            
                            for rows in arrayOptions{
                                var objectRows       = rows
                                if(objectRows["textbox"] as! Bool == false){
                                    selected_option = 0
                                }
                                else{
                                    selected_option = 1
                                }
                                objectRows["answer"] = ""
                                arrayOptions[index]  = objectRows
                                index+=1
                            }
                            print("Array arrayOptions: \(arrayOptions)")
                            appendWaiverData["selected_option"] = selected_option
                            appendWaiverData["options"]         = arrayOptions
                        }
                        
                        if waiver_data.keys.contains("disallowed_services"){
                            arrayDisabledServices               = waiver_data["disallowed_services"] as! [Int]
                            appendWaiverData["disallowed"]      = waiver_data["disallowed_services"] as! [Int]
                        }
                       
                        appendWaiverData["message"]     = message
                        appendWaiverData["answer"]      = ""
                        appendWaiverData["placeholder"] = placeholder
                
                        appendWaiverObject["target_gender"] = waiver_gender
                        appendWaiverObject["question"]      = waiver_question
                        appendWaiverObject["selected"]      = ifSelected
                        appendWaiverObject["data"]          = appendWaiverData
                        
                        arrayWaiverQuestion.append(appendWaiverObject)
                    }
                    else{
                        continue
                    }
                }
                tblWaiver.reloadData()
                dialogUtil.hideActivityIndicator(self.view)
            }
            else{
                getWaiver()
            }
        }
        catch{
            print("ERROR DB Branch \(error)")
        }
       
    }
    
    func getWaiver(){
        let schedUrl = SERVER_URL+"/api/waiver/getWaiverQuestions"
        Alamofire.request(schedUrl, method: .get)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                        return
                    }
                    
                    if(statusCode == 200 || statusCode == 201){
                        let responseJSONData    = response.result.value as! [Dictionary<String,Any>]
                        self.dbclass.insertWaiver(waiverString: self.utilities.convertJSONArrayToString(objectParse: responseJSONData))
                        self.loadWaiver()
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
                catch{
                    self.dialogUtil.hideActivityIndicator(self.view)
                    self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                }
        }
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayWaiverQuestion.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell                = tblWaiver.dequeueReusableCell(withIdentifier: "cellWaiver") as! AppointmentWaiverCell
        let position            = indexPath.row
        var objectWaiver        = arrayWaiverQuestion[position] as! Dictionary<String,Any>
        let question            = objectWaiver["question"] as! String
        let selected            = objectWaiver["selected"] as! Bool
        let data                = objectWaiver["data"] as! Dictionary<String,Any>
        let data_placeholder    = data["placeholder"] as! String
        var data_message        = ""
        var data_answer         = ""
        var arrayOptions        = [Dictionary<String,Any>()]
        
        if(data.keys.contains("message")){
            data_message = data["message"] as! String
        }
        if(data.keys.contains("answer")){
            data_answer = data["answer"] as! String
        }
        if(data.keys.contains("options")){
            arrayOptions        = data["options"] as! [Dictionary<String,Any>]
            let position_option = data["selected_option"] as! Int
            let option_answer   = arrayOptions[position_option]["answer"] as! String
            data_answer         = option_answer
        }

        
        cell.lblWaiverQuestion.text = question
        cell.segmentYesOrNo.tag     = position

        if(selected == true){
            cell.segmentYesOrNo.selectedSegmentIndex = 0
            cell.lblAnswer.isHidden = false
            cell.lblAnswer.text = "Answer: \(data_answer)"
            if(indexPath.row == 0 ){
                cell.lblAnswer.isHidden = true
            }
         
        }
        else{
            cell.segmentYesOrNo.selectedSegmentIndex = 1
            cell.lblAnswer.isHidden = true
            if(indexPath.row == 0 ){
                cell.lblAnswer.isHidden = false
                cell.lblAnswer.text = "Answer: \(data_answer)"
            }
        }
        cell.segmentYesOrNo.addTarget(self, action: #selector(changeWaiverAnswer(sender:)), for: .valueChanged)
        return cell
    }

    
    @objc func changeWaiverAnswer(sender:UISegmentedControl){
        
        let selectedIndex       = sender.selectedSegmentIndex
        let position            = sender.tag
        var objectWaiver        = arrayWaiverQuestion[position]
        var selected            = objectWaiver["selected"] as! Bool
        let objectData          = objectWaiver["data"] as! Dictionary<String,Any>
        
        if(position == 0){
            if(selectedIndex == 1){
                showWaiverQuestions(indexWaiver: position)
            }
            else{
                selected = true
                objectWaiver["selected"] = selected
                objectWaiver["remarks"]  = ""
                arrayWaiverQuestion[position] = objectWaiver
                tblWaiver.reloadData()
            }
        }
        if(position == 5){
            if(selectedIndex == 0){
                showPopupForPregnancy(indexWaiver:position)
            }
            else{
                selected = false
                objectWaiver["selected"] = selected
                objectWaiver["remarks"]  = ""
                arrayWaiverQuestion[position] = objectWaiver
                tblWaiver.reloadData()
            }
        }
        else{
            
            if(selectedIndex == 0){
                if(selectedIndex == 6){
                    ifHasMonthlyCycle = true
                }
                showWaiverQuestions(indexWaiver: position)
            }
            else{
                ifHasMonthlyCycle = false
                selected = false
                objectWaiver["selected"] = selected
                objectWaiver["remarks"]  = ""
                arrayWaiverQuestion[position] = objectWaiver
                tblWaiver.reloadData()
            }
        }
    }
    
    func showWaiverQuestions(indexWaiver:Int){
        
        var objectQuestion  = self.arrayWaiverQuestion[indexWaiver]
        var waiver_selected = objectQuestion["selected"] as! Bool
        var waiver_question = objectQuestion["question"] as! String
        var waiver_data     = objectQuestion["data"] as! Dictionary<String,Any>
        var placeholder     = waiver_data["placeholder"] as! String
        var question_message = ""
        var question_answer  = ""
        
        if(waiver_data.keys.contains("message")){
            question_message = waiver_data["message"]as! String
        }
        if(waiver_data.keys.contains("answer")){
            question_answer = waiver_data["answer"] as! String
        }

        
        let alertController = UIAlertController(title: "Waiver Question", message: question_message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            let answer    = textField.text!
            
            if(answer == "" || textField.text!.isEmpty){
                self.utilities.showToast(message:"Remarks must not empty",view:self.view)
                return
            }
            else{
                objectQuestion["selected"]  = true
                waiver_data["answer"]       = answer
                objectQuestion["data"]      = waiver_data
                self.arrayWaiverQuestion[indexWaiver] = objectQuestion
                self.tblWaiver.reloadData()
                alertController.dismiss(animated: false, completion: nil)
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.placeholder = placeholder
           
            objectQuestion["selected"]  = false
            waiver_data["answer"]       = ""
            objectQuestion["data"]      = waiver_data
            
            self.arrayWaiverQuestion[indexWaiver] = objectQuestion
            self.tblWaiver.reloadData()
            
            alertController.dismiss(animated: false, completion: nil)
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func showPopupForPregnancy(indexWaiver:Int){
        
        var index           = 0;
        var objectQuestion   = self.arrayWaiverQuestion[indexWaiver]
        var waiver_data      = objectQuestion["data"] as! Dictionary<String,Any>
        var waiver_message   = ""
        var arrayOption      = [Dictionary<String,Any>]()
        
        if(waiver_data.keys.contains("answer")){
            arrayOption = waiver_data["options"] as! [Dictionary<String,Any>]
        }
        if(waiver_data.keys.contains("message")){
            waiver_message = waiver_data["message"] as! String
        }
        
        let alertController = UIAlertController(title: "Waiver Question", message: waiver_message, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: arrayOption[0]["label"]as! String, style: .default, handler: { alert -> Void in
            self.showPregnancyDetails(position: indexWaiver,selectedOption:0)
        }))
        alertController.addAction(UIAlertAction(title: arrayOption[1]["label"]as! String, style: .default, handler: { alert -> Void in
            self.showPregnancyDetails(position: indexWaiver,selectedOption:1)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { alert -> Void in
            alertController.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func showPregnancyDetails(position:Int,selectedOption:Int){
        
        var objectQuestion     = self.arrayWaiverQuestion[position]
        var objectData         = objectQuestion["data"] as! Dictionary<String,Any>
        var arrayOption        = objectData["options"] as! [Dictionary<String,Any>]
        
        var question_message   = arrayOption[selectedOption]["message"] as! String
        var question_submsg    = ""
        
        objectData["selected_option"] = selectedOption
        if(arrayOption[selectedOption].keys.contains("submessage")){
            question_submsg = " \n\nPS: \(arrayOption[selectedOption]["submessage"] as! String)"
        }
        let alertController  = UIAlertController(title: "Inform Consent", message: question_message, preferredStyle: .alert)
        
        if(selectedOption == 0){
            question_message = "If you are a Doctor / OB-GYNE, please provide your License # (PRC) for validation. You must show the ID to the supervisor once youre at the branch.\(question_submsg)"
        }
        else{
            question_message = "\(question_message) \n\nPS: Please enter your License # below if your are only a doctor."
            alertController.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Enter PRC ID #:"
            })
        }
        
        alertController.message = question_message

        let saveAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { alert -> Void in
            let textField  = alertController.textFields![0] as UITextField
            let answer     = textField.text!
            if(answer == "" || textField.text!.isEmpty){
                return
            }
            else{
                var index = 0
                for rowOption in arrayOption{
                    if(index == selectedOption){
                        arrayOption[index]["textbox"] = true
                        arrayOption[index]["answer"]  = answer
                    }
                    else{
                        arrayOption[index]["textbox"] = false
                        arrayOption[index]["answer"]  = ""
                    }
                    index+=1
                }
                objectData["selected_option"]   = selectedOption
                objectData["options"]           = arrayOption
                objectQuestion["selected"]      = true
                objectQuestion["data"]          = objectData
                self.arrayWaiverQuestion[position] = objectQuestion
                self.tblWaiver.reloadData()
                alertController.dismiss(animated: false, completion: nil)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            (action : UIAlertAction!) -> Void in
            
            var index = 0
            for rowOption in arrayOption{
                arrayOption[index]["textbox"] = false
                arrayOption[index]["answer"]  = ""
                index+=1
            }
            
            objectData["selected_option"]   = 0
            objectData["options"]           = arrayOption
            objectQuestion["selected"]      = false
            objectQuestion["data"]          = objectData
            self.arrayWaiverQuestion[position] = objectQuestion
            self.tblWaiver.reloadData()
            
            alertController.dismiss(animated: true, completion: nil)
        })
        
        let confirmConsent = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: {
            (action : UIAlertAction!) -> Void in
            
            arrayOption[selectedOption]["textbox"] = true
            arrayOption[selectedOption]["answer"]  = "Yes, I have inform consent and I will present my inform consent."
            
            objectData["selected_option"]   = selectedOption
            objectData["options"]           = arrayOption
            objectQuestion["selected"]      = true
            objectQuestion["data"]          = objectData
            self.arrayWaiverQuestion[position] = objectQuestion
            self.tblWaiver.reloadData()
            
            alertController.dismiss(animated: true, completion: nil)
        })
        
        if(selectedOption == 0){
            alertController.addAction(confirmConsent)
        }
        else{
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
        }
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func validateAction(_ sender: Any) {
        
        objectWaiverData["signature"]    = ""
        objectWaiverData["strokes"]      = 0
        objectWaiverData["questions"]    = arrayWaiverQuestion
        objectAppointment["waiver_data"] = objectWaiverData
        
        if(ifHasMonthlyCycle == true){
            var arrayServices = objectAppointment["services"] as! [Dictionary<String,Any>]
            var index = 0
            for rows in arrayServices{
                let id = rows["id"] as! Int
                for restrictedRows in arrayDisabledServices{
                    let restricted_id = restrictedRows
                    if(restricted_id == id){
                        self.showDialog(title:"Service is not available.", message: "You cannot book the selected services when you are in monthly cycle")
                        break
                        return
                    }
                }
                if(index == arrayServices.count - 1){
                    nextAction()
                }
                index += 1
            }
        }
        else{
            nextAction()
        }
    }
    func nextAction(){
        
        self.dialogUtil.showActivityIndicator(self.view)
        
        let stringUrl   = self.SERVER_URL+"/api/appointment/addAppointment?token=\(self.utilities.getUserToken())"
        let url         = URL(string: stringUrl)!
        
        let jsonObjectString    = utilities.convertDictionaryToJSONString(dictionaryVal: self.objectAppointment)
        let jsonData            = utilities.convertJSONStringToData(arrayString: jsonObjectString)
        var request             = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let termsText = "I, \(utilities.getUserName()) of legal age, fully understood that the procedure's involves certain risks to my body, which includes scratches, pain, soreness, injury, sickness, irittation, or rash, etc., which may be present and/or after the procedure and I fully accept and assume such risk and responsibility for losses, cost, and damages I may occur. I hereby release and discharge LAY BARE WAXING SALON, its stockholders, directors, franchisees, officers and technicians from all liability, claims, damages, losses, arising from the services they have rendered into me. I acknowledge that I have read this Agreement and fully understand its terms and conditions.";
        
        let alertView   = UIAlertController(title: "Terms and Condition", message: termsText, preferredStyle: .alert)
        let confirm     = UIAlertAction(title: "Confirm", style: .default) { (action) in
            
            Alamofire.request(request)
                .responseJSON { response in
                    do{
                        self.dialogUtil.hideActivityIndicator(self.view)
                        guard let statusCode   = try response.response?.statusCode else {
                            self.dialogUtil.hideActivityIndicator(self.view)
                            self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                            return
                        }
                        if response.data != nil{
                            print("STATUS CODE: \(statusCode)")
                            if(statusCode == 200 || statusCode == 201){
                                let objectBranch    = self.objectAppointment["branch"] as! Dictionary<String,Any>
                                let branch_id       = objectBranch["value"] as! Int
                                self.webSocket.emit("refreshAppointments", branch_id)
                                self.finishAppointment()
                            }
                            else if statusCode == 401{
                                self.dialogUtil.hideActivityIndicator(self.view)
                                self.utilities.deleteAllData()
                                let mainStoryboard: UIStoryboard = UIStoryboard(name: "LoginStoryboard", bundle: nil)
                                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
                                viewController.isLoggedOut      = true
                                viewController.sessionExpired   = true
                                UIApplication.shared.keyWindow?.rootViewController = viewController
                            }
                            else{
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
                            self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                        }
                    }
                    catch{
                        print(response.error)
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                    }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            if(self.dialogUtil.activityIndicator.isHidden == false){
                self.dialogUtil.hideActivityIndicator(self.view)
            }
        }
        alertView.addAction(confirm)
        alertView.addAction(cancel)
        self.present(alertView,animated: true,completion: nil)
        
    }
    
    func finishAppointment(){
        //alert box
        let alertView = UIAlertController(title: "Succesfully Booked!", message: "You have successfully booked your appointment!", preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            self.webSocket.disconnect()
            self.navigationController?.popToRootViewController(animated: true);
        }
        alertView.addAction(confirm)
        self.present(alertView,animated: true,completion: nil)
    }
    
    
    
    
    

}
