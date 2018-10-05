//
//  TransactionRequestController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/19/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import Photos

class TransactionRequestController: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    
    @IBOutlet var lblClientName: UILabel!
    @IBOutlet var lblClientGender: UILabel!
    @IBOutlet var lblBday: UILabel!
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var imgAttachment: UIImageView!
    @IBOutlet var lblAttachmentStatus: UILabel!
    @IBOutlet var btnUploadPhoto: UIButton!
    @IBOutlet var txtMessage: UITextField!
    let utilities           = Utilities()
    let dbclass             = DatabaseHelper()
    let dialogUtil          = DialogUtility()
    var imgAttachmentString = ""
    var SERVER_URL          = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SERVER_URL          = dbclass.returnIp()
        txtMessage.delegate = self
        loadProfileDetails()
    }
    
    func loadProfileDetails(){
        let clientName      = utilities.getUserName()
        let clientGender    = utilities.getUserGender()
        let clientBday      = utilities.getUserBirthday() ?? "0000-00-00"
        let clientEmail     = utilities.getUserEmail()
        
        if(clientName == "" || clientGender == "" || clientBday == "" || clientEmail == ""){
            btnUploadPhoto.isEnabled = false
            btnUploadPhoto.alpha     = 0.5
            btnUploadPhoto.setTitle("Cannot request if profile is incomplete", for: .disabled)
        }
        lblClientName.text      = clientName.capitalized
        lblClientGender.text    = clientGender.capitalized
        lblBday.text            = utilities.getCompleteDateString(stringDate: clientBday)
        lblEmail.text           = clientEmail
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    @IBAction func uploadPhoto(_ sender: UIButton) {
        chooseImage()
    }
    
    func chooseImage(){
        
        let imagePickerController       = UIImagePickerController()
        imagePickerController.delegate  = self
        let photoPermission             = PHPhotoLibrary.authorizationStatus()
        let alertView                   = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
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
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        var image               = info[UIImagePickerControllerOriginalImage] as! UIImage
        imgAttachmentString     = utilities.convertImageviewToBase64String(imgView:image)
        imgAttachment.image     = image
        lblAttachmentStatus.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.7529411765, blue: 0.8705882353, alpha: 1)
        lblAttachmentStatus.text            = "Image is ready!"
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        imgAttachmentString = ""
        lblAttachmentStatus.backgroundColor = UIColor.red
        lblAttachmentStatus.text            = "No image!"
        imgAttachment.image = UIImage(named: "noImage")
        picker.dismiss(animated: true, completion: nil)
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
        else if (action == "exit"){
            let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
                 self.dismiss(animated: true, completion: nil)
            }
            alertView.addAction(confirm)
           
        }
        else{
            let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
                
            }
            alertView.addAction(confirm)
        }
        present(alertView,animated: true,completion: nil)
    }
    
    @IBAction func submitRequest(_ sender: Any) {
        validateAttachment()
    }
    
    func validateAttachment(){
        let msg = txtMessage.text
        if imgAttachmentString == ""{
            self.showDialog(title: "No attachment found!", message: "Please provide your attachment (valid ID) to verify your identity. ", action: "")
        }
        else if (msg?.isEmpty == true || msg == ""){
            self.showDialog(title: "No message!", message: "Please complete ALL the missing information to proceed", action: "")
        }
        else{
            self.dialogUtil.showActivityIndicator(self.view)
            let token   = utilities.getUserToken()
            let url     = SERVER_URL+"/api/premier/sendReviewRequest?token="+token
            let requestParams:Parameters   = [
                "message":msg!,
                "valid_id_url":self.imgAttachmentString
            ]
            let myURL = URL(string: url)
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
                                self.showDialog(title: "Success!", message: "You have successfully requested for a transaction review. Please wait for the further message.", action: "exit")
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
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
