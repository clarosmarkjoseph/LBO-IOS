//
//  ChatMessageController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/20/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import Alamofire
import SocketIO
import Kingfisher

protocol RefreshChat {
    func refreshChatMessage(msgArray:[ArrayChatMessage],tblChatMessage:UITableView)
}

let refreshNotificationKey = "com.oa.Laybare.refreshChatContent"
let getChatNotificationKey = "com.oa.Laybare.getChatFromServer"

class ChatMessageController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {

    @IBOutlet var tblChatMessage: UITableView!
    @IBOutlet var txtMessage: UITextField!
    @IBOutlet var btnSend: UIButton!
    @IBOutlet var uiview: UIView!
    @IBOutlet var uiviewContainerChat: UIView!
    var webSocket:SocketIOClient!
    var socketConnection = SocketConnection()
    
    let dbclass     = DatabaseHelper()
    let utilities   = Utilities()
    let notifName   = Notification.Name(rawValue: refreshNotificationKey)
    var SERVER_URL  = ""
    var clientID    = 0
    var bottomConstraints:NSLayoutConstraint?
    var ifSendingMessage = false
    var lastChatID       = 0
    var arrayMessages    = [ArrayChatMessage]()
    
    //attributes when accessing chat Inbox
    var messageThread:ArrayChatThread!
    
    //attributes when accessing branch locator
    var recipient_id    = 0
    var thread_id       = 0
    var thread_name     = ""
    var isCameFromInbox = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SERVER_URL                          = dbclass.returnIp()
        clientID                            = utilities.getUserID()
        txtMessage.delegate                 = self
        tblChatMessage.delegate             = self
        tblChatMessage.dataSource           = self
        tblChatMessage.estimatedRowHeight   = 60
        tblChatMessage.rowHeight            = UITableViewAutomaticDimension
        bottomConstraints = NSLayoutConstraint(item: uiviewContainerChat, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraints!)
        createObservers()
        
        if(isCameFromInbox == true){
            thread_name = messageThread.thread_name!.capitalized
            NotificationCenter.default.addObserver(self,selector: #selector(refreshMessage(notification:)), name: notifName, object: nil)
            loadChatMessage()
        }
        else{
            webSocket  = socketConnection.getWebSocket()
            webSocket.connect()
            loadChatFromServer()
        }
        
        self.navigationItem.title           = thread_name
        loadWebsocketEvents()
        
    }
    
    func loadWebsocketEvents(){
        
        webSocket.on("notifyTyping") {data, ack in
            guard let objectSocket      = data[0] as? Dictionary<String,Any> else { return }
            let params_recipient_id     = objectSocket["recipient_id"] as! Int
            if let checkSender     = objectSocket["sender_id"]{
                let params_sender_id = checkSender as! Int
                if (self.clientID == params_recipient_id && params_sender_id != self.clientID){
                    print("sender typing")
                    //                   arrayMessages.append(<#T##newElement: ArrayChatMessage##ArrayChatMessage#>)
                    //                      💬
                }
            }
        }
        
        if(isCameFromInbox == false){
            webSocket.on("newMessage") {data, ack in
                print("check socket: \(data)")
                guard let objectSocket      = data[0] as? Dictionary<String,Any> else { return }
                let params_recipient_id     = objectSocket["recipient_id"] as! Int
                if let checkSender     = objectSocket["sender_id"]{
                    let params_sender_id = checkSender as! Int
                    if (self.clientID == params_recipient_id && params_sender_id != self.clientID){
                        self.loadChatFromServer()
                    }
                }
            }
        }
    }
    
    func loadChatFromServer(){
        
        ChatDatasource.sharedChatInstance.loadAllChatMessages { (arrayThread,statusCode) in
            if statusCode == 200 || statusCode == 201{
                let array = arrayThread
                for rows in array{
                    self.saveMessages(jsonResult: rows)
                }
                self.loadChatMessage()
            }
            else if statusCode == 0{
                print("error status code")
                self.loadChatMessage()
            }
            else{
                self.loadChatMessage()
            }
        }
    }
    
    func saveMessages(jsonResult:ArrayChatThread){
        do{
            let chatMessage             = jsonResult.messages!
            let id                      = jsonResult.id!
            let name                    = jsonResult.thread_name ?? "N/A"
            let dateTime                = jsonResult.updated_at ?? "0000-00-00 00:00:00"
            let created_by_id           = jsonResult.created_by_id!
            let user_image              = jsonResult.user_image!
            let participant_ids         = jsonResult.participant_ids!
            let arrayParticipantData    = try JSONEncoder().encode(participant_ids)
            let jsonString              = utilities.convertDataToJSONString(data: arrayParticipantData)
            dbclass.insertOrUpdateThread(id: id, name: name, dateTime: dateTime, creator_id: created_by_id, chat_participants_id: jsonString,user_image: user_image)
            var indexChat = 0
            for rowChat in chatMessage{
                let chat_id         = rowChat.id!
                let sender_id       = rowChat.sender_id!
                let recipient_id    = rowChat.recipient_id!
                let thread_id       = rowChat.message_thread_id!
                let title           = rowChat.title ?? ""
                let body            = rowChat.body ?? ""
                let message_data    = rowChat.message_data ?? "{}"
                let dateTime        = rowChat.created_at!
                let read_at         = rowChat.read_at ?? ""
                var isRead          = 0
                
                dbclass.insertOrUpdateChat(chatID: chat_id, chatSenderID: sender_id, chatReceiverID: recipient_id, chatThreadID: thread_id, chatTitle: title, chatBody:body, chatMessageData: message_data, dateTime: dateTime, chatIsRead: read_at, chatStatus: "sent")
                if((read_at == "0000-00-00" || read_at == "null" || read_at == "") && recipient_id == clientID){
                    isRead = 0
                }
                else{
                    isRead = 1
                }
                dbclass.updateThreadTime(threadID: thread_id,datetime: dateTime,isRead:isRead)
                indexChat += 1
            }
        }
        catch{
            print("ERROR parsing chat: \(error)")
        }
    }
    
    
    func markMessageAsSeen(){
        let token   = utilities.getUserToken()
        let url     = "\(SERVER_URL)/api/message/seenMessages?token=\(token)"
        let myUrl   = URL(string: url)
        let parameters:Parameters = [
            "sender_id":recipient_id,
            "thread_id":thread_id
        ]
        
        Alamofire.request(myUrl!, method: .post, parameters: parameters)
            .responseJSON { response in
                do{
                    guard let statusCode = response.response?.statusCode else {
                        return
                    }
                    if(statusCode == 200 || statusCode == 201){
                        print("Success")
                        self.dbclass.markMessageAsSeen(threadID:self.thread_id,message_id:self.clientID)
                    }
                    else if(statusCode == 401){
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
                    }
                }
                catch{
                    print("ERROR :\(error)")
                }
        }
    }
    
    func loadChatMessage(){
        
        if(isCameFromInbox == true){
            thread_id     = messageThread.id!
            arrayMessages = messageThread.messages!
            let arrayParticipants = messageThread.participant_ids!;
            for rows in arrayParticipants {
                if rows == clientID{
                    continue
                }
                else{
                    recipient_id = rows
                }
            }
        }
        else{
            let msgArray = dbclass.returnChatThread(threadID: thread_id)
            if(msgArray.count > 0){
                for rows in msgArray{
                    messageThread           = rows
                    arrayMessages           = messageThread.messages!
                    break
                }
            }
            else{
                self.navigationController?.popViewController(animated: true)
            }
        }
        DispatchQueue.main.async {
            self.tblChatMessage.reloadData()
        }
        
        if(arrayMessages.count > 0){
            arrayMessages = arrayMessages.sorted(by: {
                let dateArray1 = utilities.convertStringToDateTime(stringDate: $0.created_at!)
                let dateArray2 = utilities.convertStringToDateTime(stringDate: $1.created_at!)
                return dateArray1.compare(dateArray2) == .orderedAscending
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() ) {
                let lastRow = IndexPath(row: self.arrayMessages.count - 1, section: 0)
                self.tblChatMessage.scrollToRow(at: lastRow, at: .top , animated: false)
            }
        }
        markMessageAsSeen()
    }

    func loadPreviousChatFromServer(){
//        lastChatID
    }
    
    

    @objc func handleKeyboardNotification(notification:Notification){
        let info:NSDictionary   = notification.userInfo! as NSDictionary
        let keyboardSize        = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
        
        let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
        bottomConstraints?.constant = isKeyboardShowing ? -keyboardSize.height : 0
        
        if arrayMessages.count > 0{
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                let lastRow = IndexPath(row: self.arrayMessages.count - 1, section: 0)
                self.tblChatMessage.scrollToRow(at: lastRow, at: .top , animated: false)
            })
        }
        
    }
   
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        txtMessage  = textField
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let msg = txtMessage.text!
        if msg.isEmpty{
            btnSend.alpha       = 0.5
            btnSend.isEnabled   = false
        }
        else{
            btnSend.alpha       = 1.0
            btnSend.isEnabled   = true
        }
    }
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func createObservers(){
        let center:NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(handleKeyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(handleKeyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        txtMessage.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
       
    }
    
    @objc func refreshMessage(notification: NSNotification){
        if let arrayChat = notification.userInfo?["arrayMessages"] as? [ArrayChatMessage]{
            arrayMessages = arrayChat
            self.tblChatMessage.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() ) {
                let lastRow = IndexPath(row: self.arrayMessages.count - 1, section: 0)
                self.tblChatMessage.scrollToRow(at: lastRow, at: .top , animated: false)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self,name:NSNotification.Name.UIKeyboardWillShow,object:nil)
        NotificationCenter.default.removeObserver(self,name:NSNotification.Name.UIKeyboardWillHide,object:nil)
        if isCameFromInbox == false{
            webSocket.disconnect()
        }
    }
    
    
    @objc func keyboardDidShow(notification:Notification){
        let info:NSDictionary   = notification.userInfo! as NSDictionary
        let keyboardSize        = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
        let keyboardY           = self.tblChatMessage.frame.size.height - keyboardSize.height
        let editingTextFieldY:CGFloat! = self.txtMessage?.frame.origin.y
        
        if self.tblChatMessage.frame.origin.y >= 0{
            //check if textfield is really hidden behind the keyboard
            if editingTextFieldY > keyboardY - 60{
                UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations:{
                    self.tblChatMessage.frame = CGRect(x: 0, y: self.tblChatMessage.frame.origin.y - (editingTextFieldY! - (keyboardY - 60)), width: self.tblChatMessage.bounds.width, height: self.tblChatMessage.bounds.height)
                } , completion: nil)
            }
        }
    }
    
    @objc func keyboardWillHide(notification:Notification){
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.tblChatMessage.frame = CGRect(x: 0, y: 0, width: self.tblChatMessage.bounds.width, height: self.tblChatMessage.bounds.width)
        }, completion: nil)
    }
    
   
    
    
    @IBAction func btnSendClicked(_ sender: Any) {
        
        let msgData                         = txtMessage.text!
        let last_chat_id                    = lastChatID + 1
        let currentDateTime                 = utilities.getCurrentDateTime(ifDateOrTime: "datetimeseconds")
        var countMessage                    = arrayMessages.count
        var objectParse                     = Dictionary<String,Any>()
        objectParse["id"]                   = last_chat_id
        objectParse["created_at"]           = currentDateTime
        objectParse["sender_id"]            = clientID
        objectParse["recipient_id"]         = recipient_id
        objectParse["message_thread_id"]    = thread_id
        objectParse["is_closed"]            = 0
        objectParse["message_data"]         = "{}"
        objectParse["deleted_to_id"]        = nil
        objectParse["read_at"]              = ""
        objectParse["updated_at"]           = currentDateTime
        objectParse["title"]                = ""
        objectParse["body"]                 = msgData
        objectParse["status"]               = "sending"
        let objectParseString               = utilities.convertDictionaryToJSONString(dictionaryVal: objectParse)
        let objectParseData                 = objectParseString.data(using: .utf8)
        
        ifSendingMessage = true
        do{
            let encodedParse    = try JSONDecoder().decode(ArrayChatMessage.self, from: objectParseData!)
            arrayMessages.append(encodedParse)
            saveToLocalDatabase(encodedParse:encodedParse)
            countMessage        = arrayMessages.count - 1
            DispatchQueue.main.async {
                self.tblChatMessage.reloadData()
            }
            btnSend.isEnabled   = false
            btnSend.alpha       = 0.5
            txtMessage.text     = ""
            txtMessage.resignFirstResponder()
            self.sendMessage(msg:msgData,objectChat: encodedParse,countMessageAsPosition:countMessage, chatID: last_chat_id)
        }
        catch{
            print("ERROR :\(error)")
            arrayMessages[countMessage].status = "failed"
            let indexPath = IndexPath(item: countMessage, section: 0)
            self.tblChatMessage.reloadRows(at: [indexPath], with: .top)
        }
    }
    
    
    
    func sendMessage(msg:String,objectChat:ArrayChatMessage,countMessageAsPosition:Int,chatID:Int){
        
        let last_chat_id    = chatID
        var encodedParse    = objectChat
        let token           = utilities.getUserToken()
        let stringURL       = SERVER_URL+"/api/mobile/sendChatMessage?token="+token
        let myUrl           = URL(string: stringURL)
        let parameters:Parameters = [
            "body":msg,
            "recipient_id":recipient_id
        ]
        Alamofire.request(myUrl!, method: .post, parameters: parameters)
            .responseJSON { response in
                
                do{
                    guard let statusCode = response.response?.statusCode else {
                        print("COunt all msg with failed: \(countMessageAsPosition)")
                        encodedParse.status                = "failed"
                        self.arrayMessages[countMessageAsPosition]   = encodedParse
                        self.saveToLocalDatabase(encodedParse:encodedParse)
                        self.tblChatMessage.beginUpdates()
                        let indexPath                      = IndexPath(item: countMessageAsPosition, section: 0)
                        self.tblChatMessage.reloadRows(at: [indexPath], with: .top)
                        self.tblChatMessage.endUpdates()
                        return
                    }
                    if response.data != nil{
                        if(statusCode == 200 || statusCode == 201){
                            let jsonDecoded         = try JSONDecoder().decode(ChatMessageSent.self, from: response.data!)
                            encodedParse            = jsonDecoded.object_sent!
                            encodedParse.status     = ""
                            print("STATUS: \(encodedParse.status!)")
                            self.lastChatID         = jsonDecoded.latestChatID!
                            self.dbclass.deleteSpecificChatMessage(chatID:last_chat_id)
                            self.arrayMessages[countMessageAsPosition] = encodedParse
                            self.saveToLocalDatabase(encodedParse:encodedParse)
                            let socketStatus = self.webSocket.status
                            print("Status socket \(socketStatus)")
                            print("socket if active: \(socketStatus.active)")
                            self.webSocket.emitWithAck("newMessage", self.recipient_id).timingOut(after: 5) {data in
                                if self.isCameFromInbox == true{
                                    DispatchQueue.main.asyncAfter(deadline: .now() ) {
                                        let notifName = Notification.Name(rawValue: getChatNotificationKey)
                                        NotificationCenter.default.post(name: notifName, object: nil, userInfo: nil)
                                    }
                                }
                                else{
                                    self.loadChatFromServer()
                                }
                            }
                        }
                        else if(statusCode == 401){
                            self.utilities.deleteAllData()
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "LoginStoryboard", bundle: nil)
                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
                            viewController.isLoggedOut      = true
                            viewController.sessionExpired   = true
                            UIApplication.shared.keyWindow?.rootViewController = viewController
                        }
                        else{
                            encodedParse.status                = "failed"
                            self.arrayMessages[countMessageAsPosition]   = encodedParse
                            self.saveToLocalDatabase(encodedParse:encodedParse)
                        }
                    }
                    else{
                        encodedParse.status                = "failed"
                        self.arrayMessages[countMessageAsPosition]   = encodedParse
                        self.saveToLocalDatabase(encodedParse:encodedParse)
                    }
                    
                    self.tblChatMessage.beginUpdates()
                    let indexPath                      = IndexPath(item: countMessageAsPosition, section: 0)
                    self.tblChatMessage.reloadRows(at: [indexPath], with: .fade)
                    self.tblChatMessage.endUpdates()
                    
                }
                catch{
                    print("ERROR :\(error)")
                    encodedParse.status                = "failed"
                    self.arrayMessages[countMessageAsPosition]   = encodedParse
                    self.saveToLocalDatabase(encodedParse:encodedParse)
                }
        }
    }
    
    
    func saveToLocalDatabase(encodedParse:ArrayChatMessage){
        
        let chat_id             = encodedParse.id!
        let chat_sender_id      = encodedParse.sender_id!
        let chat_recipient_id   = encodedParse.recipient_id!
        let chat_thread_id      = encodedParse.message_thread_id!
        let chat_title          = encodedParse.title ?? ""
        let chat_body           = encodedParse.body!
        let chat_message_data   = encodedParse.message_data ?? "{}"
        let chat_updated_at     = encodedParse.updated_at!
        let chat_read_at        = encodedParse.read_at ?? ""
        let chat_status         = encodedParse.status ?? ""
        
        dbclass.insertOrUpdateChat(chatID: chat_id, chatSenderID: chat_sender_id, chatReceiverID: chat_recipient_id, chatThreadID: chat_thread_id, chatTitle: chat_title, chatBody: chat_body, chatMessageData: chat_message_data, dateTime: chat_updated_at, chatIsRead: chat_read_at, chatStatus: chat_status)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if(arrayMessages.count <= 0){
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            emptyLabel.text             = "Start chatting with \(thread_name)"
            emptyLabel.textColor        = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
            emptyLabel.numberOfLines    = 0
            emptyLabel.textAlignment    = NSTextAlignment.center
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            return 0
        }
        return arrayMessages.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let position    = indexPath.row
        let cell        = tblChatMessage.dequeueReusableCell(withIdentifier: "cellChatMessage", for: indexPath) as! ChatMessageViewCell
        let sender_id        = arrayMessages[position].sender_id!
        let chat_id          = arrayMessages[position].id!
        let message          = arrayMessages[position].body!
        let date_chat        = arrayMessages[position].updated_at!
        let dateTime         = utilities.convertStringToDateTime(stringDate: date_chat)
        let minuteAgo        = utilities.getTimeAgo(dateSet: dateTime,ifSpecific: true)
        var profileString    = ""
        var url:URL!
        
        cell.lblCaption.textColor       = UIColor.darkGray
        cell.lblMessage.text            = message
        cell.lblCaption.isHidden        = false
        cell.lblCaption.text            = minuteAgo
        
        if(clientID == sender_id){
            
            let profile         = utilities.getUserImage()
            profileString       = SERVER_URL+"/images/users/\(profile)"
            profileString       = profileString.replacingOccurrences(of: " ", with: "%20")
            url                 = URL(string: profileString)
            cell.imgUser.kf.setImage(with: url)
            
            cell.constraintTrailing.isActive        = true
            cell.constraintLeading.isActive         = false
            
            cell.stackviewParent.addArrangedSubview(cell.stackviewParent.subviews[1])
            cell.uiviewBackground.backgroundColor   = #colorLiteral(red: 0.3568627451, green: 0.7529411765, blue: 0.8705882353, alpha: 1)
            cell.lblMessage.textColor               = UIColor.white
            cell.lblCaption.textAlignment           = .right
            if let chatStatus = arrayMessages[position].status {
                if chatStatus == "sending"{
                    cell.selectionStyle = .gray
                    cell.uiviewBackground.alpha = 0.5
                    cell.lblCaption.isHidden = false
                    cell.lblCaption.text = "Sending...."
                }
                else if chatStatus == "failed"{
                     cell.selectionStyle = .gray
                     cell.uiviewBackground.alpha = 0.5
                     cell.lblCaption.text = "Message failed to send!"
                     cell.lblCaption.isHidden = false
                     cell.lblCaption.textColor = UIColor.red
                }
                else{
                    cell.selectionStyle         = .none
                    cell.uiviewBackground.alpha = 1.0
                    cell.lblCaption.isHidden    = false
                    cell.lblCaption.text        = minuteAgo
                }
            }
        }
        else{
            
            let profile         = messageThread.user_image!
            profileString       = SERVER_URL+"/images/users/\(profile)"
            profileString       = profileString.replacingOccurrences(of: " ", with: "%20")
            url                 = URL(string: profileString)
            cell.imgUser.kf.setImage(with: url)
            
            cell.constraintLeading.isActive             = true
            cell.constraintTrailing.isActive            = false
            
            cell.stackviewParent.addArrangedSubview(cell.stackviewParent.subviews[0])
            cell.uiviewBackground.backgroundColor       = UIColor.white
            cell.lblMessage.textColor                   = UIColor.black
            cell.lblCaption.textAlignment               = .left
            cell.uiviewBackground.alpha                 = 1.0
        }
        
        if position == arrayMessages.count - 1 {
            lastChatID = chat_id
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        txtMessage.endEditing(true)
        if let index = self.tblChatMessage.indexPathForSelectedRow{
            self.tblChatMessage.deselectRow(at: index, animated: true)
        }
        
        let position  = indexPath.row
        let objectRow = arrayMessages[position]
        let status    = objectRow.status!
        
        if status == "sending"{
            showDialogOptions(title: "Message is on-progress.", message: "Your message is still sending. Do you want to cancel your message?", isResend: false, itemRowPosition: position)
        }
        else if status == "failed" {
            showDialogOptions(title: "Message failed to send!", message: "Your message is failed to send. Would you try to resend your message?", isResend: true, itemRowPosition: position)
        }
    }
    
    func showDialogOptions(title:String,message:String,isResend:Bool,itemRowPosition:Int){
        //alert box
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        if(isResend == true){
            let confirm = UIAlertAction(title: "Resend Chat", style: .default) { (action) in
                let objectChat  = self.arrayMessages[itemRowPosition]
                let chatID      = objectChat.id!
                let msgData     = objectChat.body!
                self.sendMessage(msg:msgData,objectChat: objectChat, countMessageAsPosition: itemRowPosition, chatID: chatID)
            }
            let cancel = UIAlertAction(title: "Back", style: .cancel) { (action) in
                
            }
            alertView.addAction(confirm)
            alertView.addAction(cancel)
        }
//        else{
//            let confirm = UIAlertAction(title: "Cancel Sending", style: .default) { (action) in
////                let sessionManager = Alamofire.SessionManager.default
////                sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in dataTasks.forEach { $0.cancel() }
////                    uploadTasks.forEach { $0.cancel() }
////                    downloadTasks.forEach { $0.cancel() }
////                }
//                //Cancel all requests
////                Alamofire.SessionManager.default.session.getAllTasks { (tasks) in
////                    tasks.forEach({$0.cancel()})
////                }
//            }
//            let cancel = UIAlertAction(title: "Back", style: .cancel) { (action) in
//
//            }
//            alertView.addAction(confirm)
//            alertView.addAction(cancel)
//        }
        
        present(alertView,animated: true,completion: nil)
    }
    

}
