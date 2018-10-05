//
//  ItemDetailViewController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 5/25/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Kingfisher


class ItemDetailViewController: UIViewController {
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var lblItemName: UILabel!
    @IBOutlet weak var lblItemPrice: UILabel!
    @IBOutlet weak var imgItem: UIImageView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblQuestion1: UILabel!
    @IBOutlet weak var lblQuestion2: UILabel!
    @IBOutlet weak var lblAnswer1: UILabel!
    @IBOutlet weak var lblAnswer2: UILabel!
    @IBOutlet var btnAdd: UIButton!
    let utilities       = Utilities()
    let dbclass         = DatabaseHelper()
    var SERVER_URL      = ""
    var item_id         = 0
    var item_name       = ""
    var item_desc       = ""
    var item_image      = ""
    var item_price      = 0.0
    var item_duration   = 0
    var item_gender     = ""
    var item_size       = ""
    var item_variant    = ""
    var item_type       = ""
    var viewType        = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navItem.backBarButtonItem?.title = ""
        SERVER_URL        =  dbclass.returnIp()
        lblItemName.text  = item_name
        lblItemPrice.text = utilities.convertToStringCurrency(value: "\(item_price)")
        lblDesc.text      = item_desc
        var myURL:URL
        if(item_type == "product") {
            lblQuestion1.text = "Variant: "
            lblQuestion2.text = "Size: "
            lblAnswer1.text   = item_variant
            lblAnswer2.text   = item_size
            myURL             = URL(string:SERVER_URL+"/images/products/\(item_image)")!
        }
        else{
            lblQuestion1.text = "Duration: "
            lblQuestion2.text = "Gender: "
            lblAnswer1.text   = "\(item_duration) minutes"
            lblAnswer2.text   = item_gender
            myURL             = URL(string:SERVER_URL+"/images/services/\(item_image)")!
        }
        if(viewType == "appointment"){
            btnAdd.isHidden = false
        }
        imgItem.kf.setImage(with: myURL)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    @IBAction func addToList(_ sender: Any) {
//        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
//        let storyBoard = UIStoryboard(name:"AppointmentStoryboard",bundle:nil)
//        let appointmentVC  = storyBoard.instantiateViewController(withIdentifier: "AppointmentSecondViewController") as! AppointmentSecondViewController
        self.navigationController?.popViewController(animated: true)
    }
    
    

}
