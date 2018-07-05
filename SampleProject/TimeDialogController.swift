//
//  TimeDialogController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/6/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit

protocol ProtocolTimeForAppointment {
    func setTime(selectedDateTime:String)
}

class TimeDialogController: UIViewController {
    
    let utilities       = Utilities()
    var selected_date   = ""
    var start_time      = ""
    var end_time        = ""
    var delegateTime:ProtocolTimeForAppointment? = nil
    @IBOutlet var timePicker: UIDatePicker!
    @IBOutlet var popupView: UIView!
    @IBOutlet var lblSelectedDate: UILabel!
    @IBOutlet var lblTime: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 30
        popupView.layer.masksToBounds = true
        loadTime()
    }
    
    
    func loadTime(){
        
        var calendar                = Calendar.current
        var dateFormatter           = DateFormatter()
        dateFormatter.dateFormat    = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone      = calendar.timeZone
       
        
        var selectedDateTime        = utilities.convertStringToDateTime(stringDate: "\(selected_date) \(self.start_time):00")
        var currentDateTime         = utilities.convertStringToDateTime(stringDate: dateFormatter.string(from: Date()))
        var start_datetime          = Date()
        var end_datetime            = utilities.convertStringToDateTime(stringDate: selected_date+" "+self.end_time+":00")
        
        switch currentDateTime.compare(selectedDateTime) {
            
        case .orderedSame:
             print("currentDateTime same as selected date")
             start_datetime = utilities.convertStringToDateTime(stringDate: selected_date+" "+self.start_time+":00")
        
        case .orderedAscending:
            print("currentDateTime is smaller than second")
            start_datetime = utilities.convertStringToDateTime(stringDate: selected_date+" "+self.start_time+":00")
        
        case .orderedDescending:
            print("currentDateTime is greater than second")
 
            let currentFormatter        = DateFormatter()
            currentFormatter.dateFormat = "mm"
            var modulo                  = calendar.component(.minute, from: currentDateTime) % 10
            var remainder               = 10 - modulo
            var dateComponent           = DateComponents()
            dateComponent.hour          = 2
            dateComponent.minute        = remainder

            start_datetime              = calendar.date(byAdding: dateComponent, to: currentDateTime)!
            start_time                  = utilities.removeDateFromDatetime(stringDateTime: utilities.convertDateTimeToString(date: start_datetime))
            
        }
       
        timePicker.datePickerMode = .time
        timePicker.minimumDate    = Date()
        timePicker.date           = start_datetime
        timePicker.maximumDate    = end_datetime
        timePicker.minimumDate    = start_datetime
        timePicker.minuteInterval = 10
        lblSelectedDate.text      = utilities.getCompleteDateString(stringDate: selected_date)
        lblTime.text              = "\(utilities.getStandardTime(stringTime: start_time)) - \(utilities.getStandardTime(stringTime: end_time))"
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func confirmTime(_ sender: Any) {
        
        let dateTimeString = utilities.convertDateTimeToString(date: timePicker.date)
        delegateTime?.setTime(selectedDateTime: dateTimeString)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelDialog(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
