//
//  PackagesSegmentController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 5/23/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit

class PackagesSegmentController: UIViewController,UITableViewDelegate,UITableViewDataSource {
 
    @IBOutlet weak var tblPackage: UITableView!
    let dbclass     = DatabaseHelper()
    let utilities   = Utilities()
    let dialogUtils = DialogUtility()
    var modelPackages:[ArrayPackage]!
    var SERVER_URL   = ""
    var viewType     = ""
    var clientGender = ""
    var delegateAppointment:ProtocolAddItem? = nil
    
    
    override func viewDidLoad() {
        tblPackage.delegate     = self
        tblPackage.dataSource   = self
        SERVER_URL              = dbclass.returnIp()
        clientGender            = utilities.getUserGender()
        loadPackage()
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadPackage() {
        self.dialogUtils.showActivityIndicator(self.view)
        let package_tbl = dbclass.package_tbl
        do{
            if let queryPackage = try dbclass.db?.pluck(package_tbl) {
                let arrayStringPackage  = queryPackage[dbclass.package_array]
                let jsonData            = arrayStringPackage.data(using: .utf8)
                let resultPackages      = try JSONDecoder().decode([ArrayPackage].self, from: jsonData!)
                if(clientGender != ""){
                    modelPackages = [ArrayPackage]()
                    for rows in resultPackages{
                        let resGender = rows.package_gender
                        if(clientGender.lowercased() == resGender?.lowercased()){
                            modelPackages.append(rows)
                        }
                    }
                }
                else{
                    modelPackages = resultPackages
                }
            }
            self.dialogUtils.hideActivityIndicator(self.view)
        }
        catch{
            print("ERROR DB SERVICE \(error)")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelPackages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell                = tblPackage.dequeueReusableCell(withIdentifier: "cellPackage") as! ServicePackageTableCellView
        let image                = modelPackages[indexPath.row].package_image!
        let service_name         = modelPackages[indexPath.row].package_name!
        let service_desc         = modelPackages[indexPath.row].package_desc!
        let service_price:Double = modelPackages[indexPath.row].package_price ?? 0.0
        let service_gender       = modelPackages[indexPath.row].package_gender!
        let myURL                = URL(string:SERVER_URL+"/images/services/\(image)")
        
        cell.lblServiceName.text    = service_name
        cell.lblServiceDesc.text    = service_desc
        cell.lblServicePrice.text   = utilities.convertToStringCurrency(value: "\(service_price)")
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
            let id              = modelPackages[position].id!
            let item_name       = modelPackages[position].package_name!
            let item_price      = modelPackages[position].package_price!
            let item_duration   = modelPackages[position].package_duration!
            let item_image      = modelPackages[position].package_image!
            let item_type_id    = modelPackages[position].service_package_id!
            var stringType_data = ""
            if let item_type_data  = modelPackages[position].package_services{
                stringType_data = item_type_data.description
            }
            else{
                stringType_data = "[]"
            }
            self.navigationController?.popViewController(animated: true)
            delegateAppointment?.setNewItems(id: id, itemName: item_name, quantity: 1,price:item_price, duration: item_duration, item_type: "packages",item_image: item_image,item_size:"",type_id: item_type_id,type_data: stringType_data,item_variation:"")
            
        }
        else{
            
            let myVC            = storyboard?.instantiateViewController(withIdentifier: "ItemDetailViewController") as! ItemDetailViewController
            let objectPackage   = modelPackages[position]
            myVC.item_name      = objectPackage.package_name!
            myVC.item_desc      = objectPackage.package_desc!
            myVC.item_image     = objectPackage.package_image!
            myVC.item_price     = objectPackage.package_price!
            myVC.item_duration  = objectPackage.package_duration!
            myVC.item_gender    = objectPackage.package_gender!
            myVC.item_id        = objectPackage.id!
            myVC.item_type      = "services"
            myVC.viewType       = self.viewType
            navigationController?.pushViewController(myVC, animated: true)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tblPackage.indexPathForSelectedRow{
            self.tblPackage.deselectRow(at: index, animated: true)
        }
    }

}
