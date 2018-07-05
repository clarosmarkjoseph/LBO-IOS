//
//  LoginController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 5/28/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Alamofire
import SQLite


class LoginController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!

    let utilities  = Utilities()
    let dbclass    = DatabaseHelper()
    let dialogUtil = DialogUtility()
    var SERVER_URL = ""
    var deviceID   = ""
    let device     = "IOS"
    let devicetype = UIDevice.current.modelName
    var attempts   = 0
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SERVER_URL = dbclass.returnIp()
        if let device_id =  UIDevice.current.identifierForVendor?.uuidString{
            deviceID = device_id
        }
        else{
            deviceID = "N/A"
        }
    }

    

    @IBAction func btnSubmit(_ sender: Any) {
        let email    = txtEmail.text!
        let password = txtPassword.text!
        if email.isEmpty == true {
            //alert box
            showDialog(title: "Incomplete Details",message: "Please enter your email address")
        }
//        if utilities.isValidEmail(testStr: email) == false {
//            showDialog(title: "Invalid Input",message: "Email address is not valid")
//        }
        if password.isEmpty == true {
            showDialog(title: "Incomplete Details",message: "Please enter your password")
        }
        else{
            loginUser(email: email,password: password)
        }
        print("Email Address: \(email)")
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        if let viewController = UIStoryboard(name: "LoginStoryboard", bundle: nil).instantiateViewController(withIdentifier: "SignupController") as? SignupController {
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
    
    @IBAction func btnClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loginUser(email:String,password:String){
        
        dialogUtil.showActivityIndicator(self.view)
        var myUrlString = SERVER_URL+"/api/mobile/loginUser";
        // Alamofire 4
        let requestParams: Parameters = [
                        "attempts":attempts,
                        "email":email,
                        "password":password,
                        "device":device,
                        "device_info":devicetype,
                        "unique_device_id":deviceID,
                        ]
        Alamofire.request(myUrlString, method: .post, parameters: requestParams)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else { return }
                    let responseError    = response.error?.localizedDescription
                    if let responseJSON = response.result.value{
                        var objectResponse            = responseJSON as! Dictionary<String,Any>
                        
                        if(statusCode == 200 || statusCode == 201){
                            let token        = objectResponse["token"] as! String
                            let result       = objectResponse["result"] as! String
                            let users_data   = objectResponse["users_data"] as! Dictionary<String,Any>
                            let transactions = objectResponse["transactions"] as! Dictionary<String,Any>
                            
                            let client_id    = users_data["id"] as! Int
                            let client_name  = users_data["username"] as! String
                            let client_email = users_data["email"] as! String
                            let date_loaded  = self.utilities.getCurrentDateTime(ifDateOrTime: "datetime")
                            print("Date Loaded: \(date_loaded)")
                            self.dbclass.insertUserAccount(id: client_id, name: client_name, email: client_email, token: token, object_data: users_data, date_updated: date_loaded)
                            
                            self.dialogUtil.hideActivityIndicator(self.view)
                            
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "MenuTabBarController") as! MenuTabBarController
                            UIApplication.shared.keyWindow?.rootViewController = viewController
                            
                            return
                        }
                        if(statusCode == 401){
                            //token expired
                            self.dialogUtil.hideActivityIndicator(self.view)
                            let errorMessage = objectResponse["error"] as! String
                            self.showDialog(title: "Error!", message: errorMessage)
                        }
                        else{
                            self.dialogUtil.hideActivityIndicator(self.view)
                            let errorMessage = objectResponse["error"] as! String
                            self.showDialog(title: "Error!", message: errorMessage)
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
    
    func showDialog(title:String,message:String){
        //alert box
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            
        }

        alertView.addAction(confirm)
        present(alertView,animated: true,completion: nil)
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
