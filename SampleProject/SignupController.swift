//
//  SignupController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 5/29/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Alamofire
import PopupDialog

protocol ProtocolForSignup {
    func setupAgreement(isAgreed:Bool);
}

class SignupController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate,ProtocolForSignup{
    
    @IBOutlet weak var txtFname: UITextField!
    @IBOutlet weak var txtMname: UITextField!
    @IBOutlet weak var txtLname: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtBday: UITextField!
    @IBOutlet weak var segmentGender: UISegmentedControl!
    @IBOutlet weak var txtContact: UITextField!
    @IBOutlet weak var txtBranch: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnTerms: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    let dialogUtil              = DialogUtility()
    let dbclass                 = DatabaseHelper()
    let utilities               = Utilities()
    var arrayBranch:[String]    = []
    var arrayBranchID:[Int]     = []
    var pickerViewBranch        = UIPickerView()
    var pickerViewBday          = UIDatePicker()
    var SERVER_URL              = ""
    var stringTerms             = ""
    var ifTermsAgree            = false
    var deviceID                = ""
    let device                  = "IOS"
    let devicetype              = UIDevice.current.modelName
    var fbID                    = ""
    var fbFname                 = ""
    var fbLname                 = ""
    var fbBday                  = ""
    var fbImage                 = ""
    var fbGender                = ""
    var fbEmail                 = ""
    var branchID                = 0
    var paramsFacebook:Parameters = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtFname.delegate       = self
        txtMname.delegate       = self
        txtLname.delegate       = self
        txtAddress.delegate     = self
        txtBday.delegate        = self
        txtContact.delegate     = self
        txtBranch.delegate      = self
        txtEmail.delegate       = self
        txtPassword.delegate    = self
        txtConfirmPassword.delegate = self
        if let device_id =  UIDevice.current.identifierForVendor?.uuidString{
            deviceID = device_id
        }
        else{
            deviceID = "N/A"
        }
        SERVER_URL = dbclass.returnIp()
        getTerms()
        loadPickerDate()
        loadBranch()
        
        if(!paramsFacebook.isEmpty){
            fbID        = paramsFacebook["fb_id"] as! String
            fbFname     = paramsFacebook["fb_fname"] as! String
            fbLname     = paramsFacebook["fb_lname"] as! String
            fbBday      = paramsFacebook["fb_bday"] as! String
            fbImage     = paramsFacebook["fb_image"] as! String
            fbGender    = paramsFacebook["fb_gender"] as! String
            fbEmail     = paramsFacebook["fb_email"] as! String
            branchID    = 0
            txtFname.text = fbFname
            txtLname.text = fbLname
            txtEmail.text = fbEmail
            if fbGender == "male"{
                segmentGender.selectedSegmentIndex = 1
            }
            else{
                segmentGender.selectedSegmentIndex = 0
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateBday = dateFormatter.date(from: fbBday)
            let dateBdayString  = dateFormatter.string(from: dateBday!)
            txtBday.text        = dateBdayString
            self.showDialog(title: "Welcome to Lay Bare Registration", message: "Hello, you've just logged-in via facebook. Please register to continue using the platform")
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text  = textField.text else { return true }
        let newLength   = text.characters.count + string.characters.count - range.length
        if(textField == txtContact){
            return newLength <= 10 // Bool
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if ((textField == txtContact ) || (textField == txtBranch) || (textField == txtEmail) || (textField == txtPassword) || (textField == txtConfirmPassword) ){
            animateViewMoving(up: true, moveValue: 200)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if ((textField == txtContact ) || (textField == txtBranch) || (textField == txtEmail) || (textField == txtPassword) || (textField == txtConfirmPassword) ){
           animateViewMoving(up: false, moveValue: 200)
        }
    }

    
    func animateViewMoving(up:Bool, moveValue :CGFloat){
      
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    
    }
    
    //textfield ontouch anywhere to hide keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        textField.resignFirstResponder()
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        }
        return true
    }
    
    func getTerms(){
        
        let terms_tbl = dbclass.terms_tbl
        do{
            if let queryTerms = try dbclass.db?.pluck(terms_tbl) {
                stringTerms = queryTerms[dbclass.terms_data]
            }
            else{
                let termUrl    = SERVER_URL+"/api/config/getTerms"
                let requestParams: Parameters = ["":""]
                Alamofire.request(termUrl, method: .get, parameters: requestParams)
                    .responseString { response in
                        do{
                            guard let statusCode   = try response.response?.statusCode else {
                                self.dialogUtil.hideActivityIndicator(self.view)
                                self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                                return
                            }
                            self.dialogUtil.hideActivityIndicator(self.view)
                            
                            if(statusCode == 200 || statusCode == 201){
                                self.stringTerms = response.value!
                                self.dbclass.insertTerms(terms_string: self.stringTerms)
                            }
                            else{
                                 self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                            }
                        }
                        catch{
                            print("Error1: \(response.error)")
                            self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                        }
                }
            }
        }
        catch{
            print("ERROR DB SERVICE \(error)")
        }
    }

    func loadBranch(){
        dialogUtil.showActivityIndicator(self.view)
        let branch_tbl            = dbclass.branch_tbl
        do{
            if let queryBranch          = try dbclass.db?.pluck(branch_tbl){
                var stringBranch        = queryBranch[dbclass.branch_array]
                let jsonData            = stringBranch.data(using: .utf8)
                let resultBranch        = try JSONDecoder().decode([ArrayBranch].self, from: jsonData!)
                for row in resultBranch{
                    arrayBranch.append(row.branch_name!)
                    arrayBranchID.append(row.id!)
                }
            }
        }
        catch{
            print("ERROR retrieving Image: \(error)")
        }
        
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let btnDone  = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: nil, action: #selector(doneBranch))
        let btnCancel   = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelBranch))
        let toolbarBranch = UIToolbar()
        toolbarBranch.sizeToFit()
        toolbarBranch.setItems([btnCancel,flexible,btnDone], animated: false)
        
        pickerViewBranch.delegate     = self
        pickerViewBranch.dataSource   = self
        txtBranch.inputAccessoryView = toolbarBranch
        txtBranch.inputView          = pickerViewBranch
        txtBranch.textAlignment = .justified
        txtBranch.placeholder   = "Select Home Branch"
        dialogUtil.hideActivityIndicator(self.view)

    }
    
    func loadPickerDate(){
        let toolbarBday = UIToolbar()
        toolbarBday.sizeToFit()

        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let btnDone  = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: nil, action: #selector(doneBday))
        let btnCancel   = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        toolbarBday.setItems([btnCancel,flexible,btnDone], animated: false)
        
        txtBday.inputAccessoryView = toolbarBday
        txtBday.inputView = pickerViewBday
        
        //formatter
        pickerViewBday.datePickerMode   = .date
        pickerViewBday.maximumDate      = Date()

    }
    
    @objc func doneBday(){
        let myFormatter         = DateFormatter()
        myFormatter.dateFormat  = "yyyy-MM-dd"
        let date_selected       = myFormatter.string(from: pickerViewBday.date)
        txtBday.text            = "\(date_selected)"
        self.view.endEditing(true)
    }
    
    @objc func doneBranch(){
         self.view.endEditing(true)
    }
    
    @objc func cancelBranch(){
        txtBranch.text  = ""
        branchID        = 0
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return arrayBranch.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        branchID = arrayBranchID[row]
        return arrayBranch[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtBranch.text = arrayBranch[row]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "segueTerms"){
            let modalVC:TermConditionViewController = segue.destination as! TermConditionViewController
            modalVC.stringTerms     = self.stringTerms
            modalVC.ifTermsAgreed   = self.ifTermsAgree
            modalVC.delegate        = self
        }
        
        
    }
    
    func setupAgreement(isAgreed: Bool) {
        if(isAgreed == true){
            btnRegister.isEnabled = true
            btnRegister.alpha = 1.0
        }
        else{
            btnRegister.isEnabled = false
            btnRegister.alpha = 0.7
        }
    }

    
    @IBAction func registerUser(_ sender: Any) {
        
        var regStatus   = ""
        var strResponse = ""
        let email = txtEmail.text!
        
        if(txtFname.text!.isEmpty){
            self.promptAndFocus(titles: "Missing required data", messages: "Please provide your first name", actions: txtFname)
        }
        else if(txtFname.text!.isEmpty){
            promptAndFocus(titles: "Missing required data", messages: "Please provide your last name", actions: txtLname)
        }
        else if(txtAddress.text!.isEmpty){
            promptAndFocus(titles: "Missing required data", messages: "Please provide your address", actions: txtAddress)
        }
        else if(txtContact.text!.isEmpty) {
            promptAndFocus(titles: "Missing required data", messages: "Please provide your contact number", actions: txtContact)
        }
        else if(txtContact.text!.count < 10) {
            promptAndFocus(titles: "Invalid Contact no", messages: "Please enter your valid phone no.", actions: txtContact)
        }
        else if(txtBday.text!.isEmpty){
            promptAndFocus(titles: "Missing required data", messages: "Please provide your birth date", actions: txtBday)
        }
        else if(utilities.calculateAge(birthday: txtBday.text!) < 13){
            promptAndFocus(titles: "Underage?", messages: "Registration failed, You must be 13 y/o of age to register.", actions: txtBday)
        }
        else if(txtBranch.text!.isEmpty){
            promptAndFocus(titles: "Missing required data", messages: "Please select your home branch", actions:txtBranch)
        }
        else if(txtEmail.text!.isEmpty){
            promptAndFocus(titles: "Missing required data", messages: "Please provide your valid email address", actions: txtEmail)
        }
        else if(utilities.isValidEmail(testStr: email) == false){
            promptAndFocus(titles: "Missing required data", messages: "Please provide your valid email address", actions: txtEmail)
        }
        else if(txtPassword.text!.isEmpty){
            promptAndFocus(titles: "Missing required data", messages: "Please provide your account password", actions: txtPassword)
        }
        else if(utilities.checkIfAlphaNumeric(password: txtPassword.text!) == false){
            promptAndFocus(titles: "Missing required data", messages: "Password must contain 9 alphanumeric", actions: txtPassword)
        }
        else if(txtConfirmPassword.text!.isEmpty){
            promptAndFocus(titles: "Missing required data", messages: "Please confirm your password", actions: txtConfirmPassword)
        }
        else if(txtPassword.text! != txtConfirmPassword.text!){
            promptAndFocus(titles: "Password verification", messages: "Your password doesn't match. Please try again", actions: txtPassword)
        }
        else if (txtPassword.text?.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil || (txtPassword.text?.characters.count)! <= 9 ){
            promptAndFocus(titles: "Password verification", messages: "Password must contain more than 9 numbers or digits", actions: txtPassword)
        }
        else{
            
            let gender      = segmentGender.titleForSegment(at: segmentGender.selectedSegmentIndex)!
            let contactNo   = "+63\(txtContact.text!)"
            self.dialogUtil.showActivityIndicator(self.view)
            let myURL = SERVER_URL+"/api/mobile/registerUser"
            let requestParams: Parameters = [
                "addEmail":txtEmail.text!,
                "addFname":txtFname.text!,
                "addMname":txtMname.text!,
                "addLname":txtLname.text!,
                "addAddress":txtAddress.text!,
                "addMobile":contactNo,
                "addBday":txtBday.text!,
                "addGender":gender,
                "addPassword":txtPassword.text!,
                "addBranch":branchID,
                "addBossID":0,
                "addBossArray":"[]",
                "addDevice":device,
                "addFBID":fbID,
                "addImageUrl":fbImage,
                "addDeviceName":devicetype,
                "addUniqueID":deviceID,
                ]

            Alamofire.request(myURL, method: .post, parameters: requestParams)
                .responseJSON { response in
                    do{
                        self.dialogUtil.hideActivityIndicator(self.view)
                        guard let statusCode   = try response.response?.statusCode else {
                            self.dialogUtil.hideActivityIndicator(self.view)
                            self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                            return
                        }
                        if response.data != nil{
                            if(statusCode == 200 || statusCode == 201){
                                self.dialogUtil.hideActivityIndicator(self.view)
                                let objectResponse   = response.result.value as! Dictionary<String,Any>
                                let msgResult        = objectResponse["result"] as! String
                                let isFacebook       = objectResponse["isFacebook"] as! Bool
                                self.showCompleteRegistration(isFacebook:isFacebook,objectResponse:objectResponse)
                                return
                            }
                            else{
                                self.dialogUtil.hideActivityIndicator(self.view)
                                let objectResponse = response.result.value as! Dictionary<String,Any>
                                if(response.result.value != nil){
                                    let arrayError = self.utilities.handleHttpResponseError(objectResponseError: objectResponse,statusCode:statusCode)
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
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                    }
            }
        }
    }
    
    func showCompleteRegistration(isFacebook:Bool,objectResponse:Dictionary<String,Any>){
        
        var messageString = ""
        var messageTitle  = ""
        if(isFacebook == true){
            messageTitle  = "Registration Complete"
            messageString = "You are now registered to Lay Bare Online via Facebook Login! Enjoy our Services / Products and our promos. You may use this app to book your appointments and to view your transactions. Enjoy booking!"
            let resImage        = objectResponse["image"] as! String
            let resToken        = objectResponse["token"] as! String
            let resClientID     = objectResponse["client_id"] as! Int
            let resObjectData   = objectResponse["client_data"] as! Dictionary<String,Any>
            
            dbclass.insertUserAccount(id: resClientID, name: txtFname.text!+" "+txtLname.text!, email: txtEmail.text!, token: resToken, object_data: resObjectData, date_updated: self.utilities.getCurrentDateTime(ifDateOrTime: "datetime"))
            
            let alertView   = UIAlertController(title: messageTitle, message: messageString, preferredStyle: .alert)
            let confirm     = UIAlertAction(title: "Confirm", style: .default) { (action) in
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "MenuTabBarController") as! MenuTabBarController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
            alertView.addAction(confirm)
            present(alertView,animated: true,completion: nil)
        }
        else{
            messageTitle  = "Registration Complete"
            messageString = "You are now registered to Lay Bare Online! Please verify your account via activating the link that we sent to you on your Email.  Enjoy our Services / Products and our promos. You may use this app to book your appointments and to view your transactions. Enjoy booking!"
            let alertView   = UIAlertController(title: messageTitle, message: messageString, preferredStyle: .alert)
            let confirm     = UIAlertAction(title: "Confirm", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alertView.addAction(confirm)
            present(alertView,animated: true,completion: nil)
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
    
    
    func promptAndFocus(titles:String, messages:String, actions:UITextField){
        let alertController = UIAlertController(title: titles, message: messages, preferredStyle: UIAlertControllerStyle.alert)
        let actionButton   = UIAlertAction(title: "Ok", style: .default){
                (action:UIAlertAction!) in
            if(actions != nil){
                actions.becomeFirstResponder()
            }
        }
        alertController.addAction(actionButton)
        self.present(alertController, animated: true, completion:nil)
    
    }
    

    @IBAction func btnBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    

}
