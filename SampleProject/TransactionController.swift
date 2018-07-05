//
//  TransactionController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/25/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Alamofire
import SQLite


class TransactionController: UIViewController,UITableViewDelegate,UITableViewDataSource {
  
    @IBOutlet var tblTransactionList: UITableView!
    @IBOutlet var lblTotalTransaction: UILabel!
    @IBOutlet var lblTransactionCaption: UILabel!
    @IBOutlet var lblTotalDiscount: UILabel!
    @IBOutlet var lblTransactionThisMonth: UILabel!
    @IBOutlet var lblPLCStatus: UILabel!
    
    let utilities  = Utilities()
    let dbclass    = DatabaseHelper()
    let dialogUtil = DialogUtility()
    var SERVER_URL = ""
    var limit      = 30
    var arrayTransactions = [ArrayUserTransactionData]()
    var dictionaryTransaction = Dictionary<String,Any>()
    var total_transaction = 0.0
    var total_discount    = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SERVER_URL = dbclass.returnIp()
        tblTransactionList.delegate   = self
        tblTransactionList.dataSource = self
        getTransactionSummary()
        loadPremiere()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func loadPremiere(_ sender: Any) {
//        loadTotalTransactions()
        loadPremiere()
    }
    
    func loadPremiere(){
        var premiere_status = ""
        if(utilities.getUserPremierStatus() == false){
            premiere_status = "Not Premiere Client - "
            if(total_transaction >= 5000){
                 premiere_status += "Qualified!"
            }
            else{
                premiere_status += "Not yet Qualified!"
            }
        }
        else{
             premiere_status = "Premiere Client"
        }
        lblPLCStatus.text = premiere_status
    }
    
    @IBAction func loadPLC(_ sender: Any) {
        
        let storyBoard = UIStoryboard(name:"PremiereStoryboard",bundle:nil)
        let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "PremiereLoyaltyClientController") as! PremiereLoyaltyClientController
        self.navigationController?.pushViewController(appointmentVC, animated: true)
        
    }
    
    
    func getTransactionSummary(){
        do{
            self.dialogUtil.showActivityIndicator(self.view)
            let objectClient        = utilities.getUserObjectData()
            let jsonData            = objectClient.data(using: .utf8)
            let objectUser          = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
            let transactions        = objectUser.transaction_data
            let jsonTransactionData = transactions?.data(using: .utf8)
            arrayTransactions       = try JSONDecoder().decode([ArrayUserTransactionData].self, from: jsonTransactionData!)
      
            for rows in arrayTransactions{
                var price                 = utilities.getNumberValueInString(stringValue: "\(rows.net_amount!)")
                let transaction_price     = Double(price) ?? 0.0
                let transaction_discount  = Double(rows.price_discount  ?? "0.0")
                total_transaction+=transaction_price
                total_discount+=transaction_discount ?? 0.0
            }
            total_transaction+=10
            lblTotalTransaction.text    = utilities.convertToStringCurrency(value: "\(total_transaction)")
            lblTotalDiscount.text       = utilities.convertToStringCurrency(value: "\(total_discount)")
            self.dialogUtil.hideActivityIndicator(self.view)
            
        }
        catch{
            print("error: \(error)")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let position    = indexPath.row
        let cell        = tblTransactionList.dequeueReusableCell(withIdentifier: "cellTransactionList") as! TransactionViewCell
        let net_amount  = utilities.getNumberValueInString(stringValue: "\(arrayTransactions[indexPath.row].net_amount!)")
        let transaction_price   = Double(net_amount) ?? 0.0
        let transaction_branch  = arrayTransactions[indexPath.row].branch ?? "N/A"
        let transaction_date    = arrayTransactions[indexPath.row].date ?? "0000-00-00"
        
        cell.lblBranchName.text = transaction_branch.uppercased()
        cell.lblTotalPrice.text = utilities.convertToStringCurrency(value: "\(transaction_price)")
        cell.lblDate.text       = utilities.getCompleteDateString(stringDate: transaction_date)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = self.tblTransactionList.indexPathForSelectedRow{
            self.tblTransactionList.deselectRow(at: index, animated: true)
        }
        let position        = indexPath.row
        let storyBoard      = UIStoryboard(name:"TransactionStoryboard",bundle:nil)
        let appointmentVC   = storyBoard.instantiateViewController(withIdentifier: "TransactionDetailsController") as! TransactionDetailsController
        appointmentVC.objectTransaction  = arrayTransactions[position]
        self.navigationController?.pushViewController(appointmentVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let selectedRows = tableView.indexPathsForSelectedRows?.filter({ $0.section == indexPath.section }) {
            if selectedRows.count == limit {
                return nil
            }
        }

        return indexPath
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
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
