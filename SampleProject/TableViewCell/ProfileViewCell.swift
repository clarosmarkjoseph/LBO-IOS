//
//  ProfileViewCell.swift
//  SampleProject
//
//  Created by Paolo Hilario on 5/30/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit

class ProfileViewCell: UITableViewCell {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblClientName: UILabel!
    @IBOutlet weak var lblHomeBranch: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class ProfileOptionViewCell: UITableViewCell {
    
    @IBOutlet weak var lblOption: UILabel!
    @IBOutlet weak var imgOption: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
