//
//  FAQViewCell.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/3/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import Foundation

class FAQCategoryViewCell:UITableViewCell{
    @IBOutlet var imgCategory: UIImageView!
    @IBOutlet var lblCategoryTitle: UILabel!

}

class FAQQuestionViewCell:UITableViewCell{
    @IBOutlet var lblQuestionTitle: UILabel!
    @IBOutlet var lblQuestionAnswer: UILabel!
}
