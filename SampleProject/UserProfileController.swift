//
//  UserProfileController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/20/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit

class UserProfileController: UITableViewController {

    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblClientName: UILabel!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var lblBday: UILabel!
    @IBOutlet var lblContact: UILabel!
    @IBOutlet var lblGender: UILabel!
    @IBOutlet var lblHomeBranch: UILabel!
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var btnImgProfile: UIButton!
    @IBOutlet var tblProfile: UITableView!
    var objectUserAccount:ObjectUserAccount? = nil
    let utilities   = Utilities()
    let dbclass     = DatabaseHelper()
    var SERVER_URL  = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SERVER_URL = dbclass.returnIp()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
         loadProfileDetails()
    }

    func loadProfileDetails(){
        let user_tbl            = dbclass.user_tbl
        do{
            if let queryUser   = try dbclass.db?.pluck(user_tbl){
                let stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUserAccount       = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                let clientName          = try objectUserAccount?.username ?? "N/A"
                let clientGender        = try objectUserAccount?.gender ?? "N/A"
                let clientAddress       = try objectUserAccount?.user_address ?? "N/A"
                let clientBday          = try objectUserAccount?.birth_date ?? "0000-00-00"
                let clientMobile        = try objectUserAccount?.user_mobile ?? "N/A"
                let clientEmail         = try objectUserAccount?.email ?? "N/A"
                var clientImage         = try objectUserAccount?.user_picture ?? "no image \(clientGender.lowercased()).png"
                let clientData          = try objectUserAccount?.user_data ?? "{}"
                let objectUserData      = utilities.convertJSONStringToData(arrayString: clientData)
                let objectUserDecoded   = try JSONDecoder().decode(ObjectUserData.self, from: objectUserData)
                let clientBranchID      = objectUserDecoded.home_branch
                let clientBranchName    = utilities.getBranchName(branch_id: clientBranchID!)
                
                lblClientName.text      = clientName
                lblBday.text            = utilities.getCompleteDateString(stringDate: clientBday)
                lblContact.text         = clientMobile
                lblGender.text          = clientGender.capitalized
                lblHomeBranch.text      = clientBranchName
                lblEmail.text           = clientEmail
                lblAddress.text         = clientAddress
                clientImage             = clientImage.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
                let stringURL           = SERVER_URL+"/images/users/"+clientImage
                let url                 = URL(string: stringURL)
                print("IAGE :URL : \(stringURL)")
                imgProfile.kf.setImage(with: url)
                tblProfile.reloadData()
            }
            else{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        catch{
            print("User retrieve error: \(error)")
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let index = self.tblProfile.indexPathForSelectedRow{
            self.tblProfile.deselectRow(at: index, animated: true)
        }
        
        if(indexPath.row == 2){
            let storyBoard      = UIStoryboard(name:"UserProfile",bundle:nil)
            let viewcontroller  = storyBoard.instantiateViewController(withIdentifier: "UserProfileEditController") as! UserProfileEditController
            viewcontroller.indexPosition = 0
            self.navigationController?.pushViewController(viewcontroller, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
        if(indexPath.row == 4){
            let storyBoard      = UIStoryboard(name:"UserProfile",bundle:nil)
            let viewcontroller  = storyBoard.instantiateViewController(withIdentifier: "UserProfileEditController") as! UserProfileEditController
            viewcontroller.indexPosition = 1
            self.navigationController?.pushViewController(viewcontroller, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
        if(indexPath.row == 6){
            let storyBoard      = UIStoryboard(name:"UserProfile",bundle:nil)
            let viewcontroller  = storyBoard.instantiateViewController(withIdentifier: "UserProfileEditController") as! UserProfileEditController
            viewcontroller.indexPosition = 2
            self.navigationController?.pushViewController(viewcontroller, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
        else{
            print("indexPath.row \(indexPath.row)")
            return
        }
    }
    
 
    
}
