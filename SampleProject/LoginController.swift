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
import FBSDKCoreKit
import FBSDKLoginKit

class LoginController: UIViewController,UITextFieldDelegate,FBSDKLoginButtonDelegate {
   
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet var btnFBLogin: FBSDKLoginButton!
    
    var isLoggedOut = false
    let utilities   = Utilities()
    let dbclass     = DatabaseHelper()
    let dialogUtil  = DialogUtility()
    var SERVER_URL  = ""
    var deviceID    = ""
    let device      = "IOS"
    let devicetype  = UIDevice.current.modelName
    var attempts    = 0
    var sessionExpired:Bool!
    let loginManager = FBSDKLoginManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SERVER_URL = dbclass.returnIp()
        btnFBLogin.readPermissions  = ["public_profile","email"]
        btnFBLogin.delegate         = self

        if let device_id =  UIDevice.current.identifierForVendor?.uuidString{
            deviceID = device_id
        }
        else{
            deviceID = "N/A"
        }
        txtEmail.delegate       = self
        txtPassword.delegate    = self
        
        print("SESSION EXPIRED: \(sessionExpired)")
        if(sessionExpired == nil){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showDialog(title: "Session Expired!", message: "Sorry, your token session with the app is expired. Please login again")
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        logoutFacebook()
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
       
        if error != nil{
            self.showDialog(title: "Error", message: error.localizedDescription)
        }
        else if result.isCancelled{
            self.showDialog(title: "Login Cancelled", message: "You just cancelled Facebook Login")
        }
        else{
            
            let grantedPermission   = result.grantedPermissions
            let declinedPermission  = result.declinedPermissions
            let accessTokenString   = result.token.tokenString
            if grantedPermission?.contains("email") == false{
                self.showDialog(title: "Email is required!", message: "Sorry, we need you to grant the permission of email address. This will determine your transaction's history")
                self.logoutFacebook()
            }
            else{
                 self.getUserInfo(accessToken: accessTokenString!)
            }
        }
    }
    
    func logoutFacebook() {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        self.showDialog(title: "Logout User", message: "Logout User!")
    }
    
    func getUserInfo(accessToken:String){
        self.dialogUtil.showActivityIndicator(self.view)
        let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id,email,gender,birthday,picture.width(480).height(480),first_name,last_name"], tokenString: accessToken, version: nil, httpMethod: "GET")
        request?.start(completionHandler: { (connection, result, error ) -> Void in
           
            if(error != nil){
                self.dialogUtil.hideActivityIndicator(self.view)
                self.showDialog(title: "Error", message: "\(error)" )
            }
            else{
                print("User Result: \(result)")
                self.checkFacebookAccount(result: result)
            }
        })
    }
    
    func checkFacebookAccount(result:Any){
        do{
            let objectResult        = result as! Dictionary<String,Any>
            let fb_id               = objectResult["id"] as! String
            let fb_bday             = objectResult["birthday"] ?? "0000-00-00"
            let fb_gender           = objectResult["gender"] as? String ?? ""
            let fb_email            = objectResult["email"]  as? String ?? ""
            let objectPicture       = objectResult["picture"] as! Dictionary<String,Any>
            let objectPictureData   = objectPicture["data"] as! Dictionary<String,Any>
            let fb_picture          = objectPictureData["url"] as! String
            let fb_fname            = objectResult["first_name"] as! String
            let fb_lname            = objectResult["last_name"]as! String
            
            let requestParams: Parameters = [
                "fb_id":fb_id,
                "fb_email":fb_email,
                "fb_bday":fb_bday,
                "fb_fname":fb_fname,
                "fb_lname":fb_lname,
                "fb_gender":fb_gender,
                "fb_image":fb_picture,
                "device":device,
                "device_info":devicetype,
                "unique_device_id":deviceID
            ]
            self.validateFacebookFromServer(requestParams: requestParams)
        }
        catch{
            print(error)
        }
    }
    
    func validateFacebookFromServer(requestParams:Parameters){
        let myUrlString = SERVER_URL+"/api/mobile/FacebookLogin";
        print(requestParams)
        // Alamofire 4
        Alamofire.request(myUrlString, method: .post, parameters: requestParams)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                        self.logoutFacebook()
                        return
                    }
                    print("error code FB: \(statusCode)")
                    if let responseJSON = response.result.value{
                        var objectResponse            = responseJSON as! Dictionary<String,Any>
                        if(statusCode == 200 || statusCode == 201){
                            let isAlready         = objectResponse["isAlready"] as! Bool
                            if(isAlready == true){
                                let token               = objectResponse["token"] as! String
                                let objClientResult     = objectResponse["objResult"] as! Dictionary<String,Any>
                                let client_id           = objClientResult["id"] as! Int
                                let client_name         = objClientResult["username"] as! String
                                let client_email        = objClientResult["email"] as! String
                                let date_loaded         = self.utilities.getCurrentDateTime(ifDateOrTime: "datetime")
                                
                                self.dbclass.insertUserAccount(id: client_id, name: client_name, email: client_email, token: token, object_data: objClientResult, date_updated: date_loaded)
                                self.dialogUtil.hideActivityIndicator(self.view)
                                
                                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "MenuTabBarController") as! MenuTabBarController
                                UIApplication.shared.keyWindow?.rootViewController = viewController
                            }
                            else{
                                self.dialogUtil.hideActivityIndicator(self.view)
                                if let viewController = UIStoryboard(name: "LoginStoryboard", bundle: nil).instantiateViewController(withIdentifier: "SignupController") as? SignupController {
                                    if let navigator = self.navigationController {
                                        viewController.paramsFacebook = requestParams
                                        navigator.present(viewController, animated: true)
                                    }
                                }
                            }
                        }
                        else{
                            self.dialogUtil.hideActivityIndicator(self.view)
                            self.logoutFacebook()
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
                        self.logoutFacebook()
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
    
    
    @IBAction func btnSubmit(_ sender: Any) {
        txtEmail.resignFirstResponder()
        txtPassword.resignFirstResponder()
        let email    = txtEmail.text!
        let password = txtPassword.text!
        if email.isEmpty == true {
            //alert box
            showDialog(title: "Incomplete Details",message: "Please enter your email address")
        }
        if password.isEmpty == true {
            showDialog(title: "Incomplete Details",message: "Please enter your password")
        }
        else{
            loginUser(email: email,password: password)
        }
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
        
        if(isLoggedOut == false){
            self.dismiss(animated: true, completion: nil)
        }
        else{
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "MenuTabBarController") as! MenuTabBarController
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
    }
    
    func loginUser(email:String,password:String){
        
        dialogUtil.showActivityIndicator(self.view)
        let myUrlString = SERVER_URL+"/api/mobile/loginUser";
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
                    guard let statusCode   = try response.response?.statusCode else {
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                        return
                    }
                    if let responseJSON = response.result.value{
                        var objectResponse            = responseJSON as! Dictionary<String,Any>
                        
                        print("OBJECT: \(responseJSON)")
                        
                        if(statusCode == 200 || statusCode == 201){
                            let token        = objectResponse["token"] as! String
                            let users_data   = objectResponse["users_data"] as! Dictionary<String,Any>
                            let transactions = objectResponse["transactions"] as! Dictionary<String,Any>
                            
                            let client_id    = users_data["id"] as! Int
                            let client_name  = users_data["username"] as! String
                            let client_email = users_data["email"] as! String
                            let date_loaded  = self.utilities.getCurrentDateTime(ifDateOrTime: "datetime")
                            print("Date Loaded: \(date_loaded)")
                            
                            self.dbclass.insertUserAccount(id: client_id, name: client_name, email: client_email, token: token, object_data: users_data, date_updated: date_loaded)

                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "MenuTabBarController") as! MenuTabBarController
                            UIApplication.shared.keyWindow?.rootViewController = viewController
                            self.dialogUtil.hideActivityIndicator(self.view)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
