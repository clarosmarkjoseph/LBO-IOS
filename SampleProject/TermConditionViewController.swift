//
//  TermConditionViewController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/1/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit


class TermConditionViewController: UIViewController {

    var stringTerms = ""
    var ifTermsAgreed = false
    var delegate:ProtocolForSignup? = nil
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var uiViewContent: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiViewContent.layer.cornerRadius = 10
        uiViewContent.layer.masksToBounds = true
        loadTerms()
        
        // Do any additional setup after loading the view.
    }

    func loadTerms(){

        let data = stringTerms.data(using: String.Encoding.unicode)! // mind "!"
        let attrStr = try? NSAttributedString( // do catch
            data: data,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        lblTerms.attributedText = attrStr
    
    }
    
    @IBAction func cancelTerms(_ sender: Any) {
        delegate?.setupAgreement(isAgreed:false)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func agreeTerms(_ sender: Any) {
        delegate?.setupAgreement(isAgreed:true)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
