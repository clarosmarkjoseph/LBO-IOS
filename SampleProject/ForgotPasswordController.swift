//
//  ForgotPasswordController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/4/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Alamofire

class ForgotPasswordController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtBday: UITextField!
    var pickerViewBday          = UIDatePicker()
    let dbclass     = DatabaseHelper()
    let utilities   = Utilities()
    let dialogUtil  = DialogUtility()
    var SERVER_URL  = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SERVER_URL = dbclass.returnIp()
        loadPickerDate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    @IBAction func submitForgotPassword(_ sender: Any) {
        if(txtEmail.text!.isEmpty){
            self.self.promptAndFocus(titles: "Missing required data", messages: "Please provide your first name", actions: txtEmail)
        }
        if(txtBday.text!.isEmpty){
            self.promptAndFocus(titles: "Missing required data", messages: "Please provide your last name", actions: txtBday)
        }
        else{
            self.dialogUtil.showActivityIndicator(self.view)
            let myURL = SERVER_URL+"/api/mobile/verifyMyPassword"
            let requestParams  = [
                "verify_email":txtEmail.text!,
                "verify_birth_date":txtBday.text!,
                ]
            
        Alamofire.request(myURL, method: .post, parameters: requestParams)
            .responseJSON { response in
                do{
                    self.dialogUtil.hideActivityIndicator(self.view)
                    guard let statusCode   = try response.response?.statusCode else { return }
                    let responseError    = response.error?.localizedDescription
                    
                    if let responseJSON = response.result.value{
                        var objectResponse            = responseJSON as! Dictionary<String,Any>
                        
                        if(statusCode == 200 || statusCode == 201){
                            let msgResult        = objectResponse["result"] as! String
                            self.showCompleted()
                            return
                        }
                        else{
                            let arrayError = self.utilities.handleHttpResponseError(objectResponseError: objectResponse,statusCode:statusCode)
                            self.self.promptAndFocus(titles: arrayError[0], messages: arrayError[1], actions: self.txtEmail)
                        }
                    }
                    else{
                        self.promptAndFocus(titles: "Error!", messages: "There was a problem connecting to Lay Bare App. Please check your connection and try again", actions: self.txtEmail)
                    }
                }
                catch{
                    self.dialogUtil.hideActivityIndicator(self.view)
                    self.promptAndFocus(titles: "Error!", messages: "There was a problem connecting to Lay Bare App. Please check your connection and try again", actions: self.txtEmail)
                }
            }
        }
    }
    
    func showCompleted(){
        
        var messageString = "Successfully verified your account! Please check your email for password reset"
        var messageTitle  = "Email Sent!"
        let alertView   = UIAlertController(title: messageTitle, message: messageString, preferredStyle: .alert)
        let confirm     = UIAlertAction(title: "Confirm", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertView.addAction(confirm)
        present(alertView,animated: true,completion: nil)
        
    }
    
    
    func promptAndFocus(titles:String, messages:String, actions:Any){
        
        let alertController = UIAlertController(title: titles, message: messages, preferredStyle: UIAlertControllerStyle.alert)
        let actionButton   = UIAlertAction(title: "Ok", style: .default){
            (action:UIAlertAction!) in
            if let checkTextField = actions as? UITextField{
                checkTextField.becomeFirstResponder()
            }
        }
        alertController.addAction(actionButton)
        self.present(alertController, animated: true, completion:nil)
    }
    
    
    @IBAction func closePopup(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
