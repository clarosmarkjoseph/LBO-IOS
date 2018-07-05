//
//  ImageCollectionViewCell.swift
//  SampleProject
//
//  Created by itadmin on 12/05/2017.
//  Copyright © 2017 itadmin. All rights reserved.
//

import Foundation
class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
