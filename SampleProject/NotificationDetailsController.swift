//
//  NotificationDetailsController.swift
//  Lay Bare Waxing PH
//
//  Created by Paolo Hilario on 9/20/18.
//  Copyright © 2018 itadmin. All rights reserved.
//
import UIKit

class NotificationDetailsController: UIViewController {

    @IBOutlet var lblContent: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var imgPromo: UIImageView!
    let utilities   = Utilities()
    let dbclass     = DatabaseHelper()
    var notification_type = ""
    var objectPromotions:PromotionStruct? = nil
    var objectNotification:UserNotification? = nil
    var promotion_id = 0
    var SERVER_URL = ""
    let dialogUtil = DialogUtility()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SERVER_URL = dbclass.returnIp()
        lblContent.numberOfLines = 0
        lblContent.lineBreakMode = .byWordWrapping
        initElements()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initElements(){
        if(notification_type == "promotion"){
            self.navigationItem.title = "Promotions"
            getPromotions()
        }
        if(notification_type == "campaign_manager"){
            self.navigationItem.title = "Campaign Manager"
            getCampaignManager()
        }
    }
    
    func getPromotions(){
        if(objectPromotions == nil){
            self.dialogUtil.hideActivityIndicator(self.view)
            do{
                let jsonString      = dbclass.returnPromotions()
                let jsonData        = jsonString.data(using: .utf8)
                let arrayPromotions = try JSONDecoder().decode([PromotionStruct].self, from: jsonData!)
                for rows in arrayPromotions{
                    let res_id = rows.id ?? 0
                    if(res_id == promotion_id){
                        objectPromotions = rows
                        setPromotion()
                        break
                    }
                }
            }
            catch{
                self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
            }
        }
        else{
            setPromotion()
        }
    }
    
    func setPromotion(){
        
        let promo_type  = objectPromotions?.type ?? ""
        let promo_title = objectPromotions?.title ?? ""
        let promo_desc  = objectPromotions?.description ?? ""
        var date_start  = objectPromotions?.date_start ?? ""
        var date_end    = objectPromotions?.date_end ?? ""
        let promo_img   = objectPromotions?.promo_picture ?? "no%20photo.jpg"
        let imgURL      = URL(string: SERVER_URL+"/images/promotions/"+promo_img)
        var date        = ""
        
        if(promo_type == "promo"){
            date_start  = utilities.removeTimeFromDatetime(stringDateTime: date_start)
            date_end    = utilities.removeTimeFromDatetime(stringDateTime: date_end)
            date        = "\(utilities.getCompleteDateString(stringDate: date_start)) - \(utilities.getCompleteDateString(stringDate: date_end))"
        }
        else{
            date = "For Display"
        }
        lblDate.text        = date
        lblTitle.text       = promo_title
        let data            = promo_desc.data(using: String.Encoding.unicode)
        let attrStr         = try? NSAttributedString( // do catch
                data: data!,
                options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil
        )
        lblContent.textColor        = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
        lblContent.attributedText   = attrStr
        lblContent.font             = UIFont.systemFont(ofSize: 18)
        imgPromo.isHidden           = false
        imgPromo.kf.setImage(with: imgURL,
                             placeholder: UIImage(named: "noImage"),
                             options: nil,
                             progressBlock: nil,
                             completionHandler: { (image: UIImage?, error: Error?, cache, url) in
                                if error != nil {
                                    self.imgPromo.image = UIImage(named: "noImage")
                                }
        })
    }
    
    
    func getCampaignManager(){
        imgPromo.isHidden   = true
        let title       = objectNotification?.notification_data?.title ?? "No Title"
        let message     = objectNotification?.notification_data?.body ?? "No Content"
        let unique_id   = objectNotification?.notification_data?.unique_id ??  0
        let created_at  = objectNotification?.created_at ?? utilities.getCurrentDateTime(ifDateOrTime: "datetime")
        let date        = utilities.getCompleteDateTimeString(stringDate: created_at)

        lblContent.textColor        = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
        lblContent.text             = message
        lblDate.text                = date
        lblTitle.text               = title
       
    }
    

   
    
    func showDialog(title:String,message:String){
        //alert box
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            
        }
        alertView.addAction(confirm)
        present(alertView,animated: true,completion: nil)
    }
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
