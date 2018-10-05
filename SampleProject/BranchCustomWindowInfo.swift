//
//  BranchCustomWindowInfo.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/10/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import Foundation
import Alamofire

protocol ProtocolLocationButton: class {
    func buttonPressed(objectRating:BranchObjectRatingResult,index:Int,distance:Double,duration:String)
}

class BranchCustomWindowInfo:UIViewController{
    
    @IBOutlet var lblBranchName: UILabel!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var lblDistance: UILabel!
    @IBOutlet var lblDuration: UILabel!
    @IBOutlet var lblAverageRating: UILabel!
    @IBOutlet var lblTotalReview: UILabel!
    @IBOutlet var stackviewLoader: UIStackView!
    @IBOutlet var stackViewDetails: UIStackView!
    @IBOutlet var btnPreview: UIButton!
    
    var delegateButton:ProtocolLocationButton?
    var objectBranchDetails:ArrayBranch?        = nil
    var objectRating:BranchObjectRatingResult?  = nil
    var current_lng         = 0.0
    var current_lat         = 0.0
    var default_branch_lat  = 0.0
    var default_branch_lng  = 0.0
    var estimated_distance  = 0.0
    var estimated_duration  = ""
    var offset              = 0
    var index               = 0
    let utilities           = Utilities()
    let dbclass             = DatabaseHelper()
    let dialogUtil          = DialogUtility()
    var SERVER_URL          = ""
    var googleAPIDistance   = ""
    
    
    override func viewDidLoad() {
        SERVER_URL = dbclass.returnIp()
        btnPreview.isEnabled = false
        btnPreview.alpha     = 0.5
        loadDetails()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func loadDetails(){
        lblBranchName.text  = objectBranchDetails?.branch_name
        lblAddress.text     = objectBranchDetails?.branch_address
        default_branch_lat  = Double(objectBranchDetails?.map_coordinates?.lat ?? 0.0)
        default_branch_lng  = Double(objectBranchDetails?.map_coordinates?.long ?? 0.0)
        getBranchDuration()
    }
    
    func getBranchDuration(){
        
        let branch_id       = objectBranchDetails?.id ?? 0
        let stringURL       = SERVER_URL+"/api/mobile/getBranchRatings"
        let requestParams   = [
            "branch_id":"\(branch_id)",
            "offset":offset,
            "long":current_lng,
            "lat":current_lat,
            "default_distance":estimated_distance,
            "default_duration":estimated_duration,
            "destination_long":default_branch_lng,
            "destination_lat":default_branch_lat,
            "getAllDetails":"true"
            ] as [String : Any]
        let myURL = URL(string: stringURL)
        Alamofire.request(myURL!, method: .post, parameters: requestParams)
            .responseJSON { response in
                
                
                do{
                    self.dialogUtil.hideActivityIndicator(self.view)                    
                    guard let statusCode   = try response.response?.statusCode else {
                        self.displayWithoutResult()
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                        return
                    }
                    
                    if let responseJSONData = response.data{
                        if(statusCode == 200 || statusCode == 201){
                            self.objectRating = try JSONDecoder().decode(BranchObjectRatingResult.self, from: responseJSONData)
                            self.displayDetails()
                        }
                        else{
                            self.displayWithoutResult()
                            let responseValue = response.result.value
                            if responseValue != nil{
                                let arrayError = self.utilities.handleHttpResponseError(objectResponseError: responseValue as! Dictionary<String, Any> ,statusCode:statusCode)
                                self.showDialog(title:arrayError[0], message: arrayError[1])
                            }
                            else{
                                self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                            }
                        }
                    }
                    else{
                        self.displayWithoutResult()
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                    }
                }
                catch{
                    print("Error BRanch Res: \(error)")
                    self.displayWithoutResult()
                    self.dialogUtil.hideActivityIndicator(self.view)
                    self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                }
        }
    }
    
    func displayDetails(){
        
        estimated_distance      = Double(objectRating?.distance ?? 0.0)
        estimated_duration      = objectRating?.duration ?? "0 min"
        
        let stringDistance      = utilities.convertDistanceToString(distance:estimated_distance)
        let averageRating       = objectRating?.totalRatings ?? 0.0
        let totalReview         = objectRating?.totalReviews ?? 0
        
        offset                  = objectRating?.offset ?? 0
        googleAPIDistance       = "\(stringDistance) km"
        lblDistance.text        = googleAPIDistance
        lblDuration.text        = estimated_duration
        lblAverageRating.text   = "\(averageRating)"
        lblTotalReview.text     = "\(totalReview)"
        
        stackviewLoader.isHidden  = true
        stackViewDetails.isHidden = false
        btnPreview.isEnabled = true
        btnPreview.alpha     = 1.0
    }
    
    func displayWithoutResult(){
        let stringDistance      = utilities.convertDistanceToString(distance:estimated_distance)
        objectRating            = nil
        offset                  = 0
        lblDistance.text        = "\(stringDistance) km"
        lblDuration.text        = "Cannot determine!"
        lblAverageRating.text   = "0"
        lblTotalReview.text     = "0"
        
        stackviewLoader.isHidden  = true
        stackViewDetails.isHidden = false
        btnPreview.isEnabled = true
        btnPreview.alpha     = 1.0
    }
    
    
    func showDialog(title:String,message:String){
        //alert box
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            
        }
        alertView.addAction(confirm)
        present(alertView,animated: true,completion: nil)
    }
    
    @IBAction func previewBranchDetails(_ sender: Any) {
        delegateButton?.buttonPressed(objectRating:objectRating!, index: index,distance:estimated_distance,duration:estimated_duration)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
}
