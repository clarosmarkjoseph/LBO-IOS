//
//  BranchInfoController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/11/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import SocketIO
import Alamofire

class BranchInfoController: UITableViewController {
    
    @IBOutlet var tblBranchInfo: UITableView!
    var objectBranch:ArrayBranch? = nil
    var arrayInfoDetails    = [String]()
    var arrayInfoImage      = [String]()
    let utilities           = Utilities()
    var webSocket:SocketIOClient!
    let dbclass             = DatabaseHelper()
    let dialogUtil          = DialogUtility()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDetails()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func loadDetails(){
        
        if let welcome_message = objectBranch?.welcome_message{
            arrayInfoImage.append("app_logo")
            arrayInfoDetails.append(welcome_message.capitalized)
        }
        
        arrayInfoImage.append("a_message")
        arrayInfoDetails.append("Message Branch now!")
        
        if let branch_address = objectBranch?.branch_address{
            arrayInfoImage.append("a_location")
            arrayInfoDetails.append(branch_address.capitalized)
        }
        if let branch_email = objectBranch?.branch_email{
            arrayInfoImage.append("a_email")
            arrayInfoDetails.append(branch_email)
        }
        if let branch_contact = objectBranch?.branch_contact{
            arrayInfoImage.append("a_contact")
            arrayInfoDetails.append(branch_contact)
        }
       
        if let branch_contact_person = objectBranch?.branch_contact_person{
            arrayInfoImage.append("a_tech")
            arrayInfoDetails.append(branch_contact_person.capitalized)
        }

        if let branch_payment_methods = objectBranch?.payment_methods{
            arrayInfoImage.append("a_payment")
            arrayInfoDetails.append(branch_payment_methods.capitalized)
        }
        
        arrayInfoImage.append("a_testimonials")
        arrayInfoDetails.append("Like us on our official Facebook page")
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func checkContactNo(){
        
        let contact         = objectBranch?.branch_contact ?? ""
        var arrayContact    = [String]()
        if (contact.contains(" or ")){
            arrayContact            =  contact.components(separatedBy: " or ")
        }
        else if (contact.contains(" / ")){
            arrayContact            =  contact.components(separatedBy: " / ")
        }
        else if (contact.contains("; ")){
            arrayContact            =  contact.components(separatedBy: "; ")
        }
        else if (contact.contains(" and ")){
            arrayContact            =  contact.components(separatedBy: " and ")
        }
        else if (contact.contains(" / Land-line - ")){
            arrayContact            =  contact.components(separatedBy: " / Land-line - ")
        }
        else if (contact.contains("/")){
            arrayContact            =  contact.components(separatedBy: "/")
        }
        else{
            arrayContact.append(contact)
        }
        
        let alertView = UIAlertController(title: "Branch Contact No.", message: "Please select which contact number would you like to dial", preferredStyle: .actionSheet)
        
        for rows in arrayContact{
            let btnContactNo = UIAlertAction(title: "Contact: \(rows)", style: .default) { (action) in
                self.openDialer(branchContact: rows)
            }
            alertView.addAction(btnContactNo)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        alertView.addAction(cancel)
        present(alertView,animated: true,completion: nil)
       
    }
    
    func openDialer(branchContact:String){
        if let url = URL(string: "tel://\(branchContact)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrayInfoDetails.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell        = tableView.dequeueReusableCell(withIdentifier: "cellBranchInfo", for: indexPath) as! BranchInfoViewCell
        let position    = indexPath.row
        cell.lblCaption.text = arrayInfoDetails[position]
        cell.imgDetail.image = UIImage(named: arrayInfoImage[position])
        
        cell.lblCaption.backgroundColor = UIColor.white
        cell.lblCaption.textAlignment   = .center
        cell.lblCaption.textColor       = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
        
        if(position == 0){
            cell.imgDetail.isHidden         = true
            cell.lblCaption.textAlignment   = .center
            cell.lblCaption.font            = UIFont.italicSystemFont(ofSize: 15)
            cell.accessoryType             = UITableViewCellAccessoryType.none
        }
        else{
            cell.imgDetail.isHidden         = false
            cell.lblCaption.textAlignment = .left
            
            if position == 1{
                cell.imgDetail.isHidden         = false
                cell.accessoryType              = UITableViewCellAccessoryType.disclosureIndicator
                cell.lblCaption.backgroundColor = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
                cell.lblCaption.textAlignment   = .center
                cell.lblCaption.textColor       = UIColor.white
            }
            else if(position == 4){
                cell.accessoryType            = UITableViewCellAccessoryType.detailDisclosureButton
            }
            else if(position >= arrayInfoDetails.count - 1){
                cell.accessoryType            = UITableViewCellAccessoryType.disclosureIndicator
                cell.lblCaption.font          = UIFont.italicSystemFont(ofSize: 15)
            }
            else{
                 cell.accessoryType            = UITableViewCellAccessoryType.none
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = self.tblBranchInfo.indexPathForSelectedRow{
            self.tblBranchInfo.deselectRow(at: index, animated: true)
        }
        if indexPath.row == 1{
            getChatDetails()
        }
        if indexPath.row == 4{
            checkContactNo()
        }
        
        if indexPath.row == arrayInfoDetails.count - 1{
            utilities.openFacebookPage()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.rowHeight < 70{
            return 70
        }
        return UITableViewAutomaticDimension
    }
    
    func getChatDetails(){
        let clientID = utilities.getUserID()
        if(clientID <= 0){
            
            //alert box
            let alertView = UIAlertController(title: "Chat not available", message: "Chat messaging is not available when not yet login", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "Login", style: .default) { (action) in
                if let viewController = UIStoryboard(name: "LoginStoryboard", bundle: nil).instantiateViewController(withIdentifier: "LoginController") as? LoginController {
                    if let navigator = self.navigationController {
                        viewController.sessionExpired = false
                        navigator.present(viewController, animated: true)
                    }
                }
            }
            let cancel = UIAlertAction(title: "Cancel", style: .default) { (action) in
                
            }
            alertView.addAction(confirm)
            alertView.addAction(cancel)
            present(alertView,animated: true,completion: nil)
            
            return
        }
        else{
            self.dialogUtil.showActivityIndicator(self.view)
            let SERVER_URL      = dbclass.returnIp()
            let token           = utilities.getUserToken()
            var branch_email    = objectBranch!.branch_email!
            let branch_id       = objectBranch!.id!
            branch_email        = branch_email.replacingOccurrences(of: " ", with: "%20")
            let url     = "\(SERVER_URL)/api/mobile/contactBranchSupervisor/\(branch_id)/\(branch_email)?token=\(token)"
            print(url)
            Alamofire.request(url, method: .get)
                .responseJSON { response in
                    do{
                        guard let statusCode   = try response.response?.statusCode else {
                            self.dialogUtil.hideActivityIndicator(self.view)
                            self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                            return
                        }
                        if response.data != nil{
                            if(statusCode == 200 || statusCode == 201){
                                let decodedResult = try JSONDecoder().decode(RequestChatThread.self, from: response.data!)
                                self.navigateChatRoom(requestResult: decodedResult)
                            }
                            else if (statusCode == 401){
                                self.dialogUtil.hideActivityIndicator(self.view)
                                self.utilities.deleteAllData()
                                let mainStoryboard: UIStoryboard = UIStoryboard(name: "LoginStoryboard", bundle: nil)
                                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
                                viewController.isLoggedOut      = true
                                viewController.sessionExpired   = true
                                UIApplication.shared.keyWindow?.rootViewController = viewController
                            }
                            else{
                                self.dialogUtil.hideActivityIndicator(self.view)
                                let responseValue = response.result.value
                                if responseValue != nil{
                                    let arrayError = self.utilities.handleHttpResponseError(objectResponseError: responseValue as! Dictionary<String, Any> ,statusCode:statusCode)
                                    self.showDialog(title:arrayError[0], message: arrayError[1])
                                }
                                else{
                                    self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                                }
                            }
                        }
                        else{
                            self.dialogUtil.hideActivityIndicator(self.view)
                            self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                        }
                    }
                    catch{
                        print("ERROR schedule: \(error)")
                        self.dialogUtil.hideActivityIndicator(self.view)
                        self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                    }
            }
        }
        
    }
    
    func navigateChatRoom(requestResult:RequestChatThread){
        let storyBoard          = UIStoryboard(name:"ChatStoryboard",bundle:nil)
        let chatVC              = storyBoard.instantiateViewController(withIdentifier: "ChatMessageController") as! ChatMessageController
        chatVC.thread_id        = requestResult.thread_id!
        chatVC.thread_name      = self.objectBranch?.branch_name ?? "No specific name"
        chatVC.recipient_id     = requestResult.recipient_id!
        chatVC.isCameFromInbox  = false
        self.navigationController?.pushViewController(chatVC, animated: true)
        self.dialogUtil.hideActivityIndicator(self.view)
    }
    
    func showDialog(title:String,message:String){
        //alert box
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            
        }
        alertView.addAction(confirm)
        present(alertView,animated: true,completion: nil)
    }

}
