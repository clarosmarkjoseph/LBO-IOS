//
//  BranchController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/6/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit

protocol ProtocolBranch {
    func setBranch(selectedBranch:String,selectedBranchID:Int,objectBranch:ArrayBranch)
}

class BranchController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet var tblBranch: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    let dbclass               = DatabaseHelper()
    let utilities             = Utilities()
    var ifAppointment:Bool?   = nil
    var arrayBranches         = [ArrayBranch]()
    var arrayFilteredBranches = [ArrayBranch]()
    var isSearching               = false
    var delegate: ProtocolBranch? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblBranch.delegate      = self
        tblBranch.dataSource    = self
        searchBar.delegate      = self
        searchBar.returnKeyType = UIReturnKeyType.done
        loadBranches()
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
        
        if(isSearching == true){
            branch_name     = arrayFilteredBranches[indexPath.row].branch_name!
            branch_address  = arrayFilteredBranches[indexPath.row].branch_address!
        }
        else{
            branch_name     = arrayBranches[indexPath.row].branch_name!
            branch_address  = arrayBranches[indexPath.row].branch_address!
        }
        
        cell.lblBranchName.text    = branch_name
        cell.lblBranchDesc.text    = branch_address
     
        
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
            delegate?.setBranch(selectedBranch: branch_name, selectedBranchID: branch_id,objectBranch:arrayFilteredBranches[indexPath.row])
        }
        else{
            branch_id   = arrayBranches[indexPath.row].id!
            branch_name = arrayBranches[indexPath.row].branch_name!
            delegate?.setBranch(selectedBranch: branch_name, selectedBranchID: branch_id,objectBranch:arrayBranches[indexPath.row])
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
                if (arrayBranchName.branch_name?.contains(searchBar.text!))!{
                    return true
                }
                if (arrayBranchName.branch_address?.contains(searchBar.text!))!{
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
