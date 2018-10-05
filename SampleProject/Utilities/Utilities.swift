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
import CoreLocation

public class Utilities{
    
    let dbclass = DatabaseHelper()
    
    func getUserObjectData() -> String{
        
        let user_tbl            = dbclass.user_tbl
        let userAddress:String    = "{}"
        do{
            if let queryUser   = try dbclass.db?.pluck(user_tbl){
                let stringObject        = queryUser[dbclass.user_object_data]
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
        let token:String = ""
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
        let user:Int     = 0
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
        let userName:String     = ""
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
                let stringObject        = queryUser[dbclass.user_object_data]
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
                let stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUser              = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                
                let clientData              = objectUser.user_data ?? "{}"
                let objectUserData          = convertJSONStringToData(arrayString: clientData)
                let objectUserDecoded       = try JSONDecoder().decode(ObjectUserData.self, from: objectUserData)
                let clientPremiereStatus    = objectUserDecoded.premier_status ?? 0
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
                let stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUser              = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                
                let clientData                  = objectUser.user_data ?? "{}"
                let objectUserData              = convertJSONStringToData(arrayString: clientData)
                let objectUserDecoded           = try JSONDecoder().decode(ObjectUserData.self, from: objectUserData)
                let premiere                    = getNumberValueInString(stringValue: "\(objectUserDecoded.premier_branch)")
                let idPremiere                  = Int(premiere) ?? 0
                return  idPremiere
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
                let stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUser              = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                
                let clientData          = objectUser.user_data ?? "{}"
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
                let stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUser              = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                
                let clientData          = objectUser.user_data ?? "{}"
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
        var userGender:String?  = ""
        do{
            if let queryUser   = try dbclass.db?.pluck(user_tbl){
                let stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUser              = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                userGender              = objectUser.gender ?? "female"
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
                let stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUser              = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                userEmail = objectUser.email ?? ""
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
                let stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUser              = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                userAddress             = objectUser.user_address ?? "-"
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
                let stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUser              = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                userAddress             = objectUser.user_mobile ?? "-"
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
                let stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUser              = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                userAddress             = objectUser.birth_date ?? "0000-00-00"
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
        let branch_tbl = dbclass.branch_tbl
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
        guard let jsonString    = String(data: jsonData!, encoding: .utf8) else { return "" }
        return jsonString
    }
    
    func convertJSONArrayToString(objectParse:[Dictionary<String, Any>]) ->String{
        let jsonData            = try? JSONSerialization.data(withJSONObject: objectParse, options: [])
        guard let jsonString    = String(data: jsonData!, encoding: .utf8) else { return "" }
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
            if(objectResponseError.count > 0){
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
        return weekday - 1
    }
    
    func getCurrentDateTime(ifDateOrTime:String) -> String{
        let dateFormatter           = DateFormatter()
        dateFormatter.dateFormat    = "yyyy-MM-dd" //Your date format
        dateFormatter.timeZone      = Calendar.current.timeZone //Current time zone
        let date                    = Date()
        
        if(ifDateOrTime == "datetime"){
            dateFormatter.dateFormat    = "yyyy-MM-dd HH:mm"
            let newDate = dateFormatter.string(from: date)
            return newDate
        }
        if(ifDateOrTime == "datetimeseconds"){
            dateFormatter.dateFormat    = "yyyy-MM-dd HH:mm:ss"
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
        
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 75, y: view.frame.size.height-100, width: 250, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 10.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines  = 0
        view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseIn, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func getPLCCaption(index:Int) -> String{
       
        let data_caption = ["Sorry, Based on our current system records, your transaction total doesn't meet the minimum qualified amount (Php 5,000.00). You may request us to review your transactions by clicking the button below.",
        "With your current transaction that greater than Php 5,000.00, you are now qualified to Premier Loyalty Card Application. Just Click the button below to apply digitally.",
        "Congratulations! Your application is approved! Please wait for the application to be process.\nExpect 2-3 weeks of waiting time before you can get your PLC Card",
        "Your application is currently on process. Expect 2-3 weeks of waiting time before you can get your PLC Card",
        "Your card is deployed and currently delivering to it's respective branch so you can pick it up. We will email you once the card is ready to pick-up.\nThank you for waiting.",
        "Your card is ready and you may pick-up your card in the branch that you selected. Please mark your card as 'Picked-up' once you've received the card. \n Thank your for waiting.",
        "You already picked-up your card. Enjoy 10% discounts to all Lay Bare branches and the perks and discounts to our partners found in our Website. Feel free to request a replacement if you lost your card",
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
    
    func returnGoogleAPIKey() -> String{
       return "AIzaSyDbIhpwNxlOyxl5MKnBczkl4b2s7RXp1Vs"
    }
    
    func getDistanceOfLocation(currentLat:Double,currentLng:Double,destinationLat:Double,destinationLng:Double) -> Double{
        let currentLocation     = CLLocation(latitude: currentLat, longitude: currentLng)
        let destinationLocation = CLLocation(latitude: destinationLat, longitude: destinationLng)
        let distanceInMeters    = currentLocation.distance(from: destinationLocation)
        let distanceKM          = distanceInMeters / 1000
        let distanceRounded     = Double(String(format: "%.2f", distanceKM)) ?? 0.0
        return distanceRounded
        
    }
    
    func openFacebookPage(){
        let fbAppUrl = URL(string: "fb://page/?id=7037766039")
        let fbWebUrl = URL(string: "https://www.facebook.com/OfficialLayBare/")
        let openURL =  UIApplication.shared.canOpenURL(fbAppUrl!)
        if(UIApplication.shared.openURL(fbAppUrl!)){
            UIApplication.shared.openURL(fbAppUrl!)
        }
        else{
            UIApplication.shared.openURL(fbWebUrl!)
        }
    }
    
    func convertDistanceToString(distance:Double) -> String{
        let distanceInKM:Double = distance / 1000.0
        return String(format: "%.2f", distanceInKM)
    }
    
    func convertStringToDouble(stringValue:String) -> Double{
        var value   = 0.0
        value       = (stringValue as NSString).doubleValue
        return value
    }
    
    func convertStringToInt(stringValue:String) -> Int{
        var value   = 0
        value       = (stringValue as NSString).integerValue
        return value
    }
    
    
    func compressImage(image:UIImage) -> Data {
        // Reducing file size to a 10th
        
        var actualHeight : CGFloat = image.size.height
        var actualWidth : CGFloat = image.size.width
        let maxHeight : CGFloat = 1136.0
        let maxWidth : CGFloat = 640.0
        var imgRatio : CGFloat = actualWidth/actualHeight
        let maxRatio : CGFloat = maxWidth/maxHeight
        var compressionQuality : CGFloat = 0.5
        
        if (actualHeight > maxHeight || actualWidth > maxWidth){
            if(imgRatio < maxRatio){
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio){
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else{
                actualHeight = maxHeight;
                actualWidth = maxWidth;
                compressionQuality = 1;
            }
        }
        
        var rect =  CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContext(rect.size);
        image.draw(in: rect)
        var img = UIGraphicsGetImageFromCurrentImageContext();
        let imageData = UIImageJPEGRepresentation(img!, compressionQuality);
        UIGraphicsEndImageContext();
        
        return imageData!
    }
    
    func convertImageviewToBase64String(imgView:UIImage) -> String{
       
        let imageData:Data      = UIImageJPEGRepresentation(imgView,0.4) as! Data
        let strBase64           = imageData.base64EncodedString(options: .lineLength64Characters)
        print("Image size: \(imageData)")
        return " data:image/jpeg;base64,\(strBase64)"
    }
    
    //get time ago (String)
    func getTimeAgo(dateSet:Date,ifSpecific:Bool) -> String {
        
        let calendar    = Calendar.current
        let currentDate = Date()
        
        let dateStart   = calendar.startOfDay(for: dateSet)
        let dateEnd     = calendar.startOfDay(for: currentDate)
        
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let components              = calendar.dateComponents(unitFlags, from: dateSet, to:  currentDate)
        
        let componentDateSet        = calendar.dateComponents(unitFlags, from: dateStart)
        let componentDateCurrent    = calendar.dateComponents(unitFlags, from: dateEnd)
        
        let dateFormatter           = DateFormatter()
        dateFormatter.dateFormat    = "yyyy-MM-dd"
        let stringCurrentDate       = dateFormatter.string(from: currentDate)
        let stringtDateParams       = dateFormatter.string(from: dateSet)
        if(componentDateSet.year == componentDateCurrent.year){
            
            if(stringCurrentDate == stringtDateParams){
                if components.minute! <= 5{
                    if (ifSpecific == true){
                        let dateFormatter        = DateFormatter()
                        dateFormatter.dateFormat = "hh:mm a"
                        let returnValue          = dateFormatter.string(from:dateSet)
                        return returnValue
                    }
                    else{
                        return "now"
                    }
                }
                else{
                    let dateFormatter        = DateFormatter()
                    dateFormatter.dateFormat = "hh:mm a"
                    let returnValue          = dateFormatter.string(from:dateSet)
                    return returnValue
                }
            }
            
            else if components.month! >= 1{
                let dateFormatter        = DateFormatter()
                if (ifSpecific == true){
                    dateFormatter.dateFormat = "MMMM dd hh:mm a"
                }
                else{
                    dateFormatter.dateFormat = "MMMM dd"
                }
                let returnValue = dateFormatter.string(from:dateSet)
                return returnValue
            }
            else {
                if components.day! >= 7{
                    let dateFormatter        = DateFormatter()
                    if (ifSpecific == true){
                        dateFormatter.dateFormat = "MMMM dd, hh:mm a"
                    }
                    else{
                        dateFormatter.dateFormat = "MMMM dd"
                    }
                    let returnValue = dateFormatter.string(from:dateSet)
                    return returnValue
                }
                else{
                    let dateFormatter        = DateFormatter()
                    if (ifSpecific == true){
                        dateFormatter.dateFormat = "EE, hh:mm a"
                    }
                    else{
                        dateFormatter.dateFormat = "EE"
                    }
                    let returnValue = dateFormatter.string(from:dateSet)
                    return returnValue
                }
                
            }
        }
        else{
            let dateFormatter        = DateFormatter()
            if (ifSpecific == true){
                dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
            }
            else{
                dateFormatter.dateFormat = "MM/dd/yyyy"
            }
            let returnValue = dateFormatter.string(from:dateSet)
            return returnValue
        }
    }
    
    
    func deleteAllData(){
        
        dbclass.deletePremiere()
        dbclass.deleteChatThread()
        dbclass.deleteChatMessage()
        dbclass.deleteTransactionRequest()
        dbclass.deleteUserAccount()
        dbclass.deleteAppointments()
        dbclass.deletePremier()
        dbclass.deleteBranchRating()
        
    }
    
//    func stringFromHtml(string: String) -> NSAttributedString? {
//        do {
//            let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
//            if let d = data {
//                let attrStr     = try? NSAttributedString( // do catch
//                                data: data!,
//                                options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
//                                documentAttributes: nil
//                            )
//                return attrStr
//            }
//        } catch {
//            
//        }
//        return nil
//    }
    
    
    
}


//extension String{
//    func convertHtml() -> NSAttributedString{
//        guard let data = data(using: .utf8) else { return NSAttributedString() }
//        do{
//            return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
//        }catch{
//            return NSAttributedString()
//        }
//    }
//}




