//
//  ProfileTab.swift
//  SampleProject
//
//  Created by Paolo Hilario on 5/21/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class UserProfileTab: UITableViewController{

    @IBOutlet weak var tblProfile: UITableView!
    @IBOutlet var lblClientName: UILabel!
    @IBOutlet var lblBranch: UILabel!
    @IBOutlet var imgClient: UIImageView!
    
    
    let diagUtil = DialogUtility()
    var client_id  = 0
    let dbclass    = DatabaseHelper()
    let utilities  = Utilities()
    var SERVER_URL = "";
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        SERVER_URL  = dbclass.returnIp()
        tblProfile.alwaysBounceVertical = false
        client_id   = utilities.getUserID()
        if(client_id > 0){
            print(utilities.getUserName())
            lblClientName.text = utilities.getUserName()
            lblBranch.text     = "\(utilities.getUserEmail())"
            let stringURL      = SERVER_URL+"/images/users/"+utilities.getUserImage()
            let myUrl          = URL(string: stringURL)
            imgClient.kf.setImage(with: myUrl)
        }
        else{
            lblClientName.text = "Hi Guest!"
            lblBranch.text     = "Please Login / Signup to continue"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
  
        if(client_id <= 0){
            if indexPath.row == 12 {
                return 350
            }
            else{
                return 0.0
            }
        }
        else{
            if indexPath.row == 0 {
                return 105.0
            }
            if indexPath.row == 12 {
                return 0.0
            }
            else{
                return 60
            }
        }
    }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigateToNextPage(position:indexPath.row)
    }
   
    func navigateToNextPage(position:Int){

        if(position == 0){
            let storyBoard = UIStoryboard(name:"UserProfile",bundle:nil)
            let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "UserProfileController") as! UserProfileController
            self.navigationController?.pushViewController(appointmentVC, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
        if(position == 1){
            
        }
        if(position == 2){
            
        }
        if(position == 3){
            
        }
        if(position == 4){
            
        }
        if(position == 5){
            
        }
        if(position == 6){
            
        }
        if(position == 7){
            
        }
        if(position == 8){
            
        }
        if(position == 9){
            let fbAppUrl = URL(string: "fb://page/?id=7037766039")
            let fbWebUrl = URL(string: "https://www.facebook.com/OfficialLayBare/")
            let openURL =  UIApplication.shared.canOpenURL(fbAppUrl!)
            if(UIApplication.shared.openURL(fbAppUrl!)){
                UIApplication.shared.openURL(fbAppUrl!)
            }
            else{
                UIApplication.shared.openURL(fbWebUrl!)
            }
        }
        if(position == 10){
            
        }
        if(position == 11){
            diagUtil.showActivityIndicator(self.view)
        }
        if(position == 12){
            
        }
        
    }
    
    
    @IBAction func btnLogin(_ sender: Any) {
        if let viewController = UIStoryboard(name: "LoginStoryboard", bundle: nil).instantiateViewController(withIdentifier: "LoginController") as? LoginController {
            if let navigator = navigationController {
                navigator.present(viewController, animated: true)
            }
        }
    }
    
    @IBAction func btnRegister(_ sender: Any) {
        if let viewController = UIStoryboard(name: "LoginStoryboard", bundle: nil).instantiateViewController(withIdentifier: "SignupController") as? SignupController {
            if let navigator = navigationController {
                navigator.present(viewController, animated: true)
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
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
