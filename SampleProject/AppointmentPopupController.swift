//
//  AppointmentPopupController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 8/6/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Alamofire
import SQLite
import Cosmos

protocol AppointmentReview {
    func setAppointmentReview(review_id:Int,review_count:Double)
}

class AppointmentPopupController: UIViewController {

    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblReferenceNo: UILabel!
    @IBOutlet var lblBranch: UILabel!
    @IBOutlet var lblTechnician: UILabel!
    @IBOutlet var lblRatingCaption: UILabel!
    @IBOutlet var cosmosRating: CosmosView!
    @IBOutlet var btnRating: UIButton!
    @IBOutlet var popupView: UIView!
    
    
    let dbclass                             = DatabaseHelper()
    let utilities                           = Utilities()
    var appointmentObject:AppointmentList?  = nil
    var review_id                           = 0
    var SERVER_URL                          = ""
    var clientRating                        = 0.0
    let dialogUtil                          = DialogUtility()
    var transaction_id                      = 0
    var delegate:AppointmentReview!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 20
        popupView.layer.masksToBounds = true
        
        transaction_id      = appointmentObject?.id ?? 0
        SERVER_URL          = dbclass.returnIp()
        var date            = utilities.getCompleteDateTimeString(stringDate: (appointmentObject?.transaction_datetime)!)
        let branch          = appointmentObject?.branch_name?.capitalized
        let tech            = appointmentObject?.technician_name?.capitalized
        let reference_no    = appointmentObject?.reference_no ?? "N/A"
        lblDate.text        = date
        lblBranch.text      = branch
        lblTechnician.text  = tech
        lblReferenceNo.text = reference_no
        
        cosmosRating.didFinishTouchingCosmos = { rating  in
            let caption                 = self.getReviewCaption(rating: rating)
            self.lblRatingCaption.text  = caption
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitRating(_ sender: Any) {
        let token = utilities.getUserToken()
        let myURL = URL(string: "\(SERVER_URL)/api/mobile/reviews/reviewTransaction?token=\(token)")
        let requestParams = [
            "review_id":"\(review_id)",
            "transaction_id":"\(transaction_id)",
            "rating":"\(clientRating)",
            "feedback":""
            ]
        print(requestParams)
        self.dialogUtil.showActivityIndicator(self.view)
        Alamofire.request(myURL!, method: .post, parameters: requestParams)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                        return
                    }
                    
                    if response.data != nil{
                        if(statusCode == 200 || statusCode == 201){
                            self.dialogUtil.hideActivityIndicator(self.view)
                            let jsonDictionary = response.result.value as! Dictionary<String,Any>
                            let jsonDictionaryResult    = jsonDictionary["data_response"] as! Dictionary<String,Any>
                            print("result: \(jsonDictionaryResult)")
                            self.review_id              = jsonDictionaryResult["id"] as? Int ?? 0
                            self.delegate.setAppointmentReview(review_id: self.review_id, review_count: self.clientRating)
                            self.dismiss(animated: true, completion: nil)
                        }
                        else if (statusCode == 401){
                            self.dialogUtil.hideActivityIndicator(self.view)
                            self.utilities.deleteAllData()
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "LoginStoryboard", bundle: nil)
                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
                            viewController.isLoggedOut      = true
                            viewController.sessionExpired   = true
                            UIApplication.shared.keyWindow?.rootViewController = viewController
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
                    print("error catch: \(error)")
                    self.dialogUtil.hideActivityIndicator(self.view)
                    self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                }
        }
        
        
    }
    
    func getReviewCaption(rating:Double) -> String{
        var remarks = "";
        if(rating <= 1.0){
            remarks = "Unsatisfied!";
        }
        else if( (rating > 1) && (rating <= 2) ){
            remarks = "Slightly Disliked!";
        }
        else if((rating > 2) && (rating <= 3)){
            remarks = "It's Okay!";
        }
        else if((rating > 3) && (rating <= 4)){
            remarks = "Liked it!";
        }
        else if((rating > 4) && (rating <= 5)){
            remarks = "Loved it!";
        }
        clientRating                = rating
        self.btnRating.alpha        = 1.0
        self.btnRating.isEnabled    = true
        return remarks;
    }
    
    @IBAction func btnDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func showDialog(title:String,message:String){
        //alert box
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Retry", style: .default) { (action) in
            self.submitRating(self.btnRating)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.submitRating(self.btnRating)
        }
        alertView.addAction(confirm)
        alertView.addAction(cancel)
        present(alertView,animated: true,completion: nil)
    }
    
    
    

}
