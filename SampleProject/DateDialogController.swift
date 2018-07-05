//
//  DialogStoryboard.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/5/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit

protocol ProtocolForAppointment {
    func setSelectedDate(selectedDate:String)
}

class DateDialogController: UIViewController {

    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var popupView: UIView!
    var selected_date   = ""
    let utilities       = Utilities()
    var delegateOfAppointment: ProtocolForAppointment? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 30
        popupView.layer.masksToBounds = true
        loadDate()
    }
    
    func loadDate(){
        datePicker.datePickerMode = .date
        datePicker.minimumDate    = Date()
        datePicker.date           = utilities.convertStringToDate(stringDate: selected_date)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissDialog(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectDate(_ sender: Any) {
        let dateString = utilities.convertDateToString(date: datePicker.date)
        delegateOfAppointment?.setSelectedDate(selectedDate: dateString)
        self.dismiss(animated: true, completion: nil)
    }
    
}





