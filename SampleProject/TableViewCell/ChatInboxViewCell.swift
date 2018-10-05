//
//  ChatInboxViewCell.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/19/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit

class ChatInboxViewCell: UITableViewCell {

    @IBOutlet var lblUsername: UILabel!
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblCount: UILabel!
    @IBOutlet var imgProfile: UIImageView!
    

}

class ChatMessageViewCell:UITableViewCell{

    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var stackviewParent: UIStackView!
    @IBOutlet var uiviewMessage: UIView!
    @IBOutlet var uiviewBackground: UIView!
    @IBOutlet var lblMessage: UILabel!
    
    @IBOutlet var lblCaption: UILabel!
    @IBOutlet var constraintTrailing: NSLayoutConstraint!
    @IBOutlet var constraintLeading: NSLayoutConstraint!
    
    
}


