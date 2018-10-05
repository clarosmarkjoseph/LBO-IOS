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
    
    var totalTransactions           = 0.0
    var totalDiscounts              = 0.0
    var totalTransactionThisMonth   = 0.0
    
    
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
        loadPremiere()
    }
    
//    func loadOnlineTransaction(){
//        
//        dialogUtil.showActivityIndicator(self.view)
//        let token       = utilities.getUserToken()
//        let url         = "\(SERVER_URL)/api/mobile/getTotalTransactionAmount?token=\(token)"
//        Alamofire.request(url, method: .get)
//            .responseJSON { response in
//                do{
//                    self.dialogUtil.hideActivityIndicator(self.view)
//                    guard let statusCode   = try response.response?.statusCode else {
//                        if self.dialogUtil.activityIndicator.isAnimating{
//                            self.dialogUtil.hideActivityIndicator(self.view)
//                        }
//                        return
//                    }
//                    if let responseJSONData = response.data{
//                        if(statusCode == 200 || statusCode == 201){
//                            
//                            self.dialogUtil.hideActivityIndicator(self.view)
//                        }
//                        else{
//                            if self.dialogUtil.activityIndicator.isAnimating{
//                                self.dialogUtil.hideActivityIndicator(self.view)
//                            }
//                        }
//                    }
//                    else{
//                        if self.dialogUtil.activityIndicator.isAnimating{
//                            self.dialogUtil.hideActivityIndicator(self.view)
//                        }
//                    }
//                }
//                catch{
//                    if self.dialogUtil.activityIndicator.isAnimating{
//                        self.dialogUtil.hideActivityIndicator(self.view)
//                    }
//                    self.refreshControl.endRefreshing()
//                }
//        }
//        
//        
//    }
    
    
    func loadPremiere(){
        var premiere_status = ""
        if(utilities.getUserPremierStatus() == false){
            premiere_status = "Regular - "
            if(totalTransactions >= 5000.0){
                 premiere_status += "Qualified to be a Premier Loyalty !"
            }
            else{
                premiere_status += "Not yet Qualified!"
            }
        }
        else{
             premiere_status = "Premier Client"
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
            
            let dateFormat            = DateFormatter()
            dateFormat.dateFormat     = "yyyy-MM-dd"
            let currentDateString     = utilities.getCurrentDateTime(ifDateOrTime: "date")
            let currentDate           = dateFormat.date(from: currentDateString)
            var index = 0
            
            for rows in arrayTransactions{
                let price                 = utilities.getNumberValueInString(stringValue: "\(rows.net_amount!)")
                let discountString        = utilities.getNumberValueInString(stringValue: "\(rows.price_discount)")
                let transaction_price     = Double(price) ?? 0.0
                let transaction_discount  = Double(discountString)
                var transactionDate       = Date()
                let stringDate            = rows.date ?? "0000-00-00"
//                let arrayService = rows.services!
//                for row in arrayService{
//                    let string_price = utilities.getNumberValueInString(stringValue: "\(row.sub_total)")
//                    let net_price    = Double(string_price) ?? 0.0
//                    totalTransactions += net_price
//                }
                totalTransactions += transaction_price ?? 0.0
                totalDiscounts+=transaction_discount ?? 0.0
                transactionDate = utilities.convertStringToDate(stringDate: stringDate)
                let ifSameMonth = Calendar.current.isDate(currentDate!, equalTo: transactionDate, toGranularity: .month)
                if ifSameMonth == true{
                    totalTransactionThisMonth+=transaction_price
                }
                index+=1
            }
            
            lblTotalTransaction.text     = utilities.convertToStringCurrency(value: "\(totalTransactions)")
            lblTotalDiscount.text        = utilities.convertToStringCurrency(value: "\(totalDiscounts)")
            lblTransactionThisMonth.text = utilities.convertToStringCurrency(value: "\(totalTransactionThisMonth)")
            self.dialogUtil.hideActivityIndicator(self.view)
            arrayTransactions = arrayTransactions.sorted(by: {
                let date1 = utilities.convertStringToDate(stringDate: $0.date ?? "2000-01-01")
                let date2 = utilities.convertStringToDate(stringDate: $1.date ?? "2000-01-01")
                return (date1.compare(date2) == .orderedDescending)
            })
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
        var servTotal       = 0.0
        var servDiscount    = 0.0
        let arrayServices   = arrayTransactions[indexPath.row].services!
        
        let stringNet  = utilities.getNumberValueInString(stringValue: "\(arrayTransactions[indexPath.row].net_amount)")
        let doubleNet  = Double(stringNet) ?? 0.0
        
        for rows in arrayServices{
            let string_price = utilities.getNumberValueInString(stringValue: "\(rows.sub_total)")
            let net_price    = Double(string_price) ?? 0.0
            servTotal += net_price
        }
       
        let net_discount        = utilities.getNumberValueInString(stringValue: "\(arrayTransactions[indexPath.row].price_discount!)")
        
        servDiscount = Double(net_discount) ?? 0.0
        servTotal    = servTotal - servDiscount
        
        if(servTotal <= 0){
            servTotal = doubleNet
        }
        
        
        let transaction_branch  = arrayTransactions[indexPath.row].branch ?? "N/A"
        let transaction_date    = arrayTransactions[indexPath.row].date ?? "0000-00-00"
        cell.lblBranchName.text = transaction_branch.uppercased()
        cell.lblTotalPrice.text = utilities.convertToStringCurrency(value: "\(servTotal)")
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




