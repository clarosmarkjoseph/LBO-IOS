//
//  DatabaseHelper.swift
//  SampleProject
//
//  Created by itadmin on 11/05/2017.
//  Copyright © 2017 itadmin. All rights reserved.
//

import Foundation
import SQLite


class DatabaseHelper{

    public let db: Connection?
    static let instance = DatabaseHelper()
    
    //initialize  table ip_tbl
    let ip_tbl      = Table("ip_tbl")
    let ip_address  = Expression<String>("ip_address")
    
    //initialize table user_tbl table
    let user_tbl           = Table("user_tbl")
    let user_id             = Expression<Int>("user_id")
    let user_email          = Expression<String>("user_email")
    let user_name           = Expression<String>("user_name")
    let user_token          = Expression<String>("user_token")
    let user_object_data    = Expression<String>("user_object_data")
    let user_date_updated   = Expression<String>("user_date_updated")
    
    //initialize Carousel image table
    let carousel_tbl            = Table("carousel_tbl")
    let carousel_version        = Expression<Double>("carousel_version")
    let carousel_array          = Expression<String>("carousel_array")
    let carousel_date_added     = Expression<String>("carousel_date_added")
    
    //initialize branches table
    let branch_tbl          = Table("branch_tbl")
    let branch_version      = Expression<Double>("branch_version")
    let branch_array        = Expression<String>("branch_array")
    
    //initialize services_tbl table
    let service_tbl             = Table("services_tbl")
    let service_version     = Expression<Double>("service_version")
    let service_array       = Expression<String>("service_array")

    //initialize packages table
    let package_tbl         = Table("packages_tbl")
    let package_version     = Expression<Double>("packages_version")
    let package_array       = Expression<String>("packages_array")

     //initialize products_tbl table
    let product_tbl         = Table("product_tbl")
    let product_version     = Expression<Double>("product_version")
    let product_array       = Expression<String>("product_array")
    
    //initialize commercial table
    let commercial_tbl         = Table("commercial_tbl")
    let commercial_version     = Expression<Double>("commercial_version")
    let commercial_array       = Expression<String>("commercial_array")
    
    //initialize terms table
    let terms_tbl              = Table("terms_tbl")
    let terms_data             = Expression<String>("terms")
    
    //initialize waiver tabl
    let waiver_tbl             = Table("waiver_tbl")
    let waiver_data            = Expression<String>("waiver_data")
    
    //initialize premiere table
    let premiere_tbl            = Table("premiere_tbl")
    let premiere_array          = Expression<String>("premiere_array")
    let premiere_date_modified  = Expression<String>("premiere_date_modified")
    
    //initialize transaction Requests
    let transaction_request_tbl             = Table("transaction_request_tbl")
    let transaction_request_array           = Expression<String>("transaction_request_array")
    let transaction_request_date_modified   = Expression<String>("transaction_request_date_modified")
    
    //initialize promotions table
    let promotion_tbl               = Table("promotion_tbl")
    let promotion_array             = Expression<String>("promotion_array")
    let promotion_date_updated      = Expression<String>("promotion_date_updated")
    
    //initialize FAQ's table
    let faq_tbl                     = Table("faq_tbl")
    let faq_object                  = Expression<String>("faq_object")
    let faq_date_updated            = Expression<String>("faq_date_updated")
    
    
    //appointment table
    let appointment_tbl             = Table("appointment_tbl")
    let appointment_id              = Expression<Int>("appointment_id")
    let appointment_status          = Expression<String>("appointment_status")
    let appointment_object          = Expression<String>("appointment_object")
    let appointment_date            = Expression<String>("appointment_date")
    let appointment_updated         = Expression<String>("appointment_updated")
        
    //chat thread table
    let chat_thread_tbl             = Table("chat_thread_tbl")
    var thread_id                   = Expression<Int>("thread_id")
    let thread_creator_id           = Expression<Int>("thread_creator_id")
    let thread_is_seen              = Expression<Int>("thread_is_seen")
    let thread_is_block             = Expression<Int>("thread_is_block")
    let thread_name                 = Expression<String>("thread_name")
    let thread_datetime             = Expression<String>("thread_datetime")
    let thread_user_image           = Expression<String>("thread_user_image")
    let thread_participants         = Expression<String>("thread_participants")

    
    //chat table
    let chat_tbl                    = Table("chat_tbl")
    let chat_id                     = Expression<Int>("chat_id")
    let chat_sender_id              = Expression<Int>("chat_sender_id")
    let chat_recipient_id           = Expression<Int>("chat_recipient_id")
    let chat_title                  = Expression<String>("chat_title")
    let chat_body                   = Expression<String>("chat_body")
    let chat_data                   = Expression<String>("chat_data")
    let chat_datetime               = Expression<Date>("chat_datetime")
    let chat_status                 = Expression<String>("chat_status")
    var chat_thread_id              = Expression<Int>("chat_thread_id")
    let chat_read_at                = Expression<String>("chat_is_read")
    
    //device token for APN's
    let device_token_tbl           = Table("device_token_tbl")
    let device_token               = Expression<String>("device_token")
    
    //device token for APN's
    let branch_rating_tbl          = Table("branch_rating_tbl")
    let branch_rating_id           = Expression<Int>("branch_rating_id")
    
    //notification
    let notification_tbl          = Table("notification_tbl")
    let notification_id           = Expression<Int>("notification_id")
    let notification_datetime     = Expression<String>("notification_datetime")
    let notification_type         = Expression<String>("notification_type")
    let notification_is_seen      = Expression<Int>("notification_is_seen")
    let notification_title        = Expression<String>("notification_title")
    let notification_body         = Expression<String>("notification_body")
    let notification_unique_id    = Expression<Int>("notification_unique_id")
    
    //initialize database table
    public init(){
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask,true).first!
        do{
            db = try Connection("\(path)/laybaredb.sqlite3")
            createTable()
        }
        catch{
            db = nil
            print("Unable to open database")
        }
    }
   
    func createTable(){
        do{
            try db?.run(ip_tbl.create(ifNotExists: true) { table in
                table.column(ip_address)
            })
            
            try db?.run(user_tbl.create(ifNotExists: true) { table in
                table.column(user_id,primaryKey:true)
                table.column(user_name)
                table.column(user_email,unique:true)
                table.column(user_token)
                table.column(user_object_data)
                table.column(user_date_updated)
            })
            
            try db!.run(carousel_tbl.create(ifNotExists: true) { table in
                table.column(carousel_version)
                table.column(carousel_array)
                table.column(carousel_date_added)
            })
            
            try db!.run(branch_tbl.create(ifNotExists: true) { table in
                table.column(branch_version)
                table.column(branch_array)
            })
            
            try db!.run(service_tbl.create(ifNotExists: true) { table in
                table.column(service_version)
                table.column(service_array)
            })
            
            try db!.run(product_tbl.create(ifNotExists: true) { table in
                table.column(product_array)
                table.column(product_version)
            })
            
            try db!.run(package_tbl.create(ifNotExists: true) { table in
                table.column(package_version)
                table.column(package_array)
            })
            
            try db!.run(commercial_tbl.create(ifNotExists: true) { table in
                table.column(commercial_version)
                table.column(commercial_array)
            })
            
            try db!.run(terms_tbl.create(ifNotExists: true) { table in
                table.column(terms_data)
            })
            
            try db!.run(waiver_tbl.create(ifNotExists: true) { table in
                table.column(waiver_data)
            })
            
            try db!.run(premiere_tbl.create(ifNotExists: true) { table in
                table.column(premiere_array)
                table.column(premiere_date_modified)
            })
            
            try db!.run(transaction_request_tbl.create(ifNotExists: true) { table in
                table.column(transaction_request_array)
                table.column(transaction_request_date_modified)
            })
            
            try db!.run(promotion_tbl.create(ifNotExists: true) { table in
                table.column(promotion_array)
                table.column(promotion_date_updated)
            })
            
            try db!.run(faq_tbl.create(ifNotExists: true) { table in
                table.column(faq_object)
                table.column(faq_date_updated)
            })
            
            try db!.run(appointment_tbl.create(ifNotExists: true) { table in
                table.column(appointment_id)
                table.column(appointment_status)
                table.column(appointment_object)
                table.column(appointment_date)
                table.column(appointment_updated)
            })
           
            try db!.run(chat_thread_tbl.create(ifNotExists: true) { table in
                table.column(thread_id)
                table.column(thread_creator_id)
                table.column(thread_name)
                table.column(thread_datetime)
                table.column(thread_is_seen)
                table.column(thread_participants)
                table.column(thread_is_block)
                table.column(thread_user_image)
            })
            try db!.run(chat_tbl.create(ifNotExists: true) { table in
                table.column(chat_id)
                table.column(chat_sender_id)
                table.column(chat_recipient_id)
                table.column(chat_title)
                table.column(chat_body)
                table.column(chat_data)
                table.column(chat_datetime)
                table.column(chat_read_at)
                table.column(chat_status)
                table.column(chat_thread_id)
            })
            try db!.run(device_token_tbl.create(ifNotExists: true) { table in
                table.column(device_token)
            })
            
            try db!.run(branch_rating_tbl.create(ifNotExists: true) { table in
                table.column(branch_rating_id)
            })
           
            try db!.run(notification_tbl.create(ifNotExists: true) { table in
                table.column(notification_id)
                table.column(notification_datetime)
                table.column(notification_type)
                table.column(notification_is_seen)
                table.column(notification_title)
                table.column(notification_body)
                table.column(notification_unique_id)
            })
            
        }
        catch{
            print("Unable to create Table")
        }
    }
        
    
    //insert Module

    func returnIp() -> String{
        do{
            if let ip = try db!.pluck(ip_tbl){
                return ip[ip_address]
            }
        }
        catch{
            print("error retrieving logs")
        }
        return ""
    }
    
    func insertIPAddress(url: String) {
        do{
            let insertIp = ip_tbl.insert(ip_address <- url)
            try db!.run(insertIp)
        }
        catch{
            print("ERROR inserting IP Address")
        }
    }
    
    func deleteIPAddress(){
        do{
            try db!.run(ip_tbl.delete())
        }
        catch{
            print("ERROR deleting IP Address")
        }
    }
    
    func deleteUserAccount(){
        do{
            try db!.run(user_tbl.delete())
        }
        catch{
            print("ERROR deleting User account")
        }
    }
    
    func deleteAppointments(){
        do{
            try db!.run(appointment_tbl.delete())
        }
        catch{
            print("ERROR deleting Appointment")
        }
    }
    
    func deletePremier(){
        do{
            try db!.run(premiere_tbl.delete())
        }
        catch{
            print("ERROR deleting Appointment")
        }
    }
    
    
    
    func countUserAccount() -> Int{
        var countUser = 0
        do{
            countUser = try db!.scalar(user_tbl.count)
            return countUser
        }
        catch{
            print("ERROR Inserting USER account")
            return countUser
        }
    }
    func insertUserAccount(id:Int,name:String,email:String,token:String,object_data:Dictionary<String,Any>,date_updated:String){
    
        do{
            let jsonData            = try? JSONSerialization.data(withJSONObject: object_data, options:[])
            guard let jsonString    = try String(data: jsonData!, encoding: .utf8) else { return }
            let insertUser = user_tbl.insert(
                        user_id             <- id,
                        user_name           <- name,
                        user_email          <- email,
                        user_token          <- token,
                        user_object_data    <- jsonString,
                        user_date_updated   <- date_updated
            
                    )
                try db!.run(insertUser)
       }
       catch{
            print("ERROR Inserting USER account")
       }
    }
    
    func updateUserProfile(id:Int,name:String,token:String,object_data:String,date_updated:String){
        
        do{
            let updateUser          = user_tbl.update(
                    user_name         <- name,
                    user_token        <- token,
                    user_object_data  <- object_data,
                    user_date_updated <- date_updated
            )
            try db!.run(updateUser)
        }
        catch{
            print("ERROR editing Profile : \(error)")
        }
    }
    
    func updateUserObject(jsonString:String,date_updated:String){

        do{
            let updateUser = user_tbl.update(
                        user_object_data    <- jsonString,
                        user_date_updated   <- date_updated
                    )
            try db!.run(updateUser)
        }
        catch{
            print("ERROR editing Profile OBJECT : \(error)")
        }
    }
    
    
    
    func deleteServices(){
        do{
            try db!.run(service_tbl.delete())
        }
        catch{
            print("ERROR DELETE SERVICE: \(error)")
        }
    }
    func deletePackages(){
        do{
            try db!.run(package_tbl.delete())
        }
        catch{
            print("ERROR DELETE Package \(error)")
        }
    }
    func deleteProducts(){
        do{
            try db!.run(product_tbl.delete())
        }
        catch{
            print("ERROR Delete Product \(error)")
        }
    }
    
    
    func deleteCommercial(){
        do{
            try db!.run(commercial_tbl.delete())
        }
        catch{
            print("ERROR Delete Commercial \(error)")
        }
    }
    
    
    func deleteCarousel(){
        do{
            try db!.run(carousel_tbl.delete())
        }
        catch{
            print("ERROR Delete Carousel \(error)")
        }
    }
    
    func insertBranches(insert_version:Double,insert_array:String){
        do{
            let insertBranch    = branch_tbl.insert(branch_version <- insert_version,branch_array <- insert_array)
            try db!.run(insertBranch)
        }
        catch{
            print("ERROR inserting Branches \(error)")
        }
    }
    func returnBranches() -> String{
        var returnString = "[]"
        do{
            if let queryStatement           = try db?.pluck(branch_tbl) {
                returnString                = queryStatement[branch_array]
                return returnString
            }
        }
        catch{
            print("ERROR Returning value: \(error)")
            return returnString
        }
        return returnString
    }
    
    func deleteBranches(){
        do{
            try db!.run(branch_tbl.delete())
        }
        catch{
            print("ERROR DELETE BRANCH : \(error)")
        }
    }
    func insertServices(insert_version:Double,insert_array:String){
        do{
            let insertServices = service_tbl.insert(service_version  <- insert_version,service_array <- insert_array )
            try db!.run(insertServices)
        }
        catch{
            print("ERROR inserting Service \(error)")
        }
    }
    
    func insertPackages(insert_version:Double,insert_array:String){
        do{
            let insertPackage = package_tbl.insert(package_version  <- insert_version,package_array <- insert_array )
            try db!.run(insertPackage)
        }
        catch{
            print("ERROR inserting Package \(error)")
        }
    }
    
    func insertProducts(insert_version:Double,insert_array:String){
        do{
            let insertProducts = product_tbl.insert(product_version  <- insert_version,product_array <- insert_array )
            try db!.run(insertProducts)
        }
        catch{
            print("ERROR inserting Products \(error)")
        }
    }
    func insertCommercial(insert_version:Double,insert_array:String){
        do{
            let insertCommercials = commercial_tbl.insert(commercial_version  <- insert_version,commercial_array <- insert_array )
            try db!.run(insertCommercials)
        }
        catch{
            print("ERROR inserting Commercials \(error)")
        }
    }
    func insertCarousel(version_no:Double,arrayCarousel:String){
        let utilities = Utilities()
        do{
            let currentDate     = utilities.getCurrentDateTime(ifDateOrTime: "datetime")
            let insertCarousel  = carousel_tbl.insert(carousel_version  <- version_no, carousel_array <- arrayCarousel, carousel_date_added <- currentDate)
            try db!.run(insertCarousel)
            print("Success inserting Carousel")
        }
        catch{
            print("ERROR inserting Carousel \(error)")
        }
    }
    
    //terms and agreement
    func insertTerms(terms_string:String){
        do{
            let insertTerms = terms_tbl.insert(terms_data <- terms_string)
            try db!.run(insertTerms)
            print("Success insertTerms")
        }
        catch{
            print("ERROR insertTerms \(error)")
        }
    }
    
    func deleteTerms(){
        do{
            let deleteTerms = terms_tbl.delete()
            try db!.run(deleteTerms)
            print("Success Delete terms")
        }
        catch{
            print("ERROR deleting Terms: \(error)")
        }
    }
    
    func returnTerms()->String{
        var returnString = "[]"
        do{
            if let queryStatement           = try db?.pluck(terms_tbl) {
                returnString                = queryStatement[terms_data]
                return returnString
            }
        }
        catch{
            print("ERROR Returning value: \(error)")
            return returnString
        }
        return returnString
    }
    
    
    //waiver Tbl
    func insertWaiver(waiverString:String){
        do{
            let insertWaiver = waiver_tbl.insert(waiver_data <- waiverString)
            try db!.run(insertWaiver)
            print("Success insert Waiver ")
        }
        catch{
            print("ERROR insert Waiver")
            print(error)
        }
    }
    
    func deleteWaiver(){
        do{
            let deleteWaiver = waiver_tbl.delete()
            try db!.run(deleteWaiver)
            print("Success delete Waiver ")
        }
        catch{
            print("ERROR deleting Waiver: \(error)")
        }
    }
    
    func returnWaiver()->String{
        var returnString = "[]"
        do{
            if let queryStatement           = try db?.pluck(waiver_tbl) {
                returnString                = queryStatement[waiver_data]
                return returnString
            }
        }
        catch{
            print("ERROR Returning value: \(error)")
            return returnString
        }
        return returnString
    }
   

    //Transaction Requests
    func insertTransactionRequest(arrayString:String,date_updated:String){
        do{
            let insertPremiere = transaction_request_tbl.insert(
                transaction_request_array          <- arrayString,
                transaction_request_date_modified  <- date_updated
            )
            try db!.run(insertPremiere)
            print("Success insert Transaction Request ")
        }
        catch{
            print("ERROR insert Transaction Request : \(error)")
            print()
        }
    }
    func updateTransactionRequest(arrayString:String,date_updated:String){
        do{
            let updatePremiere = transaction_request_tbl.update(
                transaction_request_array          <- arrayString,
                transaction_request_date_modified  <- date_updated
            )
            try db!.run(updatePremiere)
            print("Success updating Transaction Request")
        }
        catch{
            print("ERROR updating Premiere: \(error)")
        }
    }
    
    func deleteTransactionRequest(){
        do{
            try db!.run(transaction_request_tbl.delete())
        }
        catch{
            print("ERROR Delete Premiere \(error)")
        }
    }
    
    func returnTransactionRequest()->String{
        var returnString = "[]"
        do{
            if let queryStatement           = try db?.pluck(transaction_request_tbl) {
                returnString                = queryStatement[transaction_request_array]
                return returnString
            }
        }
        catch{
            print("ERROR Returning value: \(error)")
            return returnString
        }
        return returnString
    }
    
    //Premiere Loyalty Card
    func insertPremiere(arrayString:String,date_updated:String){
        do{
            let insertPremiere = premiere_tbl.insert(
                                            premiere_array          <- arrayString,
                                            premiere_date_modified  <- date_updated
                                            )
            try db!.run(insertPremiere)
            print("Success insert Premiere List ")
        }
        catch{
            print("ERROR insert Premiere: \(error)")
            print()
        }
    }
    
    func updatePremiere(arrayString:String,date_updated:String){
        do{
            let updatePremiere = premiere_tbl.update(
                premiere_array          <- arrayString,
                premiere_date_modified  <- date_updated
            )
            try db!.run(updatePremiere)
            print("Success updating Premiere List ")
        }
        catch{
            print("ERROR updating Premiere: \(error)")
            print()
        }
    }
    
    func deletePremiere(){
        do{
            try db!.run(premiere_tbl.delete())
        }
        catch{
            print("ERROR Delete Premiere \(error)")
        }
    }
    
    func returnPremiere()->String{
        var returnString = "[]"
        do{
            if let queryStatement           = try db?.pluck(premiere_tbl) {
                returnString                = queryStatement[premiere_array]
                return returnString
            }
        }
        catch{
            print("ERROR Returning value: \(error)")
            return returnString
        }
        return returnString
    }
    
    
    //Promotions
    func insertPromotion(arrayString:String,date_updated:String){
        let utilities = Utilities()
        do{
            let insertPremiere = promotion_tbl.insert(
                promotion_array          <- arrayString,
                promotion_date_updated   <- date_updated
            )
            try db!.run(insertPremiere)
            print("Success insert Promotions")
        }
        catch{
            print("ERROR insert Promotion: \(error)")
            print()
        }
    }
    
    func updatePromotion(arrayString:String,date_updated:String){
        let utilities = Utilities()
        do{
            let updatePremiere = promotion_tbl.update(
                promotion_array             <- arrayString,
                promotion_date_updated      <- date_updated
            )
            try db!.run(updatePremiere)
            print("Success updating promotions ")
        }
        catch{
            print("ERROR updating Promotions: \(error)")
            print()
        }
    }
    
    func deletePromotion(){
        do{
            try db!.run(promotion_tbl.delete())
        }
        catch{
            print("ERROR Delete Promotion \(error)")
        }
    }
    
    func returnPromotions()->String{
        var returnString = "[]"
        do{
            if let queryStatement           = try db?.pluck(promotion_tbl) {
                returnString                = queryStatement[promotion_array]
                return returnString
            }
        }
        catch{
            print("ERROR Returning value: \(error)")
            return returnString
        }
        return returnString
    }
    
    
    //FAQ
    func insertFAQ(objectString:String,date_updated:String){
        do{
            let insertFAQ = faq_tbl.insert(
                faq_object        <- objectString,
                faq_date_updated  <- date_updated
            )
            try db!.run(insertFAQ)
            print("Success insert FAQ's")
        }
        catch{
            print("ERROR insert FAQ's: \(error)")
            print()
        }
    }
    
    func updateFAQ(objectString:String,date_updated:String){
        do{
            let updateFAQ = faq_tbl.update(
                faq_object        <- objectString,
                faq_date_updated  <- date_updated
            )
            try db!.run(updateFAQ)
            print("Success updating FAQ's ")
        }
        catch{
            print("ERROR updating FAQ's: \(error)")
            print()
        }
    }
    
    func deleteFAQ(){
        do{
            try db!.run(faq_tbl.delete())
        }
        catch{
            print("ERROR Delete FAQ's \(error)")
        }
    }
    
    func returnFAQ()->String{
        var returnString = "{}"
        do{
            if let queryStatement           = try db?.pluck(faq_tbl) {
                returnString                = queryStatement[faq_object]
                return returnString
            }
        }
        catch{
            print("ERROR Returning value: \(error)")
            return returnString
        }
        return returnString
    }
    
    
    //appointment
    func insertOrUpdateAppointment(id:Int,status:String,objectData:String,date:String,date_updated:String){
        do{
            let filterUpdate = appointment_tbl.filter(appointment_id == id)
            let countData    = try db!.scalar(filterUpdate.count)
            if countData  > 0 {
                let updateQuery = filterUpdate.update(
                    appointment_status      <- status,
                    appointment_object      <- objectData,
                    appointment_date        <- date,
                    appointment_updated     <- date_updated
                )
                try db!.run(updateQuery)
                print("Success updating Appointment")
            }
            else{
                let insertQuery = appointment_tbl.insert(
                    appointment_id          <- id,
                    appointment_status      <- status,
                    appointment_object      <- objectData,
                    appointment_date        <- date,
                    appointment_updated     <- date_updated
                )
                try db!.run(insertQuery)
            }
        }
        catch{
            print("ERROR updating Appointment: \(error)")
        }
    }
    
    func getAppointmentString(unique_id:Int) -> String{
        
        var returnAppointment = "{}"
        print("id get: \(unique_id)")
        do{
            let filterUpdate = appointment_tbl.filter(appointment_id == unique_id)
            let query        = try db!.pluck(filterUpdate)
            let countQuery   = try db!.scalar(filterUpdate.count)
            if(countQuery <= 0){
                return returnAppointment
            }
            else{
                returnAppointment = query![appointment_object]
                return returnAppointment
            }
        }
        catch{
            print("ERROR appointment Date: \(error)")
        }
        return returnAppointment
    }
    
    func deleteAppointment(id:Int){
        do{
            let statement = appointment_tbl.filter(appointment_id == id)
            try db!.run(statement.delete())
        }
        catch{
            print("ERROR Delete Appointment \(error)")
        }
    }

    
    //chat thread CRUD
  
    
    
    func updateIfUserIsBlocked(thread_id:Int){
        do{
            let filterUpdate = chat_thread_tbl.filter(chat_thread_id == thread_id)
            let updateQuery  = filterUpdate.update(
                thread_is_block      <- 1
            )
            try db!.run(updateQuery)
            print("Success updating Chat blocked")
        }
        catch{
            print("Error update block user: \(error)")
        }
    }
    
    func updateIfUserMessageIsSeen(thread_id:Int){
        do{
            let filterUpdate = chat_thread_tbl.filter(chat_thread_id == thread_id)
            let updateQuery  = filterUpdate.update(
                thread_is_seen      <- 1
            )
            try db!.run(updateQuery)
            print("Success updating Chat thread if seen")
        }
        catch{
             print("Error update CHAT THREAD SEEN: \(error)")
        }
    }
   
    func deleteChatThread(){
        do{
            try db!.run(chat_thread_tbl.delete())
        }
        catch{
            print("ERROR Delete Chat thread \(error)")
        }
    }
    
    func returnAllChatThread() -> Dictionary<String,Any>{
        
        var arrayThread  = [Int]()
        var arrayChat    = [Int]()
        var objectDetails   = Dictionary<String,Any>()
      
        do{
            let query = try db!.prepare(self.chat_thread_tbl)
            let countData = try db!.scalar(self.chat_thread_tbl.count)
            print("Count Thread: \(countData)")
            
            for rows in query {
                let res_thread_id       = try rows.get(thread_id)
                let whereClause          = chat_tbl.where(chat_thread_id == res_thread_id)
                                                .where(chat_status == "sent")
                                                .order(chat_datetime.desc)
                                                .limit(1)
                let queryLastChat       = try db!.pluck(whereClause)
                let chatID              = try queryLastChat?.get(chat_id)
                arrayThread.append(res_thread_id)
                arrayChat.append(chatID!)
                print("thread_id & last chat ID: \(res_thread_id) - \(chatID)")
            }
            
            objectDetails["arrayThreadID"] = arrayThread
            objectDetails["arrayLastID"]   = arrayChat
            return objectDetails
        }
        catch{
            print("ERROR Retrieving chat: \(error)")
        }
        objectDetails["arrayThread"] = arrayThread
        objectDetails["arrayChatID"] = arrayChat
        return objectDetails
    }
    
    func countMessage()->Int{
        var countAll = 0
        do{
            let whereClause     = chat_thread_tbl.where(thread_is_seen == 0)
            countAll            = try db!.scalar(whereClause.count)
            return countAll
        }
        catch{
            print("ERROR Retrieving chat: \(error)")
        }
        return countAll
    }
    
    
    //chat tbl CRUD
    func insertOrUpdateChat(chatID:Int,chatSenderID:Int,chatReceiverID:Int,chatThreadID:Int,chatTitle:String,chatBody:String,chatMessageData:String,dateTime:String,chatIsRead:String,chatStatus:String){
        
        let utilities           = Utilities()
        do{
            let convertedDateTime = utilities.convertStringToDateTime(stringDate: dateTime)
            let whereClause     = chat_tbl.filter(chat_id == chatID)
            let countData       = try db!.scalar(whereClause.count)
            if countData  > 0 {
                let updateQuery = whereClause.update(
                    self.chat_title         <- chatTitle,
                    self.chat_body          <- chatBody,
                    self.chat_data          <- chatMessageData,
                    self.chat_read_at       <- chatIsRead,
                    self.chat_status        <- chatStatus,
                    self.chat_datetime      <- convertedDateTime
                )
                try db!.run(updateQuery)
                print("Success updating Chat message")
            }
            else{
                let insertChat = chat_tbl.insert(
                    chat_id                 <- chatID,
                    chat_sender_id          <- chatSenderID,
                    chat_recipient_id       <- chatReceiverID,
                    chat_thread_id          <- chatThreadID,
                    chat_title              <- chatTitle,
                    chat_body               <- chatBody,
                    chat_data               <- chatMessageData,
                    chat_datetime           <- convertedDateTime,
                    chat_read_at            <- chatIsRead,
                    chat_status             <- chatStatus
                )
                try db!.run(insertChat)
                print("Success inserting Chat message")
            }
        }
        catch{
            print("ERROR INSERTING CHAT: \(error)")
        }
    }
    
    func insertOrUpdateThread(id:Int,name:String,dateTime:String,creator_id:Int,chat_participants_id:String,user_image:String){
        
        do{
            let whereClause     = chat_thread_tbl.filter(self.thread_id == id)
            let countData       = try db!.scalar(whereClause.count)
            if countData  > 0 {
                let updateQuery = whereClause.update(
                    self.thread_name           <- name,
                    self.thread_datetime       <- dateTime,
                    self.thread_user_image     <- user_image,
                    self.thread_is_seen        <- 0
                )
                try db!.run(updateQuery)
                print("Success updating Chat thread")
            }
            else{
                let insertQuery = chat_thread_tbl.insert(
                    self.thread_id               <- id,
                    self.thread_name             <- name,
                    self.thread_datetime         <- dateTime,
                    self.thread_is_seen          <- 0,
                    self.thread_participants     <- chat_participants_id,
                    self.thread_creator_id       <- creator_id,
                    self.thread_is_block         <- 0,
                    self.thread_user_image       <- user_image
                )
                try db!.run(insertQuery)
            }
        }
        catch{
            print("ERROR updating Chat thread: \(error)")
        }
    }
    
//    func updateThreadTime(dateTime:String,thread_id:Int,isRead:Int){
//        do{
//            let filterUpdate = chat_thread_tbl.filter(chat_thread_id == thread_id)
//            let updateQuery  = filterUpdate.update(
//                thread_datetime      <- dateTime
//            )
//            try db!.run(updateQuery)
//            print("Success updating Chat thread time")
//        }
//        catch{
//            print("Error update CHAT THREAD TIME: \(error)")
//        }
//    }
    func updateThreadTime(threadID:Int,datetime:String,isRead:Int){
        
        do{
            let whereClause     = chat_thread_tbl.filter(thread_id == threadID)
            let updateQuery     = whereClause.update(
                self.thread_datetime       <- datetime,
                self.thread_is_seen        <- isRead
                
            )
            try db!.run(updateQuery)
        }
        catch{
            print("Error update CHAT THREAD TIME: \(error)")
        }
    }
    
    func markMessageAsSeen(threadID:Int,message_id:Int){
        
        let utilities   = Utilities()
        let currentDate = utilities.getCurrentDateTime(ifDateOrTime: "datetime")
        do{
            let filterUpdate = chat_tbl.where(chat_read_at == "")
                                        .where(chat_recipient_id == user_id)
                                        .where(chat_id == message_id)
            let updateQuery  = filterUpdate.update(
                chat_read_at      <- currentDate
            )
            try db!.run(updateQuery)
           
        }
        catch{
            print("Error  updating Chat if seen: \(error)")
        }
    }
    
    func markThreadAsSeen(threadID:Int){
        
        let utilities   = Utilities()
        do{
            let filterThread = chat_thread_tbl.filter(thread_id == threadID)
            let updateThread  = filterThread.update(
                thread_is_seen      <- 1
            )
            try db!.run(updateThread)
        }
        catch{
            print("Error  updating Chat if seen: \(error)")
        }
    }
    
    
    
    func deleteChatMessage(){
        do{
            //            let statement = chat_thread_tbl.filter(appointment_id == id)
            try db!.run(chat_tbl.delete())
        }
        catch{
            print("ERROR Delete Chat message: \(error)")
        }
    }
    
    func deleteSpecificChatMessage(chatID:Int){
        do{
            let statement = chat_tbl.where(chat_id == chatID)
            try db!.run(statement.delete())
        }
        catch{
            print("ERROR Delete Chat message: \(error)")
        }
    }
    
    func returnArrayChatThread() -> [ArrayChatThread]{
        
        let utilities           = Utilities()
        var arrayChatThread     = [ArrayChatThread]()
        do{
            let query        = try db!.prepare(chat_thread_tbl)
            for rows in query {
                
                var objectRows          = Dictionary<String,Any>()
                let thread_id           = try rows.get(self.thread_id)
                let thread_name         = try rows.get(self.thread_name)
                let thread_image        = try rows.get(self.thread_user_image)
                let thread_datetime     = try rows.get(self.thread_datetime)
                let thread_participants = try rows.get(self.thread_participants)
                let thread_creator_id   = try rows.get(self.thread_creator_id)
                let thread_is_block     = try rows.get(self.thread_is_block)
                
                let participants_data   = thread_participants.data(using: .utf8)
                let participant_ids     = try JSONDecoder().decode([Int].self, from: participants_data!)
                let chatArray           = self.returnChat(chat_thread_id: thread_id)

                objectRows["id"]                = thread_id
                objectRows["participant_ids"]   = participant_ids
                objectRows["created_by_id"]     = thread_creator_id
                objectRows["created_at"]        = thread_datetime
                objectRows["updated_at"]        = thread_datetime
                objectRows["thread_name"]       = thread_name
                objectRows["user_image"]        = thread_image
                
                let jsonString              = utilities.convertDictionaryToJSONString(dictionaryVal: objectRows)
                let jsonData                = jsonString.data(using: .utf8)
                var jsonDecodedThread       = try JSONDecoder().decode(ArrayChatThread.self, from: jsonData!)
                jsonDecodedThread.messages  = chatArray
                arrayChatThread.append(jsonDecodedThread)
                
            }
            return arrayChatThread
        }
        catch{
            print("ERROR returning chat thread: \(error)")
        }
        return arrayChatThread
    }
    
    func returnNotifications() -> String{
        var stringReturn        = ""
        var arrayNotification   = [Dictionary<String,Any>]()
        do{
            let query        = try db!.prepare(notification_tbl)
            for rows in query {
                
                let id                  = rows[notification_id]
                let datetime            = rows[notification_datetime]
                let title               = rows[notification_title]
                let body                = rows[notification_body]
                let unique_id           = rows[notification_unique_id]
                let isRead              = rows[notification_is_seen]
                let type                = rows[notification_type]
                
                var objectData           = Dictionary<String,Any>()
                objectData["title"]      = title
                objectData["body"]       = body
                objectData["unique_id"]  = unique_id
                
                
                
                var objectNotification   = Dictionary<String,Any>()
                objectNotification["id"]                    = id
                objectNotification["notification_type"]     = type
                objectNotification["created_at"] = datetime
                objectNotification["isRead"] = isRead
                objectNotification["notification_data"] = objectData
                arrayNotification.append(objectNotification)
            }
            stringReturn = Utilities().convertJSONArrayToString(objectParse: arrayNotification)
            return stringReturn
        }
        catch{
            print("ERROR returning notifications: \(error)")
        }
        return stringReturn
    }
    
    func returnChatThread(threadID:Int) -> [ArrayChatThread]{
        let utilities           = Utilities()
        var arrayChatThread     = [ArrayChatThread]()
        do{
            let whereClause         = self.chat_thread_tbl.where(self.thread_id == threadID)
            let queryLastChat       = try db!.pluck(whereClause)
            
            var objectRows          = Dictionary<String,Any>()
            let thread_id           = try queryLastChat?.get(self.thread_id)
            let thread_name         = try queryLastChat?.get(self.thread_name)
            let thread_image        = try queryLastChat?.get(self.thread_user_image)
            let thread_datetime     = try queryLastChat?.get(self.thread_datetime)
            let thread_participants = try queryLastChat?.get(self.thread_participants)
            let thread_creator_id   = try queryLastChat?.get(self.thread_creator_id)
            let thread_is_block     = try queryLastChat?.get(self.thread_is_block)
            
            let participants_data   = thread_participants?.data(using: .utf8)
            let participant_ids     = try JSONDecoder().decode([Int].self, from: participants_data!)
            let chatArray           = self.returnChat(chat_thread_id: thread_id!)
            
            objectRows["id"]                = thread_id
            objectRows["participant_ids"]   = participant_ids
            objectRows["created_by_id"]     = thread_creator_id
            objectRows["created_at"]        = thread_datetime
            objectRows["updated_at"]        = thread_datetime
            objectRows["thread_name"]       = thread_name
            objectRows["user_image"]        = thread_image
            
            let jsonString              = utilities.convertDictionaryToJSONString(dictionaryVal: objectRows)
            let jsonData                = jsonString.data(using: .utf8)
            var jsonDecodedThread       = try JSONDecoder().decode(ArrayChatThread.self, from: jsonData!)
            jsonDecodedThread.messages  = chatArray
            arrayChatThread.append(jsonDecodedThread)
            
            return arrayChatThread
        }
        catch{
            print("ERROR returning chat thread: \(error)")
        }
        return arrayChatThread
    }
    
   
    
    func returnChat(chat_thread_id:Int) -> [ArrayChatMessage]{
        
        let utilities     = Utilities()
        var arrayMessages = [ArrayChatMessage]()
        do{
            let whereClause  = chat_tbl.where(self.chat_thread_id == chat_thread_id)
                                        .where(self.chat_title == "")
            let query        = try db!.prepare(whereClause)
            for rows in query {
                var objectRows          = Dictionary<String,Any>()
                let chat_id             = try rows.get(self.chat_id)
                let chat_thread_id      = try rows.get(self.chat_thread_id)
                let chat_sender_id      = try rows.get(self.chat_sender_id)
                let chat_recipient_id   = try rows.get(self.chat_recipient_id)
                let chat_title          = try rows.get(self.chat_title)
                let chat_body           = try rows.get(self.chat_body)
                let chat_data           = try rows.get(self.chat_data)
                let chat_datetime       = utilities.convertDateTimeToString(date: (try rows.get(self.chat_datetime)))
                let chat_read_at        = try rows.get(self.chat_read_at)
                let chat_status         = try rows.get(self.chat_status)
                let is_closed           = 0
                let is_deleted          = 0
              
                objectRows["id"]                = chat_id
                objectRows["sender_id"]         = chat_sender_id
                objectRows["recipient_id"]      = chat_recipient_id
                objectRows["message_thread_id"] = chat_thread_id
                objectRows["is_closed"]         = is_closed
                objectRows["title"]             = chat_title
                objectRows["body"]              = chat_body
                objectRows["message_data"]      = chat_data
                objectRows["read_at"]           = chat_read_at
                objectRows["created_at"]        = chat_datetime
                objectRows["updated_at"]        = chat_datetime
                objectRows["deleted_to_id"]     = is_deleted
                objectRows["status"]            = chat_status
                
                let jsonStringThread            = utilities.convertDictionaryToJSONString(dictionaryVal: objectRows)
                let jsonDataThread              = jsonStringThread.data(using: .utf8)
                let jsonDecodedThread           = try JSONDecoder().decode(ArrayChatMessage.self, from: jsonDataThread!)
                arrayMessages.append(jsonDecodedThread)
            }
            return arrayMessages
        }
        catch{
            print("ERROR returning chat message: \(error)")
        }
        return arrayMessages
    }
    
    
    func insertDeviceToken(deviceToken:String){
        
        do{
            let insertQuery = device_token_tbl.insert(
                self.device_token <- deviceToken
            )
            try db!.run(insertQuery)
        }
        catch{
             print("ERROR Inserting DeviceToken: \(error)")
        }
    }
    
    func returnDeviceToken() ->String{
        do{
            if let queryToken = try db!.pluck(device_token_tbl){
                return queryToken[device_token]
            }
        }
        catch{
            print("error retrieving logs")
        }
        return ""
    }
    
    func deleteDeviceToken(){
        do{
            try db!.run(device_token_tbl.delete())
        }
        catch{
            print("ERROR deleting DeviceToken: \(error)")
        }
    }
    
    func insertBranchRating(review_id:Int){
        do{
            let insertQuery = branch_rating_tbl.insert(
                self.branch_rating_id <- review_id
            )
            try db!.run(insertQuery)
        }
        catch{
            print("ERROR Inserting BRanch rating: \(error)")
        }
    }

    func returnBranchRating() -> Int{
        var review_id = 0
        do{
            if let queryRating = try db!.pluck(branch_rating_tbl){
                review_id = queryRating[branch_rating_id]
                return review_id
            }
        }
        catch{
            print("error retrieving BRanch rating")
        }
        return review_id
    }
    
    func deleteBranchRating(){
        do{
            try db!.run(branch_rating_tbl.delete())
        }
        catch{
            print("ERROR deleting BRanch rating: \(error)")
        }
    }
    
    func deleteSpecificBranchRating(review_id:Int){
        do{
            let filterUpdate = appointment_tbl.filter(branch_rating_id == review_id)
            try db!.run(filterUpdate.delete())
        }
        catch{
            print("ERROR deleting BRanch rating: \(error)")
        }
    }
   
    
    func insertNotification(id:Int,datetime:String,type:String,is_seen:Int,title:String,body:String,unique_id:Int){
        do{
            let insertQuery = notification_tbl.insert(
                self.notification_id          <- id,
                self.notification_datetime    <- datetime,
                self.notification_type        <- type,
                self.notification_is_seen     <- is_seen,
                self.notification_title       <- title,
                self.notification_body        <- body,
                self.notification_unique_id   <- unique_id
            )
            try db!.run(insertQuery)
        }
        catch{
            print("error inserting Notifications: \(error)")
        }
    }
    
    func updateNotificationAsSeen(id:Int){
        do{
            let whereClause     = notification_tbl.filter(self.notification_id == id)
            let updateQuery     = whereClause.update(
                self.notification_is_seen           <- 1
            )
            try db!.run(updateQuery)
        }
        catch{
            print("error updating as seen Notifications: \(error)")
        }
    }
    
    func countNotifications() -> Int{
        var countUnseen = 0
        do{
            let whereClause = notification_tbl.filter(self.notification_is_seen == 0)
            countUnseen     = try db!.scalar(whereClause.count)
            return countUnseen
        }
        catch{
            print("error retrieving notification: \(error)")
        }
        return countUnseen
    }
    
    func getLastNotificationID() -> Int{
        var notificationID = 0
        do{
            let whereClause = notification_tbl.order(notification_id.desc)
            let query       = try db!.pluck(whereClause)
            if let queryStatement           = try db?.pluck(whereClause) {
                notificationID  = queryStatement[notification_id]
            }
            return notificationID
        }
        catch{
            print("error retrieving notification: \(error)")
        }
        return notificationID
        
    }
    
    

    
    
    
    
    
}
