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
}

class AppointmentWaiverCell:UITableViewCell{
    @IBOutlet var lblWaiverQuestion: UILabel!
    @IBOutlet var segmentYesOrNo: UISegmentedControl!
    @IBOutlet var lblAnswer: UILabel!
}

class AppointmentTableDetails:UITableViewCell{
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

//Appointment Details
class AppointmentDetailsCell:UITableViewCell{
    @IBOutlet var lblCaption: UILabel!
    @IBOutlet var lblAnswer: UILabel!
    @IBOutlet var stackViewList: UIStackView!
    @IBOutlet var stackOtherDetails: UIStackView!
    @IBOutlet var btnCancelAppointment: UIButton!
}


class AppointmentItemCell:UITableViewCell{
  
    @IBOutlet var stackViewQuantity: UIStackView!
    @IBOutlet var lblCaption1: UILabel!
    @IBOutlet var lblAnswer1: UILabel!
    @IBOutlet var lblCaption2: UILabel!
    @IBOutlet var lblAnswer2: UILabel!
    @IBOutlet var lblCaption3: UILabel!
    @IBOutlet var lblAnswer3: UILabel!
    @IBOutlet var lblCaption4: UILabel!
    @IBOutlet var lblAnswer4: UILabel!
    @IBOutlet var lblCaption5: UILabel!
    @IBOutlet var lblAnswer5: UILabel!
    @IBOutlet var lblCaption6: UILabel!
    @IBOutlet var lblAnswer6: UILabel!
    @IBOutlet var btnCancelItem: UIButton!
//    @IBOutlet var uiviewBtn: UIView!
    
    
}

class EmptyCell:UITableViewCell{
    @IBOutlet var lblCelltext: UILabel!
}







