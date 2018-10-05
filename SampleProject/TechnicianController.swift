//
//  TechnicianController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/7/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
protocol ProtocolTechnician {
    func setTechnician(id:Int,techName:String,start_time:String,end_time:String,employee_id:String)
}
class TechnicianController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tblTechnician: UITableView!
    let dbclass                       = DatabaseHelper()
    let utilities                     = Utilities()
    var ifAppointment:Bool?           = nil
    var arrayTechnician               = [ArrayTechnician]()
    var arrayFilteredTechnician       = [ArrayTechnician]()
    var isSearching                   = false
    var delegate: ProtocolTechnician? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblTechnician.delegate      = self
        tblTechnician.dataSource    = self
        searchBar.delegate          = self
        searchBar.returnKeyType     = UIReturnKeyType.done
        loadTechnicians()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadTechnicians(){
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching{
            return arrayFilteredTechnician.count
        }
        return arrayTechnician.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell                    = tblTechnician.dequeueReusableCell(withIdentifier: "cellTechnician") as! TechnicianViewCell
        var technician_name         = ""
        var technician_sched        = ""
        
        if(isSearching == true){
            technician_name     = arrayFilteredTechnician[indexPath.row].name!
            let schedule_start  = arrayFilteredTechnician[indexPath.row].schedule!.start
            let schedule_end    = arrayFilteredTechnician[indexPath.row].schedule!.end
            technician_sched    = utilities.getStandardTime(stringTime: schedule_start!)+" - "+utilities.getStandardTime(stringTime:schedule_end!)
        }
        else{
            technician_name   = arrayTechnician[indexPath.row].name!
            let schedule_start  = arrayTechnician[indexPath.row].schedule!.start
            let schedule_end    = arrayTechnician[indexPath.row].schedule!.end
            technician_sched    = utilities.getStandardTime(stringTime:schedule_start!)+" - "+utilities.getStandardTime(stringTime:schedule_end!)
        }
        
        cell.lblTechnicianName.text   = technician_name
        cell.lblTechnicianSched.text  = technician_sched
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 97
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = self.tblTechnician.indexPathForSelectedRow{
            self.tblTechnician.deselectRow(at: index, animated: true)
        }
        
        var technician_id   = 0
        var technician_name = ""
        if(isSearching == true){
            technician_id       = arrayFilteredTechnician[indexPath.row].id!
            technician_name     = arrayFilteredTechnician[indexPath.row].name!
            let employee_id     = arrayFilteredTechnician[indexPath.row].employee_id ?? "0"
            let schedule_start  = arrayFilteredTechnician[indexPath.row].schedule!.start
            let schedule_end    = arrayFilteredTechnician[indexPath.row].schedule!.end
            delegate?.setTechnician(id: technician_id, techName: technician_name, start_time: schedule_start!, end_time: schedule_end!, employee_id: employee_id)
        }
        else{
            technician_id       = arrayTechnician[indexPath.row].id!
            technician_name     = arrayTechnician[indexPath.row].name!
            let employee_id     = arrayTechnician[indexPath.row].employee_id ?? "0"
            let schedule_start  = arrayTechnician[indexPath.row].schedule!.start
            let schedule_end    = arrayTechnician[indexPath.row].schedule!.end
            delegate?.setTechnician(id: technician_id, techName: technician_name, start_time: schedule_start!, end_time: schedule_end!, employee_id: employee_id)
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
            tblTechnician.reloadData()
        }
        else{
            isSearching = true
            arrayFilteredTechnician = arrayTechnician.filter({(arrayTechName:ArrayTechnician) -> Bool in
                if (arrayTechName.name?.lowercased().contains(searchBar.text!.lowercased()))!{
                    return true
                }
                else{
                    return false
                }
            })
            tblTechnician.reloadData()
        }
    }
    
    
    @IBAction func dismissTechnician(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
