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
    var hasTech:Bool    = false
    var delegateTime:ProtocolTimeForAppointment? = nil
    var noSchedule      = false
    @IBOutlet var timePicker: UIDatePicker!
    @IBOutlet var popupView: UIView!
    @IBOutlet var lblSelectedDate: UILabel!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var btnConfirm: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 30
        popupView.layer.masksToBounds = true
        loadTime()
    }
    
    
    func loadTime(){
        
        var calendar                = Calendar.current
        let dateFormatter           = DateFormatter()
        dateFormatter.dateFormat    = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone      = calendar.timeZone
       
        let selectedDateTime        = utilities.convertStringToDateTime(stringDate: "\(selected_date) \(self.start_time):00")
        let currentDateTime         = utilities.convertStringToDateTime(stringDate: dateFormatter.string(from: Date()))
        var start_datetime          = Date()
        let end_datetime            = utilities.convertStringToDateTime(stringDate: selected_date+" "+self.end_time+":00")
        
        switch currentDateTime.compare(selectedDateTime) {
            
        case .orderedSame:
//             print("currentDateTime same as selected date")
             start_datetime = utilities.convertStringToDateTime(stringDate: selected_date+" "+self.start_time+":00")
             self.setupTime(start_datetime: start_datetime, end_datetime: end_datetime)
        case .orderedAscending:
//            print("currentDateTime is smaller than second")
            start_datetime = utilities.convertStringToDateTime(stringDate: selected_date+" "+self.start_time+":00")
            self.setupTime(start_datetime: start_datetime, end_datetime: end_datetime)
        case .orderedDescending:
//            print("currentDateTime is greater than second")
            if currentDateTime.compare(end_datetime) ==  .orderedAscending {
                print("date time is less end time")
                let currentFormatter        = DateFormatter()
                currentFormatter.dateFormat = "mm"
                let modulo                  = calendar.component(.minute, from: currentDateTime) % 10
                let remainder               = 10 - modulo
                var dateComponent           = DateComponents()
                dateComponent.hour          = 2
                dateComponent.minute        = remainder
                start_datetime              = calendar.date(byAdding: dateComponent, to: currentDateTime)!
                
                if (start_datetime.compare(end_datetime) == .orderedDescending){
                    print("end time is less than start time")
                    self.setupFailed()
                    break
                }
                else{
                    start_time                  = utilities.removeDateFromDatetime(stringDateTime: utilities.convertDateTimeToString(date: start_datetime))
                }
            }
            if currentDateTime.compare(end_datetime) == .orderedDescending{
                print("date time is greater end time")
                self.setupFailed()
                break
            }
            self.setupTime(start_datetime: start_datetime, end_datetime: end_datetime)
        }
    }
    
    
    
    func setupTime(start_datetime:Date,end_datetime:Date){
        timePicker.datePickerMode = .time
        timePicker.date           = start_datetime
        timePicker.maximumDate    = end_datetime
        timePicker.minimumDate    = start_datetime
        timePicker.minuteInterval = 10
        lblSelectedDate.text      = utilities.getCompleteDateString(stringDate: selected_date)
        lblTime.text              = "\(utilities.getStandardTime(stringTime: start_time)) - \(utilities.getStandardTime(stringTime: end_time))"
    }
    
    func setupFailed() {
        lblSelectedDate.text    = utilities.getCompleteDateString(stringDate: selected_date)
        lblTime.text            = "No Available Time"
        timePicker.isHidden     = true
        btnConfirm.setTitle("Dismiss", for: .application)
        noSchedule = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirmTime(_ sender: Any) {
        
        if(noSchedule == false){
            let dateTimeString = utilities.convertDateTimeToString(date: timePicker.date)
            delegateTime?.setTime(selectedDateTime: dateTimeString)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelDialog(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
