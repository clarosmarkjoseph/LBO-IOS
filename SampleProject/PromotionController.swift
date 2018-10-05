//
//  PromotionController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/2/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Alamofire
import SQLite
import Kingfisher

class PromotionController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let dbclass         = DatabaseHelper()
    let utilities       = Utilities()
    var SERVER_URL      = ""
    let dialogUtil      = DialogUtility()
    var arrayPromotions = [PromotionStruct]()
    @IBOutlet var tblPromotions: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SERVER_URL                  = dbclass.returnIp()
        tblPromotions.delegate      = self
        tblPromotions.dataSource    = self
        getPromotions()
    }
    
    
    func getPromotions(){
        
        self.dialogUtil.showActivityIndicator(self.view)
        let promoURL = "\(SERVER_URL)/api/promotion/getPromotions"
        Alamofire.request(promoURL, method: .get)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.loadPromotions()
                        return
                    }
                    if let responseJSONData = response.data{
                        if(statusCode == 200 || statusCode == 201){
                            let jsonString = self.utilities.convertDataToJSONString(data: responseJSONData)
                            let promotion_tbl = self.dbclass.promotion_tbl
                            do{
                                let date_updated = self.utilities.getCurrentDateTime(ifDateOrTime: "datetime")
                                let countData    = try self.dbclass.db?.scalar(promotion_tbl.count)
                                if(countData! <= 0){
                                    self.dbclass.insertPromotion(arrayString: jsonString, date_updated: date_updated)
                                }
                                else{
                                    self.dbclass.updatePromotion(arrayString: jsonString, date_updated: date_updated)
                                }
                                self.loadPromotions()
                            }
                            catch{
                                print("ERROR DB Branch \(error)")
                            }
                            
                        }
                        else{
                            self.loadPromotions()
                            let objectResponse = response.result.value as! Dictionary<String, Any>
                            let arrayError = self.utilities.handleHttpResponseError(objectResponseError: objectResponse ,statusCode:statusCode)
                            self.showDialog(title:arrayError[0], message: arrayError[1])
                        }
                    }
                    else{
                        self.loadPromotions()
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                    }
                }
                catch{
                    print(response.error)
                    self.loadPromotions()
                    self.dialogUtil.hideActivityIndicator(self.view)
                    self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                }
        }
    }
    
    func loadPromotions(){
        
        self.dialogUtil.hideActivityIndicator(self.view)
        do{
            let jsonString  = dbclass.returnPromotions()
            let jsonData    = jsonString.data(using: .utf8)
            arrayPromotions = try JSONDecoder().decode([PromotionStruct].self, from: jsonData!)
            if (arrayPromotions.count > 0){
                self.tblPromotions.reloadData()
            }
            else{
                 self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
            }
        }
        catch{
             self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("COunt: \(arrayPromotions.count)")
        return arrayPromotions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
        return 130.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let position    = indexPath.row
        let cell        = tblPromotions.dequeueReusableCell(withIdentifier: "cellPromotions",for:indexPath) as! PromotionViewCell
        let promo_type  = arrayPromotions[position].type ?? ""
        let promo_title = arrayPromotions[position].title ?? ""
        let promo_desc  = arrayPromotions[position].description ?? ""
        var date_start  = arrayPromotions[position].date_start ?? ""
        var date_end    = arrayPromotions[position].date_end ?? ""
        let branches    = arrayPromotions[position].branches
        var date        = ""
        let promo_img   = arrayPromotions[position].promo_picture
        let imgURL      = URL(string: SERVER_URL+"/images/promotions/"+promo_img!)

        if(promo_type == "promo"){
            date_start  = utilities.removeTimeFromDatetime(stringDateTime: date_start)
            date_end    = utilities.removeTimeFromDatetime(stringDateTime: date_end)
            date        = "\(utilities.getCompleteDateString(stringDate: date_start)) - \(utilities.getCompleteDateString(stringDate: date_end))"
        }
        else{
            date = "For Display"
        }
        
        cell.lblTitle.text  = promo_title
        cell.imgPromotion.kf.setImage(with: imgURL,
                                        placeholder: UIImage(named: "noImage"),
                                        options: nil,
                                        progressBlock: nil,
                                        completionHandler: { (image: UIImage?, error: Error?, cache, url) in
                                            if error != nil {
                                                cell.imgPromotion.image = UIImage(named: "noImage")
                                            }
        })
        cell.lblDate.text = date
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objectPromotion = arrayPromotions[indexPath.row]
        let storyBoard = UIStoryboard(name:"OtherStoryboard",bundle:nil)
        let notificationVC  = storyBoard.instantiateViewController(withIdentifier: "NotificationDetailsController") as! NotificationDetailsController
        notificationVC.objectPromotions  = objectPromotion
        notificationVC.notification_type = "promotion"
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(notificationVC, animated: true)
        
    }
    
  
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  

}
