//
//  PremiereHistoryController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/3/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit

class PremiereHistoryController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var segmentTabs: UISegmentedControl!
    @IBOutlet var tblHistory: UITableView!

    let dialogUtil          = DialogUtility()
    let utilities           = Utilities()
    let dbclass             = DatabaseHelper()
    var arrayRequest        = [TransactionRequest]()
    var arrayApplication    = [PremiereLoyaltyCardList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblHistory.delegate     = self
        tblHistory.dataSource   = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.dialogUtil.showActivityIndicator(self.view)
        loadDetails()
    }

    func loadDetails(){
      
        do{
            let stringJSONPremiere  = dbclass.returnPremiere()
            let stringPremiereData  = stringJSONPremiere.data(using: .utf8)
            arrayApplication        = try JSONDecoder().decode([PremiereLoyaltyCardList].self, from: stringPremiereData!)
            
            let stringJSONRequest   = dbclass.returnTransactionRequest()
            let stringRequestData   = stringJSONRequest.data(using: .utf8)
            arrayRequest            = try JSONDecoder().decode([TransactionRequest].self, from: stringRequestData!)
            tblHistory.reloadData()
            self.dialogUtil.hideActivityIndicator(self.view)
        }
        catch{
            print("ERROR loadDetails: \(error)")
        }
        
        
    }
    
    func displayDetails(){
        let index = segmentTabs.selectedSegmentIndex
        do{
            if(index == 0){
                let stringJSONPremiere  = dbclass.returnPremiere()
                let stringPremiereData  = stringJSONPremiere.data(using: .utf8)
                arrayApplication        = try JSONDecoder().decode([PremiereLoyaltyCardList].self, from: stringPremiereData!)
            }
            else{
                let stringJSONRequest   = dbclass.returnTransactionRequest()
                let stringRequestData   = stringJSONRequest.data(using: .utf8)
                arrayRequest            = try JSONDecoder().decode([TransactionRequest].self, from: stringRequestData!)
            }
            tblHistory.reloadData()
        }
        catch{
            print("ERROR displayDetails: \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func segmentClicked(_ sender: UISegmentedControl) {
        let index = segmentTabs.selectedSegmentIndex
        tblHistory.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let index = segmentTabs.selectedSegmentIndex
        if(index == 0){
            return arrayApplication.count
        }
        else{
            return arrayRequest.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell     = tblHistory.dequeueReusableCell(withIdentifier: "cellHistory", for: indexPath) as! PremiereViewCell
        let indexTab = segmentTabs.selectedSegmentIndex
        
        if(indexTab == 0){
            let date    = arrayApplication[indexPath.row].created_at!
            let branch  = arrayApplication[indexPath.row].branch_name!
            let status  = arrayApplication[indexPath.row].status!
            let gender  = utilities.getUserGender()
            let dateOnly = utilities.removeTimeFromDatetime(stringDateTime: date)
            
            if(status == "approved"){
                cell.lblStatus.backgroundColor = #colorLiteral(red: 0.5725490196, green: 0.7803921569, blue: 0.2509803922, alpha: 1)
            }
            else if(status == "denied"){
                cell.lblStatus.backgroundColor = UIColor.red
            }
            else{
                cell.lblStatus.backgroundColor = #colorLiteral(red: 1, green: 0.7450980392, blue: 0, alpha: 1)
            }
            
            cell.imgHistory.image   = UIImage(named: "plc_\(gender)")
            cell.lblDate.text       = utilities.getCompleteDateString(stringDate: dateOnly)
            cell.lblContent.text    = branch.uppercased()
            cell.lblStatus.text     = status.capitalized
            
        }
        else{
            let date     = arrayRequest[indexPath.row].created_at
            let remarks  = arrayRequest[indexPath.row].remarks! ?? "None"
            let message  = arrayRequest[indexPath.row].message! ?? "None"
            let status   = arrayRequest[indexPath.row].status! ?? "None"
            
            if(status == "approved"){
                cell.lblStatus.backgroundColor = #colorLiteral(red: 0.5725490196, green: 0.7803921569, blue: 0.2509803922, alpha: 1)
            }
            else if(status == "denied"){
                cell.lblStatus.backgroundColor = UIColor.red
            }
            else{
                cell.lblStatus.backgroundColor = #colorLiteral(red: 1, green: 0.7450980392, blue: 0, alpha: 1)
            }
            
            let dateOnly = utilities.removeTimeFromDatetime(stringDateTime: date!)
            cell.lblDate.text       = utilities.getCompleteDateString(stringDate: dateOnly)
            cell.lblContent.text    = "Topic: \(remarks.capitalized)"
            cell.lblStatus.text     = status.capitalized
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let indexTab = segmentTabs.selectedSegmentIndex
        if(indexTab == 0){
            return "List of Previous PLC Application"
        }
        else{
            return "List of Transaction Request"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 120
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = self.tblHistory.indexPathForSelectedRow{
            self.tblHistory.deselectRow(at: index, animated: true)
        }
        
        var objectApplication:PremiereLoyaltyCardList?   = nil
        var objectRequest:TransactionRequest?            = nil
        let indexTab = segmentTabs.selectedSegmentIndex
        
        if(indexTab == 0){
            objectApplication = arrayApplication[indexPath.row]
        }
        else{
            objectRequest = arrayRequest[indexPath.row]
        }
        
        let storyBoard = UIStoryboard(name:"PremiereStoryboard",bundle:nil)
        let applicationVC  = storyBoard.instantiateViewController(withIdentifier: "PremiereHistoryDetailsController") as! PremiereHistoryDetailsController
        
        applicationVC.type              = indexTab
        applicationVC.objectApplication = objectApplication
        applicationVC.objectRequest     = objectRequest
        self.navigationController?.pushViewController(applicationVC, animated: true)
        
    }
    
   
}
