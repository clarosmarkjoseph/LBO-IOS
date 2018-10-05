//
//  BranchViewCell.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/6/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import Foundation

class BranchViewCell:UITableViewCell{
    
    @IBOutlet var lblBranchName: UILabel!
    @IBOutlet var lblBranchDesc: UILabel!
    @IBOutlet var lblBranchDistance: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}


class TechnicianViewCell:UITableViewCell{
    
    @IBOutlet var lblTechnicianName: UILabel!
    @IBOutlet var lblTechnicianSched: UILabel!
}

class BranchInfoViewCell:UITableViewCell{
    
    @IBOutlet var lblCaption: UILabel!
    @IBOutlet var imgDetail: UIImageView!
    @IBOutlet var stackviewDetails: UIStackView!

    
}


class BranchQueuingViewCell:UICollectionViewCell{
    
    @IBOutlet var lblClientName: UILabel!
    @IBOutlet var lblClientID: UILabel!
    @IBOutlet var lblClientTech: UILabel!
    @IBOutlet var lblClientTime: UILabel!
    
}


class BranchArrayReviewCell:UITableViewCell{
    
    @IBOutlet var imgClient: UIImageView!
    @IBOutlet var lblClientName: UILabel!
    @IBOutlet var lblClientMessage: UILabel!
    
}





