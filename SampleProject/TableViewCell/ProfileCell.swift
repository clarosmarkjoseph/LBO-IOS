//
//  ProfileEditCell.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/21/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {

    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var txtAnswer: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
