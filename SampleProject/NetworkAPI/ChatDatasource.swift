//
//  ChatDatasource.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/26/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import Foundation
import Alamofire
import SQLite

class ChatDatasource{
    
    let dbclass     = DatabaseHelper()
    let utilities   = Utilities()
    var SERVER_URL  = ""
    var arrayChatThread     = [ArrayChatThread]()
    var arrayChatMessage    = [ArrayChatMessage]()
    var ifChatMessageShown  = false
    var statusCode          = 0
    static let sharedChatInstance = ChatDatasource()
    
    init() {
        SERVER_URL          = dbclass.returnIp()
    }
    
    func loadAllChatMessages(completionBlock: @escaping ([ArrayChatThread],Int) -> () )  {
        var arrayChatThread = [ArrayChatThread]()
        do{
            let returnObjectID  = dbclass.returnAllChatThread()
            let arrayThreadID   = returnObjectID["arrayThreadID"] as! [Int]
            let arrayChatID     = returnObjectID["arrayLastID"] as! [Int]
            let userToken       = utilities.getUserToken()
            let stringURL       = "\(SERVER_URL)/api/mobile/getAllChatMessage?token=\(userToken)"
            let myURL           = URL(string: stringURL)
            let requestParams   = [
                "arrayThreadID":"\(arrayThreadID)",
                "arrayLastID":"\(arrayChatID)"
            ]
            
            Alamofire.request(myURL!, method: .post, parameters: requestParams)
                .responseJSON { response in
                    do{
                        guard let statusCode   = try response.response?.statusCode else {
                            completionBlock(arrayChatThread, 0)
                            return
                        }
                        if let responseJSONData = response.data{
                            if(statusCode == 200 || statusCode == 201){
                                let jsonResult          = try JSONDecoder().decode(ChatResult.self, from: responseJSONData)
                                arrayChatThread = jsonResult.allMessage!
                                completionBlock(arrayChatThread, statusCode)
                            }
                            else if (statusCode == 401){
                                self.utilities.deleteAllData()
                                let mainStoryboard: UIStoryboard = UIStoryboard(name: "LoginStoryboard", bundle: nil)
                                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
                                viewController.isLoggedOut      = true
                                viewController.sessionExpired   = true
                                UIApplication.shared.keyWindow?.rootViewController = viewController
                            }
                            else{
                                let responseValue = response.result.value
                                if responseValue != nil{
                                    let arrayError = self.utilities.handleHttpResponseError(objectResponseError: responseValue as! Dictionary<String, Any> ,statusCode:statusCode)
                                    print("title: \(arrayError[0])\n body:\(arrayError[1])")
                                }
                                else{
                                    print("title:Error!\n body:There was a problem connecting to Lay Bare App. Please check your connection and try again")
                                }
                                completionBlock(arrayChatThread, statusCode)
                            }
                        }
                        else{
                            completionBlock(arrayChatThread, statusCode)
                        }
                    }
                    catch{
                        print("error catch: \(error)")
                        completionBlock(arrayChatThread, 0)
                    }
            }
        }
        catch{
            print("ERROR Retrieving chat5: \(error)")
            completionBlock(arrayChatThread,0)
        }
    }
   
   
    
   
    
    
}
