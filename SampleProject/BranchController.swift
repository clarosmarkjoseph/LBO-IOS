//
//  BranchController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/6/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit

protocol ProtocolBranch {
    func setBranch(selectedBranch:String,selectedBranchID:Int,objectSelectedBranch:ArrayBranch,arrayIndex:Int)
}

class BranchController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet var tblBranch: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    let dbclass               = DatabaseHelper()
    let utilities             = Utilities()
    var ifAppointment:Bool?   = nil
    var arrayBranches         = [ArrayBranch]()
    var arrayFilteredBranches = [ArrayBranch]()
    var isSearching           = false
    var ifLocation            = false
    var delegate: ProtocolBranch? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblBranch.delegate      = self
        tblBranch.dataSource    = self
        searchBar.delegate      = self
        searchBar.returnKeyType = UIReturnKeyType.done
    }
    
    
    override func viewWillLayoutSubviews() {
        if ifLocation == false{
            loadBranches()
        }
        else{
           
        }
    }
    
    
    func loadBranches(){
        let branch_tbl = dbclass.branch_tbl
        do{
            if let queryBranch          = try dbclass.db?.pluck(branch_tbl) {
                let arrayStringBranch   = queryBranch[dbclass.branch_array]
                let jsonData            = arrayStringBranch.data(using: .utf8)
                arrayBranches           = try JSONDecoder().decode([ArrayBranch].self, from: jsonData!)
            }
        }
        catch{
            print("ERROR DB Branch \(error)")
        }
    }
    
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching{
            return arrayFilteredBranches.count
        }
        return arrayBranches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell                    = tblBranch.dequeueReusableCell(withIdentifier: "cellBranch") as! BranchViewCell
        var branch_name             = ""
        var branch_address          = ""
        
        if ifLocation == true{
            var default_distance = 0.0
            var default_duration = ""
            var statementDesc    = ""
            if(isSearching == true){
                branch_name         = arrayFilteredBranches[indexPath.row].branch_name!
                default_distance    = arrayFilteredBranches[indexPath.row].estimated_distance!
                default_duration    = arrayFilteredBranches[indexPath.row].estimated_travel_time ?? "0 min"
            }
            else{
                branch_name         = arrayBranches[indexPath.row].branch_name!
                default_distance    = arrayBranches[indexPath.row].estimated_distance!
                default_duration    = arrayBranches[indexPath.row].estimated_travel_time ?? "0 min"
            }
            
            if default_duration == "0 min"{
                statementDesc = "\(default_distance) km away from your current location"
            }
            else{
                statementDesc = "\(default_distance) km away from your current location"
                cell.lblBranchDistance.text     = "Travel Time: \(default_duration)"
                cell.lblBranchDistance.isHidden = false
            }
            cell.lblBranchDesc.text         = statementDesc
        }
        else{
            if(isSearching == true){
                branch_name     = arrayFilteredBranches[indexPath.row].branch_name!
                branch_address  = arrayFilteredBranches[indexPath.row].branch_address!
            }
            else{
                branch_name     = arrayBranches[indexPath.row].branch_name!
                branch_address  = arrayBranches[indexPath.row].branch_address!
            }
            cell.lblBranchDesc.text    = branch_address
        }
        cell.lblBranchName.text     = branch_name
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 97
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = self.tblBranch.indexPathForSelectedRow{
            self.tblBranch.deselectRow(at: index, animated: true)
        }
        
        var branch_id   = 0
        var branch_name = ""
        if(isSearching == true){
            branch_id   = arrayFilteredBranches[indexPath.row].id!
            branch_name = arrayFilteredBranches[indexPath.row].branch_name!
            delegate?.setBranch(selectedBranch: branch_name, selectedBranchID: branch_id,objectSelectedBranch:arrayFilteredBranches[indexPath.row],arrayIndex: indexPath.row)
        }
        else{
            branch_id   = arrayBranches[indexPath.row].id!
            branch_name = arrayBranches[indexPath.row].branch_name!
            delegate?.setBranch(selectedBranch: branch_name, selectedBranchID: branch_id,objectSelectedBranch:arrayBranches[indexPath.row],arrayIndex: indexPath.row)
        }
       
        self.dismiss(animated: true, completion: nil)
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    //searchbar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text == nil || searchBar.text == "") {
            isSearching = false
            tblBranch.reloadData()
        }
        else{
            isSearching = true
            arrayFilteredBranches = arrayBranches.filter({(arrayBranchName:ArrayBranch) -> Bool in
                if (arrayBranchName.branch_name?.lowercased().contains(searchBar.text!.lowercased()))!{
                    return true
                }
                if (arrayBranchName.branch_address?.lowercased().contains(searchBar.text!.lowercased()))!{
                    return true
                }
                else{
                    return false
                }
            })
            tblBranch.reloadData()
        }
    }
    
    
    
    
    @IBAction func dismissBranch(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
   

}
