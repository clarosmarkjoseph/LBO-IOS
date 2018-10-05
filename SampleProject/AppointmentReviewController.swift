//
//  AppointmentReviewController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 8/6/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Alamofire
import SQLite
import Cosmos
import Kingfisher

class AppointmentReviewController: UIViewController,UITextViewDelegate {

    @IBOutlet var lblClientName: UILabel!
    @IBOutlet var imgClient: UIImageView!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblReferenceNo: UILabel!
    @IBOutlet var lblBranch: UILabel!
    @IBOutlet var lblTechnician: UILabel!
    @IBOutlet var cosmosRating: CosmosView!
    @IBOutlet var lblRatingCaption: UILabel!
    @IBOutlet var textfieldComment: UITextView!
    @IBOutlet var btnSubmitReview: UIButton!
    @IBOutlet var textview: UITextView!
    
    let dbclass                             = DatabaseHelper()
    let utilities                           = Utilities()
    var appointmentObject:AppointmentList?  = nil
    var review_id                           = 0
    var SERVER_URL                          = ""
    var clientRating                        = 0.0
    let dialogUtil                          = DialogUtility()
    var transaction_id                      = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textview.delegate   = self
        transaction_id      = appointmentObject?.id ?? 0
        SERVER_URL          = dbclass.returnIp()
        lblClientName.text  = utilities.getUserName()
        let imgName         = utilities.getUserImage()
        let myURL           = URL(string: "\(SERVER_URL)/images/users/\(imgName)")
        imgClient.kf.setImage(with: myURL)
        
        let date            = utilities.getCompleteDateTimeString(stringDate: (appointmentObject?.transaction_datetime)!)
        let branch          = appointmentObject?.branch_name?.capitalized
        let tech            = appointmentObject?.technician_name?.capitalized
        let reference_no    = appointmentObject?.reference_no ?? "N/A"
        lblDate.text        = date
        lblBranch.text      = branch
        lblTechnician.text  = tech
        lblReferenceNo.text = reference_no
        
        lblRatingCaption.text = getReviewCaption(rating: clientRating)
        textview.textColor    = UIColor.lightGray
        textview.becomeFirstResponder()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        cosmosRating.didFinishTouchingCosmos = { rating  in
            let caption                 = self.getReviewCaption(rating: rating)
            self.lblRatingCaption.text  = caption
        }
        cosmosRating.rating = clientRating
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
        clientRating                      = rating
        self.btnSubmitReview.alpha        = 1.0
        self.btnSubmitReview.isEnabled    = true
        return remarks;
    }
    
    @IBAction func submitReview(_ sender: Any) {
        let txtComment = textview.text!
        
        if(self.validateTextView(textView: textview) == false || txtComment == "Please share to us your experience in this branch / technician or anything" ){
             self.showDialog(title: "Empty Review!", message: "Please provide your review / comment in this transaction",ifExit: false)
        }
        else{
            self.saveToServer(comment: txtComment)
        }
        
    }
    
    func saveToServer(comment:String){
        
        let token = utilities.getUserToken()
        let myURL = URL(string: "\(SERVER_URL)/api/mobile/reviews/reviewTransaction?token=\(token)")
        let requestParams = [
            "review_id":"\(review_id)",
            "transaction_id":"\(transaction_id)",
            "rating":"\(clientRating)",
            "feedback":comment
        ]
        print("parameters: \(requestParams)")
        self.dialogUtil.showActivityIndicator(self.view)
        Alamofire.request(myURL!, method: .post, parameters: requestParams)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again",ifExit: false)
                        return
                    }
                    print("Status Code: \(statusCode)")
                    if response.data != nil{
                        if(statusCode == 200 || statusCode == 201){
                            self.dialogUtil.hideActivityIndicator(self.view)
                            self.showDialog(title: "Review Success!", message: "You just reviewed your transaction. It will display to branch profile located at Location(home).",ifExit: true)
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
                                self.showDialog(title:arrayError[0], message: arrayError[1],ifExit: false)
                            }
                            else{
                                self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again",ifExit: false)
                            }
                        }
                    }
                    else{
                        
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again",ifExit: false)
                    }
                }
                catch{
                    print("error catch: \(error)")
                    self.dialogUtil.hideActivityIndicator(self.view)
                    self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again",ifExit: false)
                }
        }
    }
    
    func validateTextView(textView textView: UITextView) -> Bool {
        guard let text = textView.text,
            !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
                // this will be reached if the text is nil (unlikely)
                // or if the text only contains white spaces
                // or no text at all
                return false
        }
        
        return true
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

    
    @available(iOS 2.0, *)
    public func textViewDidBeginEditing(_ textView: UITextView){
        if textView == textview{
            if textview.textColor == UIColor.lightGray {
                textview.text = ""
                textview.textColor = UIColor.black
            }
        }
    }
    
    @available(iOS 2.0, *)
    public func textViewDidEndEditing(_ textView: UITextView){
        if textView == textview{
            if textview.text.isEmpty {
                textview.text = "Please share to us your experience in this branch / technician or anything"
                textview.textColor = UIColor.lightGray
            }
        }
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
