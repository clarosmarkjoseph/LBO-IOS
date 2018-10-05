//
//  PremiereHistoryDetailsController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/3/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit

class PremiereHistoryDetailsController: UITableViewController,UICollectionViewDataSource, UICollectionViewDelegate {

    let utilities = Utilities()
    let dbclass   = DatabaseHelper()
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblCaptionReference: UILabel!
    @IBOutlet var lblReferrenceNo: UILabel!
    @IBOutlet var lblBranch: UILabel!
    @IBOutlet var lblStatus: UILabel!
    @IBOutlet var lblApplicationType: UILabel!
    @IBOutlet var lblPlatform: UILabel!
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var lblCaptionRemarks: UILabel!
    @IBOutlet var lblRemarks: UILabel!
    @IBOutlet var collectionviewTransactions: UICollectionView!
    @IBOutlet var cellBranch: UITableViewCell!
    @IBOutlet var cellAttachment: UITableViewCell!
    @IBOutlet var cellApplicationType: UITableViewCell!
    @IBOutlet var cellPlatform: UITableViewCell!
    @IBOutlet var tblTransactionHistory: UITableView!
    
    var type = 0
    var objectApplication:PremiereLoyaltyCardList? = nil
    var objectRequest:TransactionRequest?          = nil
    var arrayTransactionDetails:[PLCReviewTransactionStruct] = [PLCReviewTransactionStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionviewTransactions.delegate     = self
        collectionviewTransactions.dataSource   = self
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden    = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func loadData(){
        if(type == 0){
            self.navigationItem.title   = "PLC Application History"
            let dateTime                = objectApplication?.created_at
            var status                  = objectApplication?.status ?? ""
           
            if(status == "approved"){
                lblStatus.backgroundColor = #colorLiteral(red: 0.5725490196, green: 0.7803921569, blue: 0.2509803922, alpha: 1)
            }
            else if(status == "processing"){
                lblStatus.backgroundColor = #colorLiteral(red: 1, green: 0.7450980392, blue: 0, alpha: 1)
            }
            else if(status == "delivery"){
                lblStatus.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.7529411765, blue: 0.8705882353, alpha: 1)
            }
            else if(status == "ready"){
                lblStatus.backgroundColor = #colorLiteral(red: 0.1058823529, green: 0.737254902, blue: 0.6078431373, alpha: 1)
            }
            else if(status == "picked_up"){
                status = "Picked-Up"
                lblStatus.backgroundColor = #colorLiteral(red: 0.5725490196, green: 0.7803921569, blue: 0.2509803922, alpha: 1)
            }
            else if(status == "denied"){
                lblStatus.backgroundColor = UIColor.red
            }
            else{
                lblStatus.backgroundColor = #colorLiteral(red: 0.5725490196, green: 0.7803921569, blue: 0.2509803922, alpha: 1)
            }
            
            lblDate.text            = utilities.getCompleteDateTimeString(stringDate: dateTime!)
            lblReferrenceNo.text    = objectApplication?.reference_no
            lblBranch.text          = objectApplication?.branch_name
            lblStatus.text          = status.capitalized
            lblApplicationType.text = objectApplication?.application_type
            lblPlatform.text        = objectApplication?.platform
            lblMessage.text         = "PLC Application"
            lblRemarks.text         = objectApplication?.remarks
        }
        else{
            self.navigationItem.title = "Transaction Review History"
            let remarks              = objectRequest?.remarks ?? "N/A"
            let status               = objectRequest?.status ?? "N/A"
            let message              = objectRequest?.message ?? "N/A"
            let dateTime             = objectRequest?.created_at
            lblDate.text             = utilities.getCompleteDateTimeString(stringDate: dateTime!)
            lblMessage.text          = "Transaction Request"
            lblCaptionReference.text = "Remarks:"
            lblReferrenceNo.text     = remarks.capitalized
            lblStatus.text           = status.capitalized
            lblCaptionRemarks.text   = "Your Message:"
            lblRemarks.text          = message.capitalized
            
            do{
                let plc_request_data     = objectRequest?.plc_review_request_data
                let jsonData              = plc_request_data?.data(using: .utf8)
                let jsonDecoderResult     = try JSONDecoder().decode(PLCReviewDataStruct.self, from: jsonData!)
                if let transactionDetails = jsonDecoderResult.transactions{
                    arrayTransactionDetails   = transactionDetails
                }
                collectionviewTransactions.reloadData()
                tblTransactionHistory.reloadData()
            }
            catch{
                print("FETCH ERROR: \(error)")
                collectionviewTransactions.reloadData()
                tblTransactionHistory.reloadData()
            }
        }
    }
 
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if(type == 0){
            return 2
        }
        else{
            if arrayTransactionDetails.count > 0{
                return 3
            }
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(type == 0){
            if(indexPath.section == 1){
                if(indexPath.row == 3){
                    return 0
                }
            }
            return 45
        }
        else{
            if (indexPath.section == 0){
                if(indexPath.row == 3){
                    return 0
                }
                return 45
            }
            if(indexPath.section == 1){
                if(indexPath.row == 2 || indexPath.row == 3){
                    return 45
                }
                return 0
            }
            if(indexPath.section == 2){
                return 145
            }
        }
        return UITableViewAutomaticDimension
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("COUNT TRANSACTIONS: \(arrayTransactionDetails.count)")
        return arrayTransactionDetails.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionviewTransactions.dequeueReusableCell(withReuseIdentifier: "cellRequest", for: indexPath) as! TransactionRequestCell
        let dictionaryLastTransaction   = arrayTransactionDetails[indexPath.row].last_transaction
        let unfiltered_amount           = dictionaryLastTransaction?.net_amount
        let net_price                   = utilities.getNumberValueInString(stringValue: "\(unfiltered_amount)")
        let raw_date                    = dictionaryLastTransaction?.date ?? "0000-00-00"
        cell.lblReferenceNo.text        = utilities.getNumberValueInString(stringValue: "\(stringValue: dictionaryLastTransaction?.inv)")
        cell.lblBranch.text             = dictionaryLastTransaction?.branch
        cell.lblDate.text               = dictionaryLastTransaction?.date ?? "0000-00-00"
        cell.lblPrice.text              = utilities.convertToStringCurrency(value:net_price)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
        if indexPath.section == 1{
            if indexPath.row == 3{
                let imgName     = objectRequest?.valid_id_url
                let SERVER_URL  = dbclass.returnIp()
                
                
                if(imgName == "" || imgName == nil || imgName == "null"){
                    self.showDialog(title: "No file / image attached!", message: "Sorry, there is no file / image attached.")
                }
                else{
                    let url             = "\(SERVER_URL)/images/ids/\(imgName!)"
                    let storyBoard      = UIStoryboard(name:"PremiereStoryboard",bundle:nil)
                    let viewController  = storyBoard.instantiateViewController(withIdentifier: "TransactionPreviewAttachmentController") as! TransactionPreviewAttachmentController
                    viewController.imgSRC   = url
                    self.navigationController?.isNavigationBarHidden    = true
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
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
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

}
