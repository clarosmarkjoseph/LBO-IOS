//
//  UserProfileEditController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/21/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Alamofire
import SQLite

class UserProfileEditController: UIViewController,UITextFieldDelegate,ProtocolBranch{
   
   
    @IBOutlet var stackview: UIStackView!
    @IBOutlet var stackviewHomebranch: UIStackView!
    @IBOutlet var stackviewAccount: UIStackView!
    @IBOutlet var stackviewPersonal: UIStackView!
    @IBOutlet var lblCaption: UILabel!
    @IBOutlet var txtHomeBranch: UITextField!
    @IBOutlet var txtFirstName: UITextField!
    @IBOutlet var txtMiddleName: UITextField!
    @IBOutlet var txtLastName: UITextField!
    @IBOutlet var txtBday: UITextField!
    @IBOutlet var segmentGender: UISegmentedControl!
    @IBOutlet var txtAddress: UITextField!
    @IBOutlet var txtContact: UITextField!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtOldPassword: UITextField!
    @IBOutlet var txtNewPassword: UITextField!
    @IBOutlet var txtConfirmPassword: UITextField!
    var arrayParamLabel:[String]?    = nil
    var arrayParamAnswer:[String]?   = nil
    var indexPosition   = 0
    var SERVER_URL      = ""
    let utilities       = Utilities()
    let dbclass         = DatabaseHelper()
    var objectUserAccount:ObjectUserAccount? = nil
    
    var stringUserAccount       = ""
    var pickerViewBranch        = UIPickerView()
    var pickerViewBday          = UIDatePicker()
    var token                   = ""
    var client_home_branch      = 0
    var client_bday             = ""
    var client_gender           = ""
    let dialogUtil              = DialogUtility()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtEmail.delegate           = self
        txtContact.delegate         = self
        txtAddress.delegate         = self
        txtBday.delegate            = self
        txtLastName.delegate        = self
        txtFirstName.delegate       = self
        txtMiddleName.delegate      = self
        txtNewPassword.delegate     = self
        txtOldPassword.delegate     = self
        txtConfirmPassword.delegate = self
        SERVER_URL                  = dbclass.returnIp()
        token                       = utilities.getUserToken()
        loadDetails()
    }
    
    func loadDetails(){
        var captionMessage = ""
        
        let user_tbl            = dbclass.user_tbl
        do{
            if let queryUser   = try dbclass.db?.pluck(user_tbl){
                let stringObject        = queryUser[dbclass.user_object_data]
                stringUserAccount       = stringObject
                let jsonData            = stringObject.data(using: .utf8)
                objectUserAccount       = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                
                if(indexPosition == 0){
                    
                    stackviewHomebranch.isHidden = false
                    captionMessage = "Select your home branch below.\nPlease choose your preffered Lay Bare home branch."
                    let clientData          = try objectUserAccount?.user_data ?? "{}"
                    let objectUserData      = utilities.convertJSONStringToData(arrayString: clientData)
                    let objectUserDecoded   = try JSONDecoder().decode(ObjectUserData.self, from: objectUserData)
                    let clientBranchID      = try objectUserDecoded.home_branch ?? 0
                    let clientBranchName    = utilities.getBranchName(branch_id: clientBranchID)
                    client_home_branch      = clientBranchID
                    txtHomeBranch.text      = clientBranchName
                    txtHomeBranch.addTarget(self, action: #selector(showBranches), for: UIControlEvents.editingDidBegin)

                }
                else if(indexPosition == 1){
                    stackviewPersonal.isHidden = false
                    captionMessage = "Your complete personal information will help ensure the accuracy of your transactional data."
                    let clientFname     = try objectUserAccount?.first_name ?? ""
                    let clientMname     = try objectUserAccount?.middle_name ?? ""
                    let clientLname     = try objectUserAccount?.last_name ?? ""
                    let clientAddress   = try objectUserAccount?.user_address ?? ""
                    let clientMobile    = try objectUserAccount?.user_mobile ?? ""
                    let clientGender    = try objectUserAccount?.gender ?? ""
                    let clientBday      = try objectUserAccount?.birth_date ?? "0000-00-00"
                    client_gender       = clientGender
                    client_bday         = clientBday
                    txtFirstName.text   = clientFname
                    txtMiddleName.text  = clientMname
                    txtLastName.text    = clientLname
                    txtAddress.text     = clientAddress
                    txtContact.text     = clientMobile
                    txtBday.text        = clientBday
                    if(clientGender.lowercased() == "male"){
                        segmentGender.selectedSegmentIndex = 1
                    }
                    else{
                        segmentGender.selectedSegmentIndex = 0
                    }
                    loadPickerDate()
                    pickerViewBday.setDate(utilities.convertStringToDate(stringDate: clientBday), animated: true)
                }
                else if(indexPosition == 2){
                    stackviewAccount.isHidden = false
                    captionMessage = "Account Details\nPlease provide your information including your old password to make sure you can change it."
                    let clientEmail         = try objectUserAccount?.email ?? ""
                    txtEmail.text           = clientEmail
                }
            }
            else{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        catch{
            print("User retrieve error: \(error)")
        }
        lblCaption.text = captionMessage
    }
    


    
    @objc func showBranches(){
        txtHomeBranch.resignFirstResponder()
        let viewController = UIStoryboard(name: "OtherStoryboard", bundle: nil).instantiateViewController(withIdentifier: "BranchController") as? BranchController
        viewController?.ifAppointment   = false
        viewController?.delegate        = self
        present(viewController!, animated: true,completion: nil)
        
    }
    

    
    func setBranch(selectedBranch: String, selectedBranchID: Int, objectSelectedBranch: ArrayBranch,arrayIndex: Int) {
        client_home_branch = selectedBranchID
        txtHomeBranch.text = selectedBranch
    }
    
    
    func loadPickerDate(){
        let toolbarBday = UIToolbar()
        toolbarBday.sizeToFit()
        
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let btnDone  = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: nil, action: #selector(doneBday))
        let btnCancel   = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelPicker))
        toolbarBday.setItems([btnCancel,flexible,btnDone], animated: false)
        
        txtBday.inputAccessoryView = toolbarBday
        txtBday.inputView = pickerViewBday
        
        //formatter
        pickerViewBday.datePickerMode   = .date
        pickerViewBday.maximumDate      = Date()
        
        
    }
    
    @objc func cancelPicker(){
        self.view.endEditing(true)
    }
    
    @objc func doneBday(){
        let myFormatter         = DateFormatter()
        myFormatter.dateFormat  = "yyyy-MM-dd"
        let date_selected       = myFormatter.string(from: pickerViewBday.date)
        client_bday             = date_selected
        txtBday.text            = client_bday
        self.view.endEditing(true)
    }
    
    
    @IBAction func btnSaveOnclick(_ sender: Any) {
        validateProfile()
    }
    
    func validateProfile(){
        var requestParams: Parameters = ["":""]
        var updateUrl = ""
        let clientID  = utilities.getUserID()
        if(indexPosition == 0){
            if(client_home_branch <= 0){
                self.showDialog(title: "Incomplete Details", message: "Please choose your Home Branch",ifExit: false)
                return
            }
            else{
                updateUrl = SERVER_URL+"/api/mobile/updateHomeBranch?token="+token
                requestParams = [
                    "edit_home_branch_id":client_home_branch,
                    "edit_home_branch":txtHomeBranch.text!,
                    "edit_client_id":clientID
                ]
                updateProfile(requestParams:requestParams, updateUrl: updateUrl)
            }
        }
        if(indexPosition == 1){
            
            let first_name  = txtFirstName.text!
            let last_name   = txtLastName.text!
            let middle_name = txtMiddleName.text!
            let address     = txtAddress.text!
            let contact     = txtContact.text!
            client_bday     = txtBday.text!
            
            if(first_name == "" || first_name.isEmpty == true){
                self.showDialog(title: "Incomplete Details", message: "Please provide your first name",ifExit: false)
                return
            }
            if(last_name == "" || last_name.isEmpty == true){
                self.showDialog(title: "Incomplete Details", message: "Please provide your last name",ifExit: false)
                return
            }
            if(client_bday == ""){
                self.showDialog(title: "Incomplete Details", message: "Please provide your birthdate",ifExit: false)
                return
            }
            if(utilities.calculateAge(birthday: client_bday) <= 13){
                self.showDialog(title: "Underage?", message: "Registration failed, You must be 13 y/o of age above.",ifExit: false)
                return
            }
            if(address == "" || address.isEmpty == true){
                self.showDialog(title: "Incomplete Details", message: "Please provide your address",ifExit: false)
                return
            }
            if(contact == "" || contact.isEmpty == true){
                self.showDialog(title: "Incomplete Details", message: "Please provide your Mobile No.",ifExit: false)
                return
            }
            else{
                updateUrl = SERVER_URL+"/api/mobile/updatePersonalInfo?token="+token
                requestParams = [
                    "edit_client_id":clientID,
                    "edit_fname":first_name,
                    "edit_mname":middle_name,
                    "edit_lname":last_name,
                    "edit_address":address,
                    "edit_contact":contact,
                    "edit_bday":client_bday,
                    "edit_gender":client_gender.lowercased()
                ]
                updateProfile(requestParams:requestParams, updateUrl: updateUrl)
            }
        }
        if(indexPosition == 2){
            
            let email               = txtEmail.text!
            let old_password        = txtOldPassword.text!
            let new_password        = txtNewPassword.text!
            let confirm_password    = txtConfirmPassword.text!
//            if(email == "" || email.isEmpty == true){
//                self.showDialog(title: "Incomplete Details!", message: "Please provide your email address",ifExit: false)
//                return
//            }
//            if(utilities.isValidEmail(testStr: email)){
//                self.showDialog(title: "Invalid Email!", message: "Please provide your valid email address",ifExit: false)
//                return
//            }
            if(new_password.count < 10){
                self.showDialog(title: "Password too short!", message: "Please provide atleast 10 alphanumeric password.",ifExit: false)
                return
            }
            if(utilities.checkIfAlphaNumeric(password: new_password) == false){
                self.showDialog(title: "Password too weak!", message: "Please provide atleast 10 alphanumeric password.",ifExit: false)
                return
            }
            if(new_password != confirm_password){
                self.showDialog(title: "Password doesn't match!", message: "Your new password and confirm password doesn't match!",ifExit: false)
                return
            }
            else{
                updateUrl = SERVER_URL+"/api/mobile/updateAccount?token="+token
                requestParams = [
                    "edit_email":email,
                    "edit_old_password":old_password,
                    "edit_new_password":new_password,
                    "edit_confirm_password":confirm_password,
                    "edit_client_id":clientID
                ]
                updateProfile(requestParams:requestParams,updateUrl: updateUrl)
            }
        }
    }
    
    func updateProfile(requestParams:Parameters,updateUrl:String){
        
        self.dialogUtil.showActivityIndicator(self.view)
        Alamofire.request(updateUrl, method: .post, parameters: requestParams)
            .responseJSON { response in
                do{
                    self.dialogUtil.hideActivityIndicator(self.view)
                    guard let statusCode   = try response.response?.statusCode else {
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again", ifExit: false)
                        return
                    }
                    
                    if let responseJSON = response.result.value{
                        var objectResponse            = responseJSON as! Dictionary<String,Any>
                        
                        if(statusCode == 200 || statusCode == 201){
                           //success
                            self.updateLocalProfile()
                        }
                        else if(statusCode == 401){
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
                                self.showDialog(title:arrayError[0], message: arrayError[1], ifExit: false)
                            }
                            else{
                                self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again", ifExit: false)
                            }
                        }
                    }
                    else{
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again", ifExit: false)
                    }
                }
                catch{
                    self.dialogUtil.hideActivityIndicator(self.view)
                    self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again", ifExit: false)
                }
        }
    }
    
    
    
    func showDialog(title:String,message:String,ifExit:Bool){
        //alert box
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            if(ifExit == true){
                self.navigationController?.popViewController(animated: true)
            }
        }
        alertView.addAction(confirm)
        present(alertView,animated: true,completion: nil)
    }
    
    
    func updateLocalProfile(){
        if(self.indexPosition == 0){
            
            do{
                let objectUserString                = try objectUserAccount?.user_data ?? "{}"
                var objectUserData                  = utilities.convertJSONStringToData(arrayString: objectUserString)
                var objectUserDataDecoded           = try JSONDecoder().decode(ObjectUserData.self, from: objectUserData)
            
                objectUserDataDecoded.home_branch   = client_home_branch
                objectUserData                      = try JSONEncoder().encode(objectUserDataDecoded)
                let resultString                    = String(data: objectUserData, encoding: .utf8)!
                objectUserAccount?.user_data        = resultString
                let jsonResultEncoded               = try JSONEncoder().encode(objectUserAccount)
                let jsonResultString                = String(data: jsonResultEncoded, encoding: .utf8)!
                
                dbclass.updateUserObject(jsonString:jsonResultString, date_updated: self.utilities.getCurrentDateTime(ifDateOrTime: "datetime"))
                self.showDialog(title: "Success!", message: "You have successfully update your home Branch!", ifExit: true)
            }
            catch{
                print("error updating home_branch: \(error)")
            }
        }
        if(self.indexPosition == 1){
            do{
                let username                        = "\(txtFirstName.text!) \(txtLastName.text!)"
                let id                              = objectUserAccount?.id
                objectUserAccount?.first_name       = txtFirstName.text!
                objectUserAccount?.middle_name      = txtMiddleName.text!
                objectUserAccount?.last_name        = txtLastName.text!
                objectUserAccount?.username         = username
                objectUserAccount?.user_address     = txtAddress.text!
                objectUserAccount?.user_mobile      = txtContact.text!
                objectUserAccount?.birth_date       = client_bday
                let jsonResultEncoded               = try JSONEncoder().encode(objectUserAccount)
                let jsonResultString                = String(data: jsonResultEncoded, encoding: .utf8)!
                dbclass.updateUserProfile(id: id!, name: username,token: utilities.getUserToken(), object_data: jsonResultString, date_updated: self.utilities.getCurrentDateTime(ifDateOrTime: "datetime"))
                self.showDialog(title: "Success!", message: "You have successfully update your personal details!", ifExit: true)
            }
            catch{
                print("error updating personal profile: \(error)")
            }
            
        }
        if(self.indexPosition == 2){
             self.showDialog(title: "Success!", message: "You have successfully updated your personal details!", ifExit: true)
        }
    }
    
    //textfield ontouch anywhere to hide keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    
    
    
}
