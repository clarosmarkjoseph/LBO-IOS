//
//  ServicePackageTableCellView.swift
//  SampleProject
//
//  Created by Paolo Hilario on 5/25/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit

class ServicePackageTableCellView: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var imgServicePackage: UIImageView!
    @IBOutlet weak var lblServiceName: UILabel!
    @IBOutlet weak var lblServiceDesc: UILabel!
    @IBOutlet weak var imgServiceGender: UIImageView!
    @IBOutlet weak var lblServicePrice: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
