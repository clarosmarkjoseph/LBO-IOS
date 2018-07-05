//
//  ProductSegmentController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 5/23/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit

class ProductSegmentController: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    @IBOutlet weak var tblProduct: UITableView!
    let dbclass     = DatabaseHelper()
    let utilities   = Utilities()
    let dialogUtils = DialogUtility()
    var modelProducts:[ArrayProducts]!
    var SERVER_URL  = ""
    var viewType    = ""
    var delegateAppointment:ProtocolAddItem? = nil
    
    override func viewDidLoad() {
        tblProduct.delegate      = self
        tblProduct.dataSource    = self
        SERVER_URL = dbclass.returnIp()
        loadProduct()
        super.viewDidLoad()
        
    }

    func loadProduct() {
        self.dialogUtils.showActivityIndicator(self.view)
        let product_tbl = dbclass.product_tbl
        do{
            if let queryProduct = try dbclass.db?.pluck(product_tbl) {
                let arrayStringProduct  = queryProduct[dbclass.product_array]
                let jsonData            = arrayStringProduct.data(using: .utf8)
                modelProducts           = try JSONDecoder().decode([ArrayProducts].self, from: jsonData!)
            }
            self.dialogUtils.hideActivityIndicator(self.view)
        }
        catch{
            print("ERROR DB SERVICE \(error)")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell                        = tblProduct.dequeueReusableCell(withIdentifier: "cellProduct") as! ServicePackageTableCellView
        let image                       = modelProducts[indexPath.row].product_picture!
        let product_name                = modelProducts[indexPath.row].product_group_name!
        let product_desc                = modelProducts[indexPath.row].product_description!
        let product_price:Double        = modelProducts[indexPath.row].product_price ?? 0.0
        let myURL                       = URL(string:SERVER_URL+"/images/products/\(image)")
        cell.lblServiceName.text        = product_name
        cell.lblServiceDesc.text        = product_desc
        cell.lblServicePrice.text       = "Php \(product_price)"
        cell.imgServicePackage.kf.setImage(with: myURL)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let position        = indexPath.row
        if(viewType == "appointment"){
            let id              = modelProducts[position].id!
            let item_name       = modelProducts[position].product_group_name!
            let item_price      = modelProducts[position].product_price!
            let item_duration   = 0
            let item_image      = modelProducts[position].product_picture!
            let item_size       = modelProducts[position].product_size!
            let item_variation  = modelProducts[position].product_variant!
            self.navigationController?.popViewController(animated: true)
            delegateAppointment?.setNewItems(id: id, itemName: item_name, quantity: 1,price:item_price, duration: item_duration, item_type: "products",item_image: item_image,item_size:item_size,type_id: 0,type_data: "",item_variation:item_variation)
        }
        else{
            let myVC            = storyboard?.instantiateViewController(withIdentifier: "ItemDetailViewController") as! ItemDetailViewController
            let objectProduct   = modelProducts[position]
            myVC.item_name      = objectProduct.product_group_name!
            myVC.item_desc      = objectProduct.product_description!
            myVC.item_image     = objectProduct.product_picture!
            myVC.item_price     = objectProduct.product_price!
            myVC.item_size      = objectProduct.product_size!
            myVC.item_variant   = objectProduct.product_variant!
            myVC.item_id        = objectProduct.id!
            myVC.item_type      = "product"
            myVC.viewType       = self.viewType
            navigationController?.pushViewController(myVC, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let index = self.tblProduct.indexPathForSelectedRow{
            self.tblProduct.deselectRow(at: index, animated: true)
        }
    }
    

}
