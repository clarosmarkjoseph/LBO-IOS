//
//  ServiceSegmentController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 5/23/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import SQLite
import Alamofire

protocol ProtocolAddItem {
    func setNewItems(id:Int,itemName:String,quantity:Int,price:Double,duration:Int,item_type:String,item_image:String,item_size:String,type_id:Int,type_data:String,item_variation:String)
}

class ServiceSegmentController:UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tblServicePackage: UITableView!
    let dbclass     = DatabaseHelper()
    let utilities   = Utilities()
    let dialogUtils = DialogUtility()
    var modelServices:[ArrayServices]!
    var SERVER_URL   = ""
    var viewType     = ""
    var clientGender = ""
    var delegateAppointment:ProtocolAddItem? = nil
    
    override func viewDidLoad() {
        tblServicePackage.delegate      = self
        tblServicePackage.dataSource    = self
        SERVER_URL                      = dbclass.returnIp()
        clientGender                    = utilities.getUserGender()
        loadServices()
        super.viewDidLoad()
    }

    func loadServices() {
        self.dialogUtils.showActivityIndicator(self.view)
        let service_tbl = dbclass.service_tbl
        do{
            if let queryServices = try dbclass.db?.pluck(service_tbl) {
                let arrayStringServices = queryServices[dbclass.service_array]
                let jsonData            = arrayStringServices.data(using: .utf8)
                let resultServices      = try JSONDecoder().decode([ArrayServices].self, from: jsonData!)
                if(clientGender != nil){
                    modelServices = [ArrayServices]()
                    for rows in resultServices{
                        let resGender = rows.service_gender
                        if(clientGender.lowercased() == resGender?.lowercased()){
                            modelServices.append(rows)
                        }
                    }
                }
                else{
                    modelServices = resultServices
                }
            }
            self.dialogUtils.hideActivityIndicator(self.view)
        }
        catch{
            print("ERROR DB SERVICE \(error)")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelServices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblServicePackage.dequeueReusableCell(withIdentifier: "cellServicePackage") as! ServicePackageTableCellView
        let image                   = modelServices[indexPath.row].service_picture!
        let service_name            = modelServices[indexPath.row].service_name!
        let service_desc            = modelServices[indexPath.row].service_description!
        let service_price:Double    = modelServices[indexPath.row].service_price ?? 0.0
        let service_gender          = modelServices[indexPath.row].service_gender!
        let myURL                   = URL(string:SERVER_URL+"/images/services/\(image)")
        
        cell.lblServiceName.text    = service_name
        cell.lblServiceDesc.text    = service_desc
        cell.lblServicePrice.text   = "Php \(service_price)"
        cell.imgServiceGender.image = UIImage(named: service_gender)
        cell.imgServicePackage.kf.setImage(with: myURL)
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let position        = indexPath.row
        
        if(viewType == "appointment"){
            let id              = modelServices[position].id!
            let item_name       = modelServices[position].service_name!
            let item_price      = modelServices[position].service_price!
            let item_duration   = modelServices[position].service_minutes!
            let item_image      = modelServices[position].service_picture!
            let item_type_id    = modelServices[position].service_type_id!
            let item_type_data  = String(modelServices[position].service_type_data!)
            self.navigationController?.popViewController(animated: true)
            delegateAppointment?.setNewItems(id: id, itemName: item_name, quantity: 1,price:item_price, duration: item_duration, item_type: "services",item_image: item_image,item_size:"",type_id: item_type_id,type_data: item_type_data,item_variation:"")
            
        }
        else{
            let myVC            = storyboard?.instantiateViewController(withIdentifier: "ItemDetailViewController") as! ItemDetailViewController
            let objectService = modelServices[position]
            myVC.item_name      = objectService.service_name!
            myVC.item_desc      = objectService.service_description!
            myVC.item_image     = objectService.service_picture!
            myVC.item_price     = objectService.service_price!
            myVC.item_duration  = objectService.service_minutes!
            myVC.item_gender    = objectService.service_gender!
            myVC.item_id        = objectService.id!
            myVC.item_type      = "services"
            myVC.viewType       = self.viewType
            navigationController?.pushViewController(myVC, animated: true)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tblServicePackage.indexPathForSelectedRow{
            self.tblServicePackage.deselectRow(at: index, animated: true)
        }
    }

}
