//
//  AppointmentItemListViewCell.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/11/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit

class AppointmentItemListViewCell: UITableViewCell {

    @IBOutlet var imgItem: UIImageView!
    @IBOutlet var btnMinus: UIButton!
    @IBOutlet var btnAdd: UIButton!
    @IBOutlet var btnRemove: UIButton!
    @IBOutlet var lblSecondTitle: UILabel!
    @IBOutlet var lblSecondValue: UILabel!
    @IBOutlet var lblThirdTitle: UILabel!
    @IBOutlet var lblThirdValue: UILabel!
    @IBOutlet var lblItemName: UILabel!
    @IBOutlet var lblQty: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblSubtotal: UILabel!
    var indexPath:IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}

class AppointmentWaiverCell:UITableViewCell{
    
    
    @IBOutlet var lblWaiverQuestion: UILabel!
    @IBOutlet var segmentYesOrNo: UISegmentedControl!
    @IBOutlet var lblAnswer: UILabel!
    
    
    
}

class AppointmentTableDetails:UITableViewCell{
//    cellAppointment
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblValue: UILabel!
    @IBOutlet var imgDetails: UIImageView!
    
}

class AppointmentCalendarDetails:UITableViewCell{
    
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var lblBranch: UILabel!
    @IBOutlet var lblTechnician: UILabel!
    @IBOutlet var lblStatus: UILabel!
    
}



