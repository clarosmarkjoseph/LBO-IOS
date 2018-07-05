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
//            let dateOnly = utilities.removeTimeFromDatetime(stringDateTime: dateTime)
            let dateTime            = objectApplication?.created_at
            lblDate.text            = utilities.getCompleteDateTimeString(stringDate: dateTime!)
            lblReferrenceNo.text    = objectApplication?.reference_no
            lblBranch.text          = objectApplication?.branch_name
            lblStatus.text          = objectApplication?.status?.capitalized
            lblApplicationType.text = objectApplication?.application_type
            lblPlatform.text        = objectApplication?.platform
            lblMessage.text         = "PLC Application"
            lblRemarks.text         = objectApplication?.remarks
        }
        else{
            let dateTime             = objectRequest?.created_at
            var plc_request_data     = objectRequest?.plc_review_request_data
            lblDate.text             = utilities.getCompleteDateTimeString(stringDate: dateTime!)
            lblMessage.text          = "Transaction Request"
            lblCaptionReference.text = "Remarks:"
            lblReferrenceNo.text     = objectRequest?.remarks?.capitalized
            lblStatus.text           = objectRequest?.status?.capitalized
            lblCaptionRemarks.text   = "Your Message:"
            lblRemarks.text          = objectRequest?.message?.capitalized
            
            do{
                let jsonData              = plc_request_data?.data(using: .utf8)
                let jsonDecoderResult     = try JSONDecoder().decode(PLCReviewDataStruct.self, from: jsonData!)
                arrayTransactionDetails   = jsonDecoderResult.transactions!
                collectionviewTransactions.reloadData()
            }
            catch{
                print("FETCH ERROR: \(error)")
            }
            
            
            
        }
    }
 
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if(type == 0){
            return 2
        }
        else{
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(type == 1){
            print("SECTION NO: \(indexPath.section)")
            if (indexPath.section == 0){
                if(indexPath.row == 3){
                    return 0
                }
                return UITableViewAutomaticDimension
            }
            if(indexPath.section == 1){
                if(indexPath.row == 2 || indexPath.row == 3){
                    return UITableViewAutomaticDimension
                }
                return 0
            }
            if(indexPath.section == 2){
                return 145
            }
        }
        else{
            if(indexPath.section == 1){
                if(indexPath.row == 3){
                     return 0
                }
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
        cell.lblReferenceNo.text        = dictionaryLastTransaction?.inv
        cell.lblBranch.text             = dictionaryLastTransaction?.branch
        cell.lblDate.text               = dictionaryLastTransaction?.date ?? "0000-00-00"
        cell.lblPrice.text              = utilities.convertToStringCurrency(value:net_price)
        print("Price: \(net_price)")
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
        
        if indexPath.section == 1{
            if indexPath.row == 3{
                let imgName = objectRequest?.valid_id_url
                let url                 = "https://lbo.lay-bare.com/images/ids/2_1530670460.jpg"
                let storyBoard          = UIStoryboard(name:"PremiereStoryboard",bundle:nil)
                let viewController      = storyBoard.instantiateViewController(withIdentifier: "TransactionPreviewAttachmentController") as! TransactionPreviewAttachmentController
                viewController.imgSRC   = url
                self.navigationController?.isNavigationBarHidden    = true
                self.navigationController?.pushViewController(viewController, animated: true)
                
                
//                if(imgName == "" || imgName == nil){
//                    self.showDialog(title: "No file / image attached!", message: "Sorry, there is no file / image attached.")
//                }
//                else{
////                    let url = "\(dbclass.returnIp())/images/ids/\(imgName)"
//                    let url                 = "http://lbo.lay-bare.com/images/ids/2_1530670460.jpg"
//                    let storyBoard          = UIStoryboard(name:"PremiereStoryboard",bundle:nil)
//                    let viewController      = storyBoard.instantiateViewController(withIdentifier: "TransactionPreviewAttachmentController") as! TransactionPreviewAttachmentController
//                    viewController.imgSRC   = url
//                    self.navigationController?.pushViewController(viewController, animated: true)
//                }
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
//        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.landscapeLeft)
    }

}
