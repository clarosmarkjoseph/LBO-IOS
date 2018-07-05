//
//  Utilities.swift
//  SampleProject
//
//  Created by Paolo Hilario on 5/15/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import Foundation
import SQLite
import Alamofire
import Kingfisher


public class Utilities{
    
    let dbclass = DatabaseHelper()
    
    func getUserObjectData() -> String{
        
        var objectUser:ObjectUserAccount
        let user_tbl            = dbclass.user_tbl
        var userAddress:String    = "{}"
        do{
            if let queryUser   = try dbclass.db?.pluck(user_tbl){
                var stringObject        = queryUser[dbclass.user_object_data]
                return stringObject
            }
            else{
                return "{}"
            }
        }
        catch{
            print("ERROR retrieving USER Object Data: \(error)")
        }
        return userAddress
    }
    
    func getUserToken() -> String{
        
        let user_tbl     = dbclass.user_tbl
        var token:String = ""
        do{
            if let queryUser   = try dbclass.db?.pluck(user_tbl){
                return queryUser[dbclass.user_token]
            }
            return token
        }
        catch{
            print("ERROR retrieving TOKEN")
        }
         return token
    }
    
    func getUserID() -> Int{
        
        let user_tbl     = dbclass.user_tbl
        var user:Int     = 0
        do{
            if let queryUser   = try dbclass.db?.pluck(user_tbl){
               return queryUser[dbclass.user_id]
            }
            else{
                return user
            }
        }
        catch{
            print("ERROR retrieving ID")
        }
        return user
    }
    
    func getUserName() -> String{
        
        let user_tbl            = dbclass.user_tbl
        var userName:String     = ""
        do{
            if let queryUser   = try dbclass.db?.pluck(user_tbl){
               return queryUser[dbclass.user_name]
            }
            else{
                return userName
            }
        }
        catch{
            print("ERROR retrieving NAME")
        }
        return userName
    }
    
    func getUserImage() -> String{
        
        var objectUser:ObjectUserAccount
        let user_tbl            = dbclass.user_tbl
        var userImage:String    = ""
        do{
            if let queryUser   = try dbclass.db?.pluck(user_tbl){
                var stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUser              = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                userImage               = objectUser.user_picture!
                userImage               = userImage.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
                return userImage
            }
            else{
                return userImage
            }
        }
        catch{
            print("ERROR retrieving Image: \(error)")
        }
        return userImage
    }
    
    func getUserPremierStatus() -> Bool{
        
        var objectUser:ObjectUserAccount
        let user_tbl            = dbclass.user_tbl
        do{
            if let queryUser   = try dbclass.db?.pluck(user_tbl){
                var stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUser              = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                
                let clientData          = try objectUser.user_data ?? "{}"
                let objectUserData      = convertJSONStringToData(arrayString: clientData)
                let objectUserDecoded       = try JSONDecoder().decode(ObjectUserData.self, from: objectUserData)
                let clientPremiereStatus    = try objectUserDecoded.premier_status ?? 0
                if(clientPremiereStatus <= 0){
                    return false
                }
                else{
                    return true
                }
            }
            else{
                return false
            }
        }
        catch{
            print("ERROR retrieving PLC STATUS: \(error)")
        }
        return false
    }
    
    func getUserPremierBranchID() -> Int{
        
        var objectUser:ObjectUserAccount
        let user_tbl            = dbclass.user_tbl
        do{
            if let queryUser   = try dbclass.db?.pluck(user_tbl){
                var stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUser              = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                
                let clientData                  = try objectUser.user_data ?? "{}"
                let objectUserData              = convertJSONStringToData(arrayString: clientData)
                let objectUserDecoded           = try JSONDecoder().decode(ObjectUserData.self, from: objectUserData)
                return try objectUserDecoded.premier_branch ?? 0
            }
            else{
                return 0
            }
        }
        catch{
            print("ERROR retrieving PRemiere_branch: \(error)")
        }
        return 0
    }
    
    func getUserHomeBranch() -> Int{
        
        var objectUser:ObjectUserAccount
        let user_tbl            = dbclass.user_tbl
        do{
            if let queryUser   = try dbclass.db?.pluck(user_tbl){
                var stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUser              = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                
                let clientData          = try objectUser.user_data ?? "{}"
                let objectUserData      = convertJSONStringToData(arrayString: clientData)
                let objectUserDecoded   = try JSONDecoder().decode(ObjectUserData.self, from: objectUserData)
                let clientHomebranch    = objectUserDecoded.home_branch ?? 0

                return clientHomebranch
            }
            else{
                return 0
            }
        }
        catch{
            print("ERROR retrieving Home Branch: \(error)")
        }
        return 0
    }
    
    func getUserBOSSID() -> String{
        
        var objectUser:ObjectUserAccount
        let user_tbl            = dbclass.user_tbl
        do{
            if let queryUser   = try dbclass.db?.pluck(user_tbl){
                var stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUser              = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                
                let clientData          = try objectUser.user_data ?? "{}"
                let objectUserData      = convertJSONStringToData(arrayString: clientData)
                let objectUserDecoded   = try JSONDecoder().decode(ObjectUserData.self, from: objectUserData)
                let clientBossID        = objectUserDecoded.boss_id ?? "0"
                
                return clientBossID
            }
            else{
                return "0"
            }
        }
        catch{
            print("ERROR retrieving BOSS ID: \(error)")
        }
        return "0"
    }
    
    
    func getUserGender() -> String{
        
        var objectUser:ObjectUserAccount
        let user_tbl            = dbclass.user_tbl
        var userGender:String?  = nil
        do{
            if let queryUser   = try dbclass.db?.pluck(user_tbl){
                var stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUser              = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                userGender = objectUser.gender!
                return userGender!
            }
            else{
                return userGender!
            }
        }
        catch{
            print("ERROR retrieving Gender: \(error)")
        }
        return userGender!
    }
    
    func getUserEmail() -> String{
        var objectUser:ObjectUserAccount
        let user_tbl            = dbclass.user_tbl
        var userEmail:String    = ""
        do{
            if let queryUser   = try dbclass.db?.pluck(user_tbl){
                var stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUser              = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                userEmail = objectUser.email!
                print("User Image: \(userEmail)")
                return userEmail
            }
            else{
                return userEmail
            }
        }
        catch{
            print("ERROR retrieving Email: \(error)")
        }
        return userEmail
    }
    
    func getUserAddress() -> String{
        
        var objectUser:ObjectUserAccount
        let user_tbl            = dbclass.user_tbl
        var userAddress:String    = ""
        do{
            if let queryUser   = try dbclass.db?.pluck(user_tbl){
                var stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUser              = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                userAddress             = objectUser.user_address!
                return userAddress
            }
            else{
                return userAddress
            }
        }
        catch{
            print("ERROR retrieving USER ADDRESS: \(error)")
        }
        return userAddress
    }
    
    func getUserMobile() -> String{
        
        var objectUser:ObjectUserAccount
        let user_tbl            = dbclass.user_tbl
        var userAddress:String    = ""
        do{
            if let queryUser   = try dbclass.db?.pluck(user_tbl){
                var stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUser              = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                userAddress             = objectUser.user_mobile!
                return userAddress
            }
            else{
                return userAddress
            }
        }
        catch{
            print("ERROR retrieving MOBILE NO: \(error)")
        }
        return userAddress
    }
    
    func getUserBirthday() -> String{
        
        var objectUser:ObjectUserAccount
        let user_tbl            = dbclass.user_tbl
        var userAddress:String    = ""
        do{
            if let queryUser   = try dbclass.db?.pluck(user_tbl){
                var stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUser              = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                userAddress             = objectUser.birth_date!
                return userAddress
            }
            else{
                return userAddress
            }
        }
        catch{
            print("ERROR retrieving BDAY: \(error)")
        }
        return userAddress
    }
    
    
    //get the versions of details
    func getBranchVersion() -> Double{
        var branch_tbl = dbclass.branch_tbl
        do{
            if let queryBranch = try dbclass.db?.pluck(branch_tbl){
                return queryBranch[dbclass.branch_version]
            }
            else{
                return 0.0
            }
        }
        catch{
            return 0.0
        }
    }
    func getCarouselVersion() -> Double{
        let carousel_tbl = dbclass.carousel_tbl
        var returnVersion:Double = 0.0;
        do{
            if let queryBranch   = try dbclass.db?.pluck(carousel_tbl){
                returnVersion = queryBranch[dbclass.carousel_version]
                return returnVersion
            }
            return returnVersion
        }
        catch{
            return returnVersion
        }
         return returnVersion
    }

    func getServiceVersion() -> Double{
        let service_tbl = dbclass.service_tbl
        var returnVersion:Double = 0.0;
        do{
            if let queryBranch   = try dbclass.db?.pluck(service_tbl){
                returnVersion = queryBranch[dbclass.service_version]
                return returnVersion
            }
            return returnVersion
        }
        catch{
            return returnVersion
        }
        return returnVersion
    }
    
    func getProductVersion() -> Double{
        let product_tbl = dbclass.product_tbl
        var returnVersion:Double = 0.0;
        do{
            if let queryBranch   = try dbclass.db?.pluck(product_tbl){
                returnVersion = queryBranch[dbclass.product_version]
                return returnVersion
            }
            return returnVersion
        }
        catch{
            return returnVersion
        }
        return returnVersion
    }
    func getPackageVersion() -> Double{
        let package_tbl = dbclass.package_tbl
        var returnVersion:Double = 0.0;
        do{
            if let queryBranch   = try dbclass.db?.pluck(package_tbl){
                returnVersion = queryBranch[dbclass.package_version]
                return returnVersion
            }
            return returnVersion
        }
        catch{
            return returnVersion
        }
        return returnVersion
    }
    
    func getCommercialVersion() -> Double{
        let commercial_tbl = dbclass.commercial_tbl
        var returnVersion:Double = 0.0;
        do{
            if let queryBranch   = try dbclass.db?.pluck(commercial_tbl){
                returnVersion = queryBranch[dbclass.commercial_version]
                return returnVersion
            }
            return returnVersion
        }
        catch{
            return returnVersion
        }
        return returnVersion
    }
    
    func convertDictionaryToJSONString(dictionaryVal:Dictionary<String, Any>) ->String{
        let jsonData            = try? JSONSerialization.data(withJSONObject: dictionaryVal, options: [])
        guard let jsonString    = try String(data: jsonData!, encoding: .utf8) else { return "" }
        return jsonString
    }
    
    func convertJSONArrayToString(objectParse:[Dictionary<String, Any>]) ->String{
        let jsonData            = try? JSONSerialization.data(withJSONObject: objectParse, options: [])
        guard let jsonString    = try String(data: jsonData!, encoding: .utf8) else { return "" }
        return jsonString
    }
 
    func getBranchName(branch_id:Int) -> String{
        
        let branch_tbl       = dbclass.branch_tbl
        var returnBranchName = "None"
        if(branch_id == 0){
            return returnBranchName
        }
        else{
            do{
                if let queryBranch   = try dbclass.db?.pluck(branch_tbl){
                    let stringData   = queryBranch[dbclass.branch_array]
                    let jsonData     = convertJSONStringToData(arrayString: stringData)
                    let decodeBranch = try JSONDecoder().decode([ArrayBranch].self, from: jsonData)
                    for rows in decodeBranch{
                        let id = rows.id
                        if(id == branch_id){
                            returnBranchName = rows.branch_name!
                            return returnBranchName
                        }
                        else{
                            continue
                        }
                    }
                    return returnBranchName
                }
                return returnBranchName
            }
            catch{
                return returnBranchName
            }
        }
        return returnBranchName
    }
    
    func convertToStringCurrency(value:String) -> String{
//        print("COnvert- \(value)")
        var returnCurrency = ""
        let doubleVal  = Double(value)
        returnCurrency = String(format: "%.2f", doubleVal!)
        let floatValue = Double(returnCurrency)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator = ","
        numberFormatter.groupingSize = 3
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.decimalSeparator = "."
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = "Php "
        numberFormatter.maximumFractionDigits = 2
        returnCurrency = numberFormatter.string(from: floatValue! as NSNumber)!

        return returnCurrency
    }
    
    func convertDataToJSONString(data:Data) -> String{
        return String(data: data, encoding: .utf8)!
    }
    
    
    
  
    
    func showAlertDialogMessage(title:String,content:String,uiView:UIView){
        
//        let alertView = UIAlertController(title: title, message: content, preferredStyle: .alert)
//        
//        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
//            
//        }
//        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
//            
//        }
//        alertView.addAction(confirm)
//        alertView.addAction(cancel)
//        uiView.present(alertView,animated: true,completion: nil)
        
    }
    
    func showSheetDialogMessage(title:String,content:String){
        
//        let alertView = UIAlertController(title: title, message: content, preferredStyle: .actionSheet)
//        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
//
//        }
//        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
//
//        }
//        alertView.addAction(confirm)
//        alertView.addAction(cancel)
//        present(alertView,animated: true,completion: nil)
        
    }

    
    
    
    
    
    //
    //          ALL VALIDATIONS OF INPUT IS HERE
    //
    public func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    //alphanumeric input
    func checkIfAlphaNumeric(password:String) -> Bool{
        let letters = CharacterSet.letters
        let digits  = CharacterSet.decimalDigits
        
        var letterCount = 0
        var digitCount = 0
        
        for uni in password.unicodeScalars {
            if letters.contains(uni) {
                letterCount += 1
            } else if digits.contains(uni) {
                digitCount += 1
            }
        }
        
        if(letterCount > 0 && digitCount > 0){
            return true
        }
        return false
        
    }

    func calculateAge(birthday:String) -> Int{
       
        let dateFormater            = DateFormatter()
        dateFormater.dateFormat     = "yyyy-MM-dd"
        let birthdayDate            = dateFormater.date(from: birthday)
        let calendar: NSCalendar!   = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let now: NSDate!            = NSDate()
        let calcAge                 = calendar.components(.year, from: birthdayDate!, to: now as Date, options: [])
        let age                     = calcAge.year
        return age!
        
    }
    
    func handleHttpResponseError(objectResponseError:Dictionary<String,Any>,statusCode:Int) -> [String] {
        
        var arrayList = [String]()
        if(statusCode == 401){
            //token expired
            //delete User accounts
//            let errorMessage = objectResponse["error"] as! String
//            self.showDialog(title: "Error!", message: errorMessage)
            arrayList.append("Session Expired!")
            arrayList.append("Sorry, we would like to inform you that your session is expired(Logged-out from other device)")
        }
        else{
            if(objectResponseError != nil){
                if let arrayResponse =  objectResponseError["error"] as? NSArray {
                    var response = "An error occurred. Please fix the following: \r\n"
                    for row in arrayResponse{
                        response += "*\(row) \r\n";
                    }
                    arrayList.append("Message Alert!")
                    arrayList.append(response)
                }
                if let stringResponse = objectResponseError["error"] as? String {
                    let errorString = stringResponse
                    arrayList.append("Message Alert!")
                    arrayList.append(errorString)
                }
                else{
                    arrayList.append("Message Alert!");
                    arrayList.append("There was a problem connecting to Lay Bare App. Please check your connection and try again");
                }
            }
            else{
                arrayList.append("Message Alert!");
                arrayList.append("There was a problem connecting to Lay Bare App. Please check your connection and try again");
            }
        }
        
       
        return arrayList
    }
    
    
    func convertStringToDate(stringDate:String) -> Date{
        let dateFormatter           = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" //Your date format
        let newDate = dateFormatter.date(from: stringDate)
        return newDate!
    }
    
    func convertStringToDateTime(stringDate:String) -> Date{

        let dateFormatter           = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //Your date format
        let newDate = dateFormatter.date(from: stringDate)
        return newDate!
    }
    
    func convertDateToString(date:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let newDate = dateFormatter.string(from: date)
        return newDate
    }
    
    func convertDateTimeToString(date:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let newDate = dateFormatter.string(from: date)
        return newDate
    }
    
    
    func getDayOfWeek(dateSelected:Date) -> Int{
        let weekday = Calendar.current.component(.weekday, from: dateSelected)
        print("day of week: \(weekday - 1)")
        return weekday - 1
    }
    
    func getCurrentDateTime(ifDateOrTime:String) -> String{
        let dateFormatter           = DateFormatter()
        dateFormatter.dateFormat    = "yyyy-MM-dd" //Your date format
        dateFormatter.timeZone      = Calendar.current.timeZone //Current time zone
        let date                    = Date()
        let calendar                = Calendar.current

        if(ifDateOrTime == "datetime"){
            dateFormatter.dateFormat    = "yyyy-MM-dd HH:mm"
            let newDate = dateFormatter.string(from: date)
            return newDate
        }
        if (ifDateOrTime == "date"){
            dateFormatter.dateFormat    = "yyyy-MM-dd"
            let newDate = dateFormatter.string(from: date)
            return newDate
        }
        else{
            dateFormatter.dateFormat    = "HH:mm"
            let newDate = dateFormatter.string(from: date)
            return newDate
        }
        
    }
    
    func getDateOrTime(dateTime:Date,ifDateOrTime:String) -> Date{
        let dateFormatter           = DateFormatter()
        dateFormatter.dateFormat    = "yyyy-MM-dd HH:mm" //Your date format
        dateFormatter.timeZone      = Calendar.current.timeZone //Current time zone
        let stringDate              = dateFormatter.string(from: dateTime)
        if(ifDateOrTime == "date"){
            dateFormatter.dateFormat    = "yyyy-MM-dd"
            let newDate = dateFormatter.date(from: stringDate)
            return newDate!
        }
        else{
            dateFormatter.dateFormat    = "HH:mm"
            let newDate = dateFormatter.date(from: stringDate)
            return newDate!
        }
    }
    
    func getStandardTime(stringTime:String) -> String{

        let dateformater        = DateFormatter()
        dateformater.dateFormat = "HH:mm"
        var time = dateformater.date(from: stringTime)
        dateformater.dateFormat = "hh:mm a"
        let returntime = dateformater.string(from: time!)
        return returntime
    }
    
    func getMilitaryTime(stringTime:String) -> String{
        
        let dateformater        = DateFormatter()
        dateformater.dateFormat = "hh:mm a"
        var time = dateformater.date(from: stringTime)
        dateformater.dateFormat = "HH:mm"
        let returntime = dateformater.string(from: time!)
        return returntime
    }
    
    
    func getCompleteDateString(stringDate:String) -> String{
        var returnDateString        = ""
        let dateFormatter           = DateFormatter()
        dateFormatter.dateFormat    = "yyyy-MM-dd" //Your date format
        dateFormatter.timeZone      = Calendar.current.timeZone //Current time zone

        let decDate                 = dateFormatter.date(from: stringDate)
        dateFormatter.dateFormat    = "MMMM dd, yyyy"
        returnDateString            = dateFormatter.string(from: decDate!)
        return returnDateString
    }
    
    func getCompleteDateTimeString(stringDate:String) -> String{
        var returnDateString        = ""
        let dateFormatter           = DateFormatter()
        dateFormatter.dateFormat    = "yyyy-MM-dd HH:mm:ss" //Your date format
        dateFormatter.timeZone      = Calendar.current.timeZone //Current time zone
        
        let decDate                 = dateFormatter.date(from: stringDate)
        dateFormatter.dateFormat    = "MMMM dd, yyyy hh:mm a"
        returnDateString            = dateFormatter.string(from: decDate!)
        return returnDateString
    }
    
    func removeDateFromDatetime(stringDateTime:String) -> String{
        let dateFormatter           = DateFormatter()
        dateFormatter.dateFormat    = "yyyy-MM-dd HH:mm:ss" //Your date format
        dateFormatter.timeZone      = Calendar.current.timeZone //Current time zone
        let newDate                 = dateFormatter.date(from: stringDateTime)
        
        dateFormatter.dateFormat    = "HH:mm"
        let returnDate                 = dateFormatter.string(from: newDate!)
        return returnDate
    }
    
    func removeTimeFromDatetime(stringDateTime:String) -> String{
        let dateFormatter           = DateFormatter()
        dateFormatter.dateFormat    = "yyyy-MM-dd HH:mm:ss" //Your date format
        dateFormatter.timeZone      = Calendar.current.timeZone //Current time zone
        let newDate                 = dateFormatter.date(from: stringDateTime)
        
        dateFormatter.dateFormat    = "yyyy-MM-dd"
        let returnTime                 = dateFormatter.string(from: newDate!)
        return returnTime
    }
    
    func convertJSONStringToData(arrayString:String) -> Data{
        let jsonData            = arrayString.data(using: .utf8)
        return jsonData!;
    }
    
    func showToast(message : String,view:UIView) {
        
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 75, y: view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 10.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseIn, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func getPLCCaption(index:Int) -> String{
       
        let data_caption = ["Sorry, based on your record, your current total transaction doesn't reach the limit of application. To qualify for a Premier Loyalty Card, you must have accumulated a minimum of Php 5,000.00 of services availed. Feel free to email us or message us below to review your previous transaction",
        "With your current transaction that greater than Php 5,000.00, you are now qualified to Premier Loyalty Card Application. Just Click the button below to apply digitally.",
        "Congratulations! Your application is approved! Please wait for the application to be process.\nExpect 2-3 weeks of waiting time before you can get your PLC Card",
        "Your application is currently on process. Expect 2-3 weeks of waiting time before you can get your PLC Card",
        "Your card is deployed and currently delivering to it's respective branch so you can pick it up. We will email you once the card is ready to pick-up.\nThank you for waiting.",
        "Your card is ready and you may pick-up your card in the branch that you selected. Please mark your card as 'Picked-up' once you've received the card. \n Thank your for waiting.",
        "You already picked-up your card. Enjoy 20% discounts to all Lay Bare branches and the perks and discounts to our partners found in our website (https://lay-bare.com/plc-corner/). Feel free to request a replacement if you lost your card",
        "Your previous application is denied! \nReason:"]
        return data_caption[index];
        
    }
    
    func getNumberValueInString(stringValue:String) ->String{
        let stringArray      = stringValue.components(separatedBy: CharacterSet.decimalDigits.inverted)
        var returnStatment   = ""
        var countWholeNum    = 0
        for item in stringArray {
            if let number = Int(item) {
                if(countWholeNum >= 1){
                    returnStatment+=".\(number)"
                }
                else{
                    returnStatment+="\(number)"
                }
                countWholeNum+=1
                continue
            }
        }
        return returnStatment
    }
    
//    func convertStringToJSON(stringJSON:String) -> JSONSerialization{
//        let data = stringJSON.data(using: .utf8)!
//        do {
//            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>]{
//                return jsonArray
//            }
//            else {
//                print("bad json")
//            }
//        }
//        catch let error as NSError {
//            print(error)
//        }
//    }
    
    
}
