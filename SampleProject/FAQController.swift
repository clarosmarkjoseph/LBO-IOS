//
//  FAQController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/3/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Alamofire
import SQLite
import Kingfisher

class FAQController: UITableViewController {

    @IBOutlet var tblFAQCategory: UITableView!
    let utilities  = Utilities()
    let dbclass    = DatabaseHelper()
    var SERVER_URL = ""
    let dialogUtil = DialogUtility()
    var faqResult:FAQResultStruct?   = nil
    var faqQuestion = [FAQQuestionStruct]()
    var faqCategory = [FAQCategoryStruct]()
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        SERVER_URL = dbclass.returnIp()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        self.navigationItem.rightBarButtonItem              = self.editButtonItem
//        self.navigationItem.rightBarButtonItem?.tintColor   = UIColor.white
        getFAQ()
        
    }
    
    func getFAQ(){
        
        self.dialogUtil.showActivityIndicator(self.view)
        let faqURL = "\(SERVER_URL)/api/faq/getFAQs"
        Alamofire.request(faqURL, method: .get)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.loadFAQ()
                        return
                    }
                    if let responseJSONData = response.data{
                        if(statusCode == 200 || statusCode == 201){
                            let jsonString = self.utilities.convertDataToJSONString(data: responseJSONData)
                            let faq_tbl = self.dbclass.faq_tbl
                            do{
                                let date_updated = self.utilities.getCurrentDateTime(ifDateOrTime: "datetime")
                                let countData    = try self.dbclass.db?.scalar(faq_tbl.count)
                                if(countData! <= 0){
                                    self.dbclass.insertFAQ(objectString: jsonString, date_updated: date_updated)
                                }
                                else{
                                    self.dbclass.updateFAQ(objectString: jsonString, date_updated: date_updated)
                                }
                                self.loadFAQ()
                            }
                            catch{
                                print("ERROR DB Branch \(error)")
                            }
                            
                        }
                        else{
                            self.loadFAQ()
                            let objectResponse = response.result.value as! Dictionary<String, Any>
                            let arrayError = self.utilities.handleHttpResponseError(objectResponseError: objectResponse ,statusCode:statusCode)
                            self.showDialog(title:arrayError[0], message: arrayError[1])
                        }
                    }
                    else{
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                    }
                }
                catch{
                    print(response.error)
                    self.dialogUtil.hideActivityIndicator(self.view)
                    self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                }
        }
    }
    
    func loadFAQ(){
        do{
            let jsonString  = dbclass.returnFAQ()
            print(jsonString)
            let jsonData    = jsonString.data(using: .utf8)
            faqResult       = try JSONDecoder().decode(FAQResultStruct?.self, from: jsonData!)
            faqCategory     = faqResult?.category ?? [FAQCategoryStruct]()
            faqQuestion     = faqResult?.questions ?? [FAQQuestionStruct]()
            self.dialogUtil.hideActivityIndicator(self.view)
            if(faqCategory.count > 0){
                tblFAQCategory.reloadData()
            }
            else{
                self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
            }
        }
        catch{
            print("ERROR: \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return faqCategory.count
    }

 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblFAQCategory.dequeueReusableCell(withIdentifier: "cellFAQCategory", for: indexPath) as! FAQCategoryViewCell
        
        let title       = faqCategory[indexPath.row].title
        let image       = faqCategory[indexPath.row].image!
        let imgString   = "\(SERVER_URL)/\(image)"
        let imgURL      = URL(string: imgString)
        cell.lblCategoryTitle.text = title
        cell.imgCategory.kf.setImage(with: imgURL)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func showDialog(title:String,message:String){
        //alert box
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Retry", style: .default) { (action) in
            self.loadFAQ()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertView.addAction(confirm)
        alertView.addAction(cancel)
        present(alertView,animated: true,completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = self.tblFAQCategory.indexPathForSelectedRow{
            self.tblFAQCategory.deselectRow(at: index, animated: true)
        }
        let category_id = faqCategory[indexPath.row].category_id
        let storyBoard  = UIStoryboard(name:"OtherStoryboard",bundle:nil)
        let viewController              = storyBoard.instantiateViewController(withIdentifier: "FAQuestionController") as! FAQuestionController
        var questions = [FAQQuestionStruct]()
        for rows in faqQuestion{
            let category = Int(rows.category!) ?? 0
            if(category_id == category){
                questions.append(rows)
            }
        }
        viewController.arrayQuestions   = questions
        self.navigationController?.pushViewController(viewController, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
 
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
