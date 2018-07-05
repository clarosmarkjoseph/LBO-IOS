//
//  PremiereLoyaltyClientController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/28/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Alamofire
import SQLite

class PremiereLoyaltyClientController: UIViewController {

    @IBOutlet var lblGrossPrice: UILabel!
    @IBOutlet var lblDiscountPrice: UILabel!
    @IBOutlet var lblNetPrice: UILabel!
    @IBOutlet var lblPremiereStatus: UILabel!
    @IBOutlet var uiviewApplication: UIView!
    @IBOutlet var uiviewCard: UIView!
    @IBOutlet var lblApplicationTitle: UILabel!
    @IBOutlet var lblApplicationContent: UILabel!
    @IBOutlet var lblCardTitle: UILabel!
    @IBOutlet var lblCardContent: UILabel!
    @IBOutlet var btnPLCApplication: UIButton!
    @IBOutlet var btnViewList: UIBarButtonItem!
    
    
    var dbclass     = DatabaseHelper()
    var utilities   = Utilities()
    var dialogUtil  = DialogUtility()
    var SERVER_URL  = ""
    var total_transaction = 10.0
    var total_discount    = 0.0
    var position_status   = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SERVER_URL = dbclass.returnIp()
    }

    
    override func viewDidAppear(_ animated: Bool) {
         AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        if(animated){
            computeTotalTransactions()
        }
    }
    

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func computeTotalTransactions(){
        do{
            total_transaction = 10.0
            total_discount    = 0.0
            
            self.dialogUtil.showActivityIndicator(self.view)
            let objectClient        = utilities.getUserObjectData()
            let jsonData            = objectClient.data(using: .utf8)
            let objectUser          = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
            let transactions        = objectUser.transaction_data
            let jsonTransactionData = transactions?.data(using: .utf8)
            let arrayTransactions   = try JSONDecoder().decode([ArrayUserTransactionData].self, from: jsonTransactionData!)
           
            
            for rows in arrayTransactions{
                var net_amount            = utilities.getNumberValueInString(stringValue: "\(rows.net_amount)")
                let transaction_price     = Double(net_amount)!
                let transaction_discount  = Double(rows.price_discount!)
                total_transaction+=transaction_price
                total_discount+=transaction_discount ?? 0.0
            }
            let gross_transaction   = total_transaction + total_discount
            
            lblGrossPrice.text      = utilities.convertToStringCurrency(value: "\(gross_transaction)")
            lblDiscountPrice.text   = utilities.convertToStringCurrency(value: "\(total_discount)")
            lblNetPrice.text   = utilities.convertToStringCurrency(value: "\(total_transaction)")
            
            self.dialogUtil.hideActivityIndicator(self.view)
            loadPremiereApplications()
        }
        catch{
            print("error: \(error)")
        }
    }
    
    
    func loadPremiereApplications(){
        self.dialogUtil.showActivityIndicator(self.view)
        let token           = utilities.getUserToken()
        let urlTransaction  = SERVER_URL+"/api/mobile/getPLCDetails/true?token="+token;
        Alamofire.request(urlTransaction, method: .get)
            .responseJSON { response in
                do{
                    self.dialogUtil.hideActivityIndicator(self.view)
                    guard let statusCode   = try response.response?.statusCode else { return }
                    if let responseJSONData = response.data{
                        if(statusCode == 200 || statusCode == 201){
                            //success
                            let objectResponse      = try JSONDecoder().decode(PremiereAndRequest.self, from: responseJSONData)
                            let currentDatetime     = self.utilities.getCurrentDateTime(ifDateOrTime: "datetime")
                            do{
                                
                                let jsonEncodedPremier  = try JSONEncoder().encode(objectResponse.application)
                                let jsonEncodedRequest  = try JSONEncoder().encode(objectResponse.request)
                                let premiere_tbl        = self.dbclass.premiere_tbl
                                let request_tbl         = self.dbclass.transaction_request_tbl
                                let countRequest        = try self.dbclass.db?.scalar(request_tbl.count) ?? 0
                                let countApplication    = try self.dbclass.db?.scalar(premiere_tbl.count) ?? 0
                                let arrayPremiereString = self.utilities.convertDataToJSONString(data: jsonEncodedPremier)
                                let arrayRequestString  = self.utilities.convertDataToJSONString(data: jsonEncodedRequest)
                                
                                if(countRequest <= 0){
                                    self.dbclass.insertPremiere(arrayString: arrayPremiereString, date_updated: currentDatetime)
                                }
                                else{
                                    self.dbclass.updatePremiere(arrayString: arrayPremiereString, date_updated: currentDatetime)
                                }
                                if(countApplication <= 0){
                                    let arrayRequestString = self.utilities.convertDataToJSONString(data: jsonEncodedRequest)
                                    self.dbclass.insertTransactionRequest(arrayString: arrayRequestString, date_updated: currentDatetime)
                                }
                                else{
                                     self.dbclass.updateTransactionRequest(arrayString: arrayRequestString, date_updated: currentDatetime)
                                }
                                
                                self.loadPremiereList()
                            }
                            catch{
                                print("ERROR: \(error)")
                                self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                            }
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
    
    
    
    func loadPremiereList(){
        
        let premiere_tbl    = dbclass.premiere_tbl
        var status          = ""
        var caption         = ""
        do{
            if let queryPremiere        = try self.dbclass.db?.pluck(premiere_tbl){
                let arrayPremiereString = queryPremiere[self.dbclass.premiere_array]
                
                let premiereData        = arrayPremiereString.data(using: .utf8)
                let arrayPremiere       = try JSONDecoder().decode([PremiereLoyaltyCardList].self, from: premiereData!)
               
                if((arrayPremiere.count) > 0){
                    for rows in arrayPremiere {
                       
                        let premiere_status = rows.status
                        status              = (premiere_status?.uppercased())!
                        
                        if(premiere_status == "approved"){
                            caption = self.utilities.getPLCCaption(index: 2)
                            self.lblPremiereStatus.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.7529411765, blue: 0.8705882353, alpha: 1)
                        }
                        if(premiere_status == "processing"){
                            caption = self.utilities.getPLCCaption(index: 3)
                            self.lblPremiereStatus.backgroundColor = #colorLiteral(red: 1, green: 0.7450980392, blue: 0, alpha: 1)
                        }
                        if(premiere_status == "delivery"){
                            caption = self.utilities.getPLCCaption(index: 4)
                            self.lblPremiereStatus.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.7333333333, blue: 0.1568627451, alpha: 1)
                        }
                        if(premiere_status == "ready"){
                            caption = self.utilities.getPLCCaption(index: 5)
                            position_status = 3
                            self.lblPremiereStatus.backgroundColor = #colorLiteral(red: 0.5725490196, green: 0.7803921569, blue: 0.2509803922, alpha: 1)
                        }
                        if(premiere_status == "picked_up"){
                            caption = self.utilities.getPLCCaption(index: 6)
                            status  = "Already Picked-Up"
                            position_status = 1
                            self.lblPremiereStatus.backgroundColor = #colorLiteral(red: 0.5725490196, green: 0.7803921569, blue: 0.2509803922, alpha: 1)
                        }
                        if(premiere_status == "denied"){
                            caption = self.utilities.getPLCCaption(index: 7)
                            status      = "Denied"
                            let plc_data = rows.plc_data
                            let remarks  = rows.remarks ?? plc_data?.reason ?? "No inputed reason. Please contact customer service @info-lay-bare.com"
                            caption+=" \(remarks)"
                            self.lblPremiereStatus.backgroundColor = UIColor.red
                            position_status = 2
                        }
                        if(premiere_status == "deleted"){
                            if(self.total_transaction < 5000){
                                caption = self.utilities.getPLCCaption(index: 0)
                                status  = "Not yet Qualified"
                                self.lblPremiereStatus.backgroundColor  = UIColor.red
                                position_status = 4
                            }
                            else{
                                caption = self.utilities.getPLCCaption(index: 1)
                                status   = "Qualified!"
                                position_status = 5
                                self.lblPremiereStatus.backgroundColor  = #colorLiteral(red: 0.1058823529, green: 0.737254902, blue: 0.6078431373, alpha: 1)
                            }
                        }
                        break
                    }
                }
                else{
                    if(self.total_transaction < 5000){
                        caption = self.utilities.getPLCCaption(index: 0)
                        status  = "Not yet Qualified"
                        position_status = 4
                        self.lblPremiereStatus.backgroundColor  = UIColor.red
                    }
                    else{
                        caption = self.utilities.getPLCCaption(index: 1)
                        status   = "Qualified!"
                        position_status = 5
                        self.lblPremiereStatus.backgroundColor  = #colorLiteral(red: 0.1058823529, green: 0.737254902, blue: 0.6078431373, alpha: 1)
                    }
                }
            }
            else{
                if(self.total_transaction < 5000){
                    caption = self.utilities.getPLCCaption(index: 0)
                    status  = "Not yet Qualified"
                    self.lblPremiereStatus.backgroundColor  = UIColor.red
                    position_status = 4
                }
                else{
                    caption = self.utilities.getPLCCaption(index: 1)
                    status   = "Qualified!"
                    position_status = 5
                    self.lblPremiereStatus.backgroundColor  = #colorLiteral(red: 0.1058823529, green: 0.737254902, blue: 0.6078431373, alpha: 1)
                }
            }
            self.nextStep(status: status.capitalized, caption: caption.capitalized)

        }
        catch{
            print("ERROR: \(error)")
            status  = "Error Occured!"
            caption = "There is an error occured! Please refresh the app and try again"
            position_status = 6
            self.nextStep(status: status, caption: caption.capitalized)
            self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
        }
    }
    
    func nextStep(status:String,caption:String){
        
        var applicationTitle    = ""
        var applicationContent  = ""
        var applicationBtnText  = ""
        lblPremiereStatus.text  = status.capitalized
      
        if(position_status == 0){
            //show loyalty virtual card & will deny applying for a new/replacement
            uiviewCard.isHidden         = false
            btnPLCApplication.isEnabled = false
            btnPLCApplication.alpha     = 0.5
            applicationBtnText          = "Replacement is not available"
            applicationTitle            = "Premiere Loyalty Card"
            btnPLCApplication.setTitle(applicationBtnText, for:.normal)
        }
        if(position_status == 1){
            //show loyalty virtual card & will allow applying for a new/replacement
            uiviewCard.isHidden = false
            applicationTitle    = "Premiere Loyalty Card"
            applicationBtnText  = "Apply for PLC Replacement"
            btnPLCApplication.setTitle(applicationBtnText, for:.normal)
        }
       
        if(position_status == 3){
             // Status: ready (mark plc as picked - up)
            uiviewCard.isHidden = false
            applicationTitle    = "Premiere Loyalty Card - Card is ready."
            applicationBtnText  = "Mark Card as Picked-up!"
            btnPLCApplication.setTitle(applicationBtnText, for:.normal)
        }
        if(position_status == 4){
            //not qualified(message will changed) & redirect to transaction request
            uiviewCard.isHidden = true
            applicationTitle    = "Premiere Loyalty Card - More transaction"
            applicationBtnText  = "Request for Transaction Review"
            btnPLCApplication.setTitle(applicationBtnText, for:.normal)
        }
        if(position_status == 5){
            //qualified but no premier application yet
            uiviewCard.isHidden = true
            applicationTitle    = "Premiere Loyalty Card -Qualified!"
            applicationBtnText  = "Apply for Premiere Loyalty Card"
            btnPLCApplication.setTitle(applicationBtnText, for:.normal)
        }
        if(position_status == 6){
            //qualified but no premier application yet
            uiviewCard.isHidden = true
            applicationTitle    = "Premiere Loyalty Card - Application error!"
            applicationBtnText  = "Please try again!"
            btnPLCApplication.setTitle(applicationBtnText, for: .disabled)
            btnPLCApplication.alpha = 0.5
        }
        
        lblApplicationContent.text  = caption
        if(position_status == 2){
            //special position for denied & deleted (Check transaction if meet)
            applicationTitle    = "PLC Previous application: \(status)"
            uiviewCard.isHidden = true
            var captionDenied = caption
            if(self.total_transaction < 5000){
                captionDenied += "\n\n\(self.utilities.getPLCCaption(index: 0))"
                applicationBtnText  = "Request for Transaction Review"
                position_status = 4
            }
            else{
                captionDenied += "\n\n\(self.utilities.getPLCCaption(index: 1))"
                applicationBtnText  = "Apply for Premiere Loyalty Card"
                position_status = 5
            }
            lblApplicationContent.text = captionDenied
            btnPLCApplication.setTitle(applicationBtnText, for:.normal)
        }
        lblApplicationTitle.text    = applicationTitle
        uiviewApplication.isHidden  = false
    }
    
    //Top Button
    @IBAction func getOptions(_ sender: Any) {
        let alertView = UIAlertController(title: "View History", message: "You're about to view all PLC Application and Transaction History list, Continue?", preferredStyle: .actionSheet)
        
        
        let btnBrowseApplicationHistory = UIAlertAction(title: "Confirm", style: .default) { (action) in
            let storyBoard = UIStoryboard(name:"PremiereStoryboard",bundle:nil)
            let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "PremiereHistoryController") as! PremiereHistoryController
            self.navigationController?.pushViewController(appointmentVC, animated: true)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertView.addAction(btnBrowseApplicationHistory)
        alertView.addAction(cancel)
        present(alertView,animated: true,completion: nil)
    }
    
    //application (1st UI)
    @IBAction func applicationAction(_ sender: Any) {
        
        if(position_status == 4){
            //transaction request
        }
        if(position_status == 5 ){
            //application
            let storyBoard = UIStoryboard(name:"PremiereStoryboard",bundle:nil)
            let applicationVC  = storyBoard.instantiateViewController(withIdentifier: "PremierApplicationController") as! PremierApplicationController
            applicationVC.position_type = 0
            self.navigationController?.pushViewController(applicationVC, animated: true)
        }
        if(position_status == 1){
            //replacement
            let storyBoard = UIStoryboard(name:"PremiereStoryboard",bundle:nil)
            let applicationVC  = storyBoard.instantiateViewController(withIdentifier: "PremierApplicationController") as! PremierApplicationController
            applicationVC.position_type = 1
            self.navigationController?.pushViewController(applicationVC, animated: true)
        }
        
        
    }
    
    
    //card (2nd UI)
    @IBAction func cardAction(_ sender: Any) {
        let storyBoard      = UIStoryboard(name:"PremiereStoryboard",bundle:nil)
        let cardPreviewVC   = storyBoard.instantiateViewController(withIdentifier: "PremiereCardPageviewController") as! PremiereCardPageviewController
        self.navigationController?.isNavigationBarHidden    = true
        self.navigationController?.pushViewController(cardPreviewVC, animated: true)
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
