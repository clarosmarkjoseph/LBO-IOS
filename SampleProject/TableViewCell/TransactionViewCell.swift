//
//  TransactionViewCell.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/26/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit

class TransactionViewCell: UITableViewCell {

    @IBOutlet var lblBranchName: UILabel!
    @IBOutlet var lblTotalPrice: UILabel!
    @IBOutlet var lblDate: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

class TransactionDataViewCell: UITableViewCell {
    
    @IBOutlet var lblUnitPrice: UILabel!
    @IBOutlet var lblSubtotal: UILabel!
    @IBOutlet var lblQuantity: UILabel!
    @IBOutlet var lblType: UILabel!
    @IBOutlet var lblItemName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
