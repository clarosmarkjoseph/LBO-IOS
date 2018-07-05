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
        //convert Dictionary to String
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
            let updateUser = user_tbl.update(
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
    
    
    
    
    func deleteBranches(){
        do{
            try db!.run(branch_tbl.delete())
        }
        catch{
            print("ERROR DELETE BRANCH : \(error)")
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
        do{
            let insertCarousel = carousel_tbl.insert(carousel_version  <- version_no, carousel_array <- arrayCarousel, carousel_date_added <- "")
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
        do{
            let insertPremiere = promotion_tbl.insert(
                promotion_array          <- arrayString,
                promotion_date_updated  <- date_updated
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
  
    func insertOrUpdateAppointment(id:Int,status:String,objectData:String,date:String,date_updated:String){
        do{
            let filterUpdate = appointment_tbl.filter(appointment_id == id)
            let countData    = try db!.scalar(filterUpdate.count)
            if try countData  > 0 {
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
    
    func deleteAppointment(id:Int){
        do{
            let statement = appointment_tbl.filter(appointment_id == id)
            try db!.run(statement.delete())
        }
        catch{
            print("ERROR Delete Appointment \(error)")
        }
    }
    
    func returnAppointment(id:Int)->String{
        var returnString = "[]"
        if(id <= 0){
            let query = appointment_tbl.select(appointment_object)
                .order(appointment_date.desc)
            returnString = String(describing: query)
            print(String(describing: query))
            return returnString
        }
        else{
            let query = appointment_tbl.select(appointment_object)
                .filter(appointment_id == id)
                .order(appointment_date.desc)
            returnString = String(describing: query)
            print(String(describing: query))
            return returnString
        }
        return returnString
    }
    
    func returnAppointmentByStatus(status:String)->String{
        var returnString = "{}"
        let query = appointment_tbl.select(appointment_object)
            .filter(appointment_status == status)
            .order(appointment_date.desc)
        returnString = String(describing: query)
        print(String(describing: query))
        return returnString
    }
    
    
   
    
   
    



   
    
    
    
    
}
