//
//  UserProfileController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/20/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Alamofire

class UserProfileController: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblClientName: UILabel!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var lblBday: UILabel!
    @IBOutlet var lblContact: UILabel!
    @IBOutlet var lblGender: UILabel!
    @IBOutlet var lblHomeBranch: UILabel!
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var tblProfile: UITableView!
    var objectUserAccount:ObjectUserAccount? = nil
    let utilities       = Utilities()
    let dbclass         = DatabaseHelper()
    var SERVER_URL      = ""
    var ifProfileLoaded = false
    let dialogUtil      = DialogUtility()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SERVER_URL = dbclass.returnIp()
    }
    
    @objc func imageTapped(sender:AnyObject){
        print("Image view Tapped")
        checkPermission()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        ifProfileLoaded = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector(imageTapped(sender:) ))
        imgProfile.isUserInteractionEnabled = true
        imgProfile.addGestureRecognizer(tapGestureRecognizer)
        loadProfileDetails()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    func loadProfileDetails(){
        let user_tbl            = dbclass.user_tbl
        do{
            if let queryUser   = try dbclass.db?.pluck(user_tbl){
                let stringObject        = queryUser[dbclass.user_object_data]
                let jsonData            = stringObject.data(using: .utf8)
                objectUserAccount       = try JSONDecoder().decode(ObjectUserAccount.self, from: jsonData!)
                let clientName          = objectUserAccount?.username ?? "N/A"
                let clientGender        = objectUserAccount?.gender ?? "N/A"
                let clientAddress       = objectUserAccount?.user_address ?? "N/A"
                let clientBday          = objectUserAccount?.birth_date ?? "0000-00-00"
                let clientMobile        = objectUserAccount?.user_mobile ?? "N/A"
                let clientEmail         = objectUserAccount?.email ?? "N/A"
                var clientImage         = objectUserAccount?.user_picture ?? "no image \(clientGender.lowercased()).png"
                let clientData          = objectUserAccount?.user_data ?? "{}"
                let objectUserData      = utilities.convertJSONStringToData(arrayString: clientData)
                let objectUserDecoded   = try JSONDecoder().decode(ObjectUserData.self, from: objectUserData)
                let clientBranchID      = objectUserDecoded.home_branch ?? 0
                let clientBranchName    = utilities.getBranchName(branch_id: clientBranchID )
                
                lblClientName.text      = clientName
                lblBday.text            = utilities.getCompleteDateString(stringDate: clientBday)
                lblContact.text         = clientMobile
                lblGender.text          = clientGender.capitalized
                lblHomeBranch.text      = clientBranchName
                lblEmail.text           = clientEmail
                lblAddress.text         = clientAddress
                clientImage             = clientImage.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
                let stringURL           = SERVER_URL+"/images/users/"+clientImage
                let url                 = URL(string: stringURL)
                imgProfile.kf.setImage(with: url,
                                              placeholder: UIImage(named: "noImage"),
                                              options: nil,
                                              progressBlock: nil,
                                              completionHandler: { (image: UIImage?, error: Error?, cache, url) in
                                                if error != nil {
                                                    self.imgProfile.image = UIImage(named: "noImage")
                                                }
                })
                tblProfile.reloadData()
            }
            else{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        catch{
            print("User retrieve error: \(error)")
        }
    }
   
    
    func checkPermission(){
        //Camera
    
        chooseImage()
    }
    
    func chooseImage(){
        
        let imagePickerController       = UIImagePickerController()
        imagePickerController.delegate  = self
        let photoPermission             = PHPhotoLibrary.authorizationStatus()
        
        let alertView = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        let btnCamera          = UIAlertAction(title: "Camera", style: .default) { (action) in
            imagePickerController.sourceType = .camera
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if response {
                    self.present(imagePickerController, animated: true, completion: nil)
                }
                else {
                    self.showDialog(title: "Permission Denied!", message: "You just disabled camera permission. Please allow it and try again",action: "permission")
                    alertView.dismiss(animated: true, completion: nil)
                }
            }
        }
        let btnPhotoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            imagePickerController.sourceType = .photoLibrary
           
            if photoPermission == .notDetermined{
                PHPhotoLibrary.requestAuthorization({status in
                    if status == .authorized{
                        self.present(imagePickerController, animated: true, completion: nil)
                    }
                    else {
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
            else if photoPermission == .denied {
                self.showDialog(title: "Permission Denied!", message: "You just disabled gallery permission. Please allow it and try again",action: "permission")
                return
            }
            else{
                 self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        let btnPhotoAlbum = UIAlertAction(title: "Photo Album", style: .default) { (action) in
            imagePickerController.sourceType = .savedPhotosAlbum
            self.present(imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertView.addAction(btnCamera)
        alertView.addAction(btnPhotoLibrary)
        alertView.addAction(btnPhotoAlbum)
        alertView.addAction(cancel)
        present(alertView,animated: true,completion: nil)
        
    }
    
    func showDialog(title:String,message:String,action:String){
        //alert box
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if action == "permission"{
            let confirm = UIAlertAction(title: "Check Permission", style: .default) { (action) in
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    // If general location settings are disabled then open general location settings
                    UIApplication.shared.openURL(url)
                }
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                
            }
            alertView.addAction(confirm)
            alertView.addAction(cancel)
        }
        else{
            let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
                
            }
            alertView.addAction(confirm)
        }
        present(alertView,animated: true,completion: nil)
    }

    func uploadImage(imgString:String){
        
        self.dialogUtil.showActivityIndicator(self.view)
        let userToken   = utilities.getUserToken()
        let user_id     = utilities.getUserID()
        let imageURL    = "\(SERVER_URL)/api/mobile/uploadUserImage?token=\(userToken)"
        let requestParams:Parameters   = [
            "upload_image":imgString,
            "upload_client_id":user_id
            ]
        let myURL = URL(string: imageURL)
        Alamofire.request(myURL!, method: .post, parameters: requestParams)
            .responseJSON { response in
                do{
                    guard let statusCode   = response.response?.statusCode else {
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again", action: "")
                        return
                    }
                    
                    if let responseJSONData = response.data{
                        self.dialogUtil.hideActivityIndicator(self.view)
                        if(statusCode == 200 || statusCode == 201){
                            let objectDictionary = response.result.value as! Dictionary<String,Any>
                            let imageDirectory   = objectDictionary["imageDirectory"] as! String
                            self.updateProfile(imageDirectory: imageDirectory)
                        }
                        else if(statusCode == 401){
                            self.dialogUtil.hideActivityIndicator(self.view)
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
                                self.showDialog(title:arrayError[0], message: arrayError[1],action: "")
                            }
                            else{
                                self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again",action: "")
                            }
                        }
                        
                    }
                    else{
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again",action: "")
                    }
                }
                catch{
                    print("ERROR catch: \(error)")
                    self.dialogUtil.hideActivityIndicator(self.view)
                    self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again",action: "")
                }
        }
        
    }
    
    func updateProfile(imageDirectory:String){
        
        do{
            objectUserAccount?.user_picture     = imageDirectory
            let jsonResultEncoded               = try JSONEncoder().encode(objectUserAccount)
            let jsonResultString                = String(data: jsonResultEncoded, encoding: .utf8)!
            
            dbclass.updateUserObject(jsonString:jsonResultString, date_updated: self.utilities.getCurrentDateTime(ifDateOrTime: "datetime"))
            self.showDialog(title: "Successfully uploaded!", message: "Your profile image is successfullt uploaded", action: "")
        }
        catch{
            print("error updating Profile Image: \(error)")
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        let image               = info[UIImagePickerControllerOriginalImage] as! UIImage
        imgProfile.image        = image
        let imgString           = utilities.convertImageviewToBase64String(imgView:image)
        uploadImage(imgString: imgString)
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let index = self.tblProfile.indexPathForSelectedRow{
            self.tblProfile.deselectRow(at: index, animated: true)
        }
        
        if(indexPath.row == 2){
            let storyBoard      = UIStoryboard(name:"UserProfile",bundle:nil)
            let viewcontroller  = storyBoard.instantiateViewController(withIdentifier: "UserProfileEditController") as! UserProfileEditController
            viewcontroller.indexPosition = 0
            self.navigationController?.pushViewController(viewcontroller, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
        if(indexPath.row == 4){
            let storyBoard      = UIStoryboard(name:"UserProfile",bundle:nil)
            let viewcontroller  = storyBoard.instantiateViewController(withIdentifier: "UserProfileEditController") as! UserProfileEditController
            viewcontroller.indexPosition = 1
            self.navigationController?.pushViewController(viewcontroller, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
        if(indexPath.row == 6){
            let storyBoard      = UIStoryboard(name:"UserProfile",bundle:nil)
            let viewcontroller  = storyBoard.instantiateViewController(withIdentifier: "UserProfileEditController") as! UserProfileEditController
            viewcontroller.indexPosition = 2
            self.navigationController?.pushViewController(viewcontroller, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
        else{
            print("indexPath.row \(indexPath.row)")
            return
        }
    }
    
 
    
 
    
}
