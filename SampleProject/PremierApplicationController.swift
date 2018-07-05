//
//  PremierApplicationController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/29/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Alamofire

class PremierApplicationController: UIViewController,ProtocolBranch {

    var utilities       = Utilities()
    var dbclass         = DatabaseHelper()
    var position_type   = 0
    var home_branch_id  = 0
    var SERVER_URL      = ""
    let dialogUtil      = DialogUtility()
    
    @IBOutlet var imgCard: UIImageView!
    @IBOutlet var imgCaption: UILabel!
    @IBOutlet var txtBranch: UITextField!
    @IBOutlet var segmentType: UISegmentedControl!
    @IBOutlet var stackIfReplacement: UIStackView!
    @IBOutlet var lblReason: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SERVER_URL = dbclass.returnIp()
        loadPremiere()
    }
    
    func loadPremiere(){
        let gender      = utilities.getUserGender()
        home_branch_id  = utilities.getUserHomeBranch()
        let home_branch = utilities.getBranchName(branch_id: home_branch_id)
        txtBranch.text  = home_branch
        txtBranch.addTarget(self, action: #selector(showBranches), for: UIControlEvents.editingDidBegin)
        
        segmentType.selectedSegmentIndex = position_type
        
        if(gender == "male"){
            imgCaption.text = "Premiere Loyalty Card For Male"
            imgCard.image   = UIImage(named: "plc_male")
        }
        else{
            imgCaption.text = "Premiere Loyalty Card For Female"
            imgCard.image   = UIImage(named: "plc_female")
        }
        
        
    }
    
    
    @objc func showBranches(){
        txtBranch.resignFirstResponder()
        let viewController = UIStoryboard(name: "OtherStoryboard", bundle: nil).instantiateViewController(withIdentifier: "BranchController") as? BranchController
        viewController?.ifAppointment   = false
        viewController?.delegate        = self
        present(viewController!, animated: true,completion: nil)
        
    }
    
    
    
    func setBranch(selectedBranch: String, selectedBranchID: Int, objectBranch: ArrayBranch) {
        home_branch_id      = selectedBranchID
        txtBranch.text      = selectedBranch
    }
    
   
    @IBAction func onSegmentClicked(_ sender: UISegmentedControl) {
        let position = sender.selectedSegmentIndex
        if(position == 0){
            lblReason.text              = ""
            stackIfReplacement.isHidden = true
        }
        else{
            showReasonPopup()
        }
    }
    
    func showReasonPopup(){
        let alertController = UIAlertController(title: "Applying for PLC Card Replacement.", message: "Please present your reason why are you requesting for a new replacement to card.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            textField.placeholder = "Enter here"
            let answer    = textField.text!
            
            if(answer == "" || textField.text!.isEmpty){
                self.showDialog(title: "Empty Input", message: "Reason must not empty",ifExit: false)
                return
            }
            else{
                self.stackIfReplacement.isHidden        = false
                self.lblReason.text                     = answer.capitalized
                self.segmentType.selectedSegmentIndex   = 1
                alertController.dismiss(animated: false, completion: nil)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.placeholder                   = ""
            self.segmentType.selectedSegmentIndex   = 0
            alertController.dismiss(animated: false, completion: nil)
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func btnSubmitClicked(_ sender: Any) {
        validateInput()
    }
    
    func validateInput(){
        print("Submit")
        if(home_branch_id <= 0){
            self.showDialog(title: "Branch must not empty!", message: "Sorry, please select your Application Branch so we may deliver it.",ifExit: false)
            return
        }
        else{
            let positionType = segmentType.selectedSegmentIndex
            if(position_type == 1){
                let reason = lblReason.text
                if(reason == ""){
                     self.showDialog(title: "Reason is empty!", message: "Sorry, please specify your reason of replacing your existing card.",ifExit: false)
                    return
                }
                else{
                    submitApplication()
                }
            }
            else{
                submitApplication()
            }
        }
    }
    
    func submitApplication(){
        
        let token             = utilities.getUserToken()
        let apply_url_string  = SERVER_URL+"/api/premier/applyPremier?token="+token
        var application_type  = ""
        let platform          = "IOS"
        let reason            = lblReason.text!
        var objectApplication = Dictionary<String,Any>()
        var objectBranch      = Dictionary<String,Any>()
        
        if(segmentType.selectedSegmentIndex == 0){
            application_type = "New"
        }
        else{
            application_type = "Replacement"
        }
        objectBranch["value"]   = home_branch_id
        objectBranch["label"]   = txtBranch.text!
        
        objectApplication["branch"]     = objectBranch
        objectApplication["type"]       = application_type
        objectApplication["platform"]   = platform
        objectApplication["reason"]     = reason
        
        let jsonString      = utilities.convertDictionaryToJSONString(dictionaryVal:objectApplication)
        let jsonData        = utilities.convertJSONStringToData(arrayString: jsonString)
        let application_url = URL(string: apply_url_string)!
        
        var request         = URLRequest(url: application_url)
        request.httpMethod  = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody    = jsonData
        
        self.dialogUtil.showActivityIndicator(self.view)
        
        Alamofire.request(request)
            .responseJSON { response in
                do{
                    self.dialogUtil.hideActivityIndicator(self.view)
                    guard let statusCode    = try response.response?.statusCode else { return }
                    print(statusCode)
                    if response.data != nil{
                        if(statusCode == 200 || statusCode == 201){
                            self.showDialog(title: "Success!", message: "You have successfully applied for Premiere Loyalty Card. The process will take 2-3 weeks. We will notify you once the card is ready and you may claim it to your selected branch. \nThank you!", ifExit: true)
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
                catch{
                    print("WEW: \(error)")
                    self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again",ifExit: false)
                }
        }
        
    }
    
    func showDialog(title:String,message:String,ifExit:Bool){
        //alert box
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            if(ifExit == true){
                 self.navigationController?.popToRootViewController(animated: true);
            }
        }
        alertView.addAction(confirm)
        present(alertView,animated: true,completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

 

}
