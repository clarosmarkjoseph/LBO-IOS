//
//  GlobalVariables.swift
//  Lay Bare Waxing PH
//
//  Created by Paolo Hilario on 9/11/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import Foundation

class GlobalVariables {
    var notification_type = ""
    var arrayServices  = [Int]()
    var arrayProducts  = [Int]()
    static let sharedInstance   = GlobalVariables()
    
    public func setNotificationType(notif:String){
        self.notification_type = notif
    }
    public func getNotificationType() -> String{
        return self.notification_type
    }
    
    public func setAvailableServices(array:[Int]){
        self.arrayServices = array
    }
    
    public func getAvailableServices()  -> [Int]{
        return self.arrayServices
    }
    public func setAvailableProducts(array:[Int]){
        self.arrayProducts = array
    }
    
    public func getAvailableProducts() -> [Int]{
        print("returning avail prod: \(self.arrayProducts)")
        return self.arrayProducts
    }
    
    
    
}
