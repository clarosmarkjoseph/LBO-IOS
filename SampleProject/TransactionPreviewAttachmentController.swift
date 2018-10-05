//
//  PremiereRequestAttachmentController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/4/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Kingfisher

class TransactionPreviewAttachmentController: UIViewController {
    
    @IBOutlet var imgAttachment: UIImageView!
    var utilities = Utilities()
    var imgSRC    = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("RECeived URL: \(imgSRC)")
        let url             = URL(string: imgSRC)
        print(imgSRC)
        imgAttachment.kf.setImage(with:url)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeLeft, andRotateTo: UIInterfaceOrientation.landscapeLeft)
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    @IBAction func btnClose(_ sender: Any) {
        
        self.navigationController?.isNavigationBarHidden    = false
        self.navigationController?.popViewController(animated: true)
    }
    

}
