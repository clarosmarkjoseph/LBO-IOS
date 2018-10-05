//
//  NetworkAPI.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/27/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import Foundation
import Alamofire
import SQLite

class NetworkAPI{
    let dbclass                 = DatabaseHelper()
    let utilities               = Utilities()
    static let sharedInstance   = NetworkAPI()
    var SERVER_URL              = ""
    
    init() {
        SERVER_URL          = dbclass.returnIp()
    }
    
    func logoutUser(url:URL,requestParams:Parameters,completionBlock: @escaping (String,Int) -> () ){
        
        Alamofire.request(url, method: .post, parameters: requestParams)
            .responseJSON { response in
                do{
                    guard let statusCode   = try response.response?.statusCode else {
                        completionBlock("failed",0)
                        return
                    }
                    if(statusCode == 200 || statusCode == 201){
                        completionBlock("success",200)
                        return
                    }
                    else if(statusCode == 401){
                        completionBlock("session expired",statusCode)
                        return
                    }
                    else{
                        completionBlock("failed",statusCode)
                        return
                    }
                }
                catch{
                    print("Error: \(error)")
                    completionBlock("failed",0)
                    return
                }
        }
    }
    
}
