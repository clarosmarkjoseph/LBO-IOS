//
//  PremiereCardPreviewController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/29/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit

class PremiereCardPreviewController: UIViewController {

    let utilities     = Utilities()
    let dbclass       = DatabaseHelper()
    var positionIndex = 0
    @IBOutlet var imgCard: UIImageView!
    @IBOutlet var uiviewDetails: UIView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblBranch: UILabel!
    @IBOutlet var lblBossID: UILabel!
    @IBOutlet var lblBday: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let value = UIInterfaceOrientation.landscapeLeft.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")
//        print("Position View: \(positionIndex)")
        loadDetails()
    }
    
    func loadDetails(){
        
        let client_gender = utilities.getUserGender()
        self.setupCardImage(client_gender:client_gender.lowercased())
        if(positionIndex == 1){
            let client_name                 = utilities.getUserName()
            let client_boss_id              = utilities.getUserBOSSID()
            let client_premiere_branch_id   = utilities.getUserPremierBranchID()
            let client_premiere_branch_name = utilities.getBranchName(branch_id: client_premiere_branch_id)
            let client_bday                 = utilities.getCompleteDateString(stringDate: utilities.getUserBirthday())
            lblName.text    = client_name
            lblBranch.text  = client_premiere_branch_name
            lblBday.text    = client_bday
            lblBossID.text  = client_boss_id
            
        }
     
    }
    
    func setupCardImage(client_gender:String){
        
        if(positionIndex == 0){
            uiviewDetails.isHidden = true
            imgCard.image = UIImage(named: "plc_\(client_gender)" )
        }
        else{
            uiviewDetails.isHidden = false
            imgCard.image = UIImage(named: "plc_\(client_gender)_back" )
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  
    @IBAction func btnCloseCard(_ sender: Any) {
        self.navigationController?.isNavigationBarHidden    = false
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    

}
