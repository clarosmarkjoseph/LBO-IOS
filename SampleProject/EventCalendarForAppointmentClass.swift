//
//  EventCalendarForAppointmentClass.swift
//  SampleProject
//
//  Created by Paolo Hilario on 8/10/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import Foundation
import EventKit

class EventCalendarForAppointmentClass{
    
    let eventStore              = EKEventStore()
    static let sharedInstance   = EventCalendarForAppointmentClass()
    
    
    func removeAllEventsMatchingPredicate(startDate:Date,endDate:Date) {
        
        let predicate2  = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events      = eventStore.events(matching: predicate2) as [EKEvent]!
        
        if events != nil {
            for i in events! {
                do{
                    (try eventStore.remove(i, span: EKSpan.thisEvent, commit: true))
                }
                catch let error {
                    print("Error removing events: ", error)
                }
                
            }
        }
    }
    
}
