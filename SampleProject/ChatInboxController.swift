//
//  ChatInboxController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/19/18.
//  Copyright © 2018 itadmin. All rights reserved.
//
import UIKit
import Alamofire
import Kingfisher
import SocketIO

class ChatInboxController: UITableViewController {
   
    @IBOutlet var tblChatInbox: UITableView!
    let dbclass         = DatabaseHelper()
    let utilities       = Utilities()
    var SERVER_URL      = ""
    var arrayChatThread = [ArrayChatThread]()
    var clientID        = 0
    var socketConnection        = SocketConnection()
    var webSocket:SocketIOClient!
    var ifChatMessageShown = false
    var selectedInboxIndex:Int = 0
    var lastChatID          = 0
    let refreshNotifName    = Notification.Name(rawValue: getChatNotificationKey)
    
    
    lazy var refreshTable: UIRefreshControl = {
        let refreshControls = UIRefreshControl()
        refreshControls.tintColor        = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
        refreshControls.attributedTitle  = NSAttributedString(string: "Swipe to refresh")
        refreshControls.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refreshControls
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SERVER_URL  = dbclass.returnIp()
        clientID    = utilities.getUserID()
        webSocket   = socketConnection.getWebSocket()
        webSocket.connect()
        
        // Disable the swipe to make sure you get your chance to save
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(userBackPressed(sender:)))
        newBackButton.tintColor                             = UIColor.white
        self.navigationItem.leftBarButtonItem               = newBackButton
        self.navigationItem.rightBarButtonItem?.tintColor   = UIColor.white
       
        self.tblChatInbox.isScrollEnabled         = true
        self.tblChatInbox.alwaysBounceVertical    = true
        self.tblChatInbox.addSubview(refreshTable)
        self.tabBarController?.tabBar.isHidden = true
        
        loadWebsocketEvents()
        handleRefresh()
        createObserver()
        
    }
    
    func createObserver(){
        NotificationCenter.default.addObserver(self,selector: #selector(getNewMessage(notification:)), name: refreshNotifName, object: nil)
    }
    
    @objc func getNewMessage(notification: NSNotification){
        self.loadChatDetails()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ifChatMessageShown      = false
        selectedInboxIndex      = 0
        iterateOfflineMessage()
    }

    //pull to refresh
    @objc func handleRefresh() {
        refreshTable.beginRefreshing()
        loadChatDetails()
    }
    
    @objc func userBackPressed(sender: UIBarButtonItem){
        webSocket.disconnect()
        navigationController?.popViewController(animated: true)
    }
    
    func loadWebsocketEvents(){
        
        webSocket.on("newMessage") {data, ack in
            print("check socket: \(data)")
            guard let objectSocket      = data[0] as? Dictionary<String,Any> else { return }
            let params_recipient_id     = objectSocket["recipient_id"] as! Int
            if let checkSender     = objectSocket["sender_id"]{
                let params_sender_id = checkSender as! Int
                if (self.clientID == params_recipient_id && params_sender_id != self.clientID){
                    print("I just Called you")
                    self.loadChatDetails()
                }
            }
        }
    }
    
    func loadChatDetails(){
        ChatDatasource.sharedChatInstance.loadAllChatMessages { (arrayThread,statusCode) in
            print("Array thread: \(arrayThread)")
            if statusCode == 200 || statusCode == 201{
                let array = arrayThread
                for rows in array{
                    self.saveMessages(jsonResult: rows)
                }
                self.iterateOfflineMessage()
            }
            else if statusCode == 0 {
                self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                self.iterateOfflineMessage()
            }
            else{
                self.showDialog(title: "Error!", message: "There was a problem connecting to Lay Bare App. Please check your connection and try again")
                self.iterateOfflineMessage()
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
    
    
    func iterateOfflineMessage(){

        arrayChatThread = dbclass.returnArrayChatThread()
        arrayChatThread =  arrayChatThread.sorted(by: {
            let dateArray1 = utilities.convertStringToDateTime(stringDate: $0.updated_at!)
            let dateArray2 = utilities.convertStringToDateTime(stringDate: $1.updated_at!)
            return dateArray1.compare(dateArray2) == .orderedDescending
        })
        self.tblChatInbox.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
            if(self.refreshTable.isRefreshing == true){
                self.refreshTable.endRefreshing()
            }
        }
        refreshChatMessage()
    }

    func refreshChatMessage() {
        if ifChatMessageShown == true{
            let getArrayMessage                   = sortArrayToDateTime(array: arrayChatThread[selectedInboxIndex].messages!)
            var dictionaryThreadInfo              = Dictionary<String,Any>()
            dictionaryThreadInfo["arrayMessages"] = getArrayMessage
            let notifName = Notification.Name(rawValue: refreshNotificationKey)
            NotificationCenter.default.post(name: notifName, object: nil, userInfo: dictionaryThreadInfo)
        }
    }
    
    func sortArrayToDateTime(array:[ArrayChatMessage]) -> [ArrayChatMessage]{
        var arrayChat = array
        arrayChat =  arrayChat.sorted(by: {
            let dateArray1 = utilities.convertStringToDateTime(stringDate: $0.created_at!)
            let dateArray2 = utilities.convertStringToDateTime(stringDate: $1.created_at!)
            return dateArray1.compare(dateArray2) == .orderedAscending
        })
        return arrayChat
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayChatThread.count <= 0{
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            emptyLabel.text             = "No message(s) to display"
            emptyLabel.textColor        = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
            emptyLabel.numberOfLines    = 0
            emptyLabel.textAlignment    = NSTextAlignment.center
            self.tblChatInbox.backgroundView = emptyLabel
            self.tblChatInbox.separatorStyle = UITableViewCellSeparatorStyle.none
            return 0
        }
        self.tblChatInbox.backgroundView = nil
        return arrayChatThread.count
        
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let position            = indexPath.row
        let cell                = tableView.dequeueReusableCell(withIdentifier: "cellChatInbox", for: indexPath) as! ChatInboxViewCell
        var imgString           = arrayChatThread[position].user_image!
        let dateTime            = utilities.convertStringToDateTime(stringDate: arrayChatThread[position].updated_at!)
        imgString               = imgString.replacingOccurrences(of: " ", with: "%20")
        imgString               = "\(SERVER_URL)/images/users/\(imgString)"
        let imgURL              = URL(string: imgString)!
        var arrayMessage        = arrayChatThread[position].messages!
        arrayMessage            = sortArrayToDateTime(array: arrayMessage)
        cell.imgProfile.kf.setImage(with: imgURL)
        cell.lblUsername.text   = arrayChatThread[position].thread_name?.capitalized
        cell.lblDate.text       = utilities.getTimeAgo(dateSet: dateTime,ifSpecific: false)
        
        var countIfUnseen       = 0
        for rows in arrayMessage{
            let sender_id       = rows.sender_id
            let msg_status      = rows.status
            var txtMsg = ""
            if (clientID == sender_id){
                if(msg_status == "failed"){
                    txtMsg = "You(failed): \(rows.body!) "
                }
                else if msg_status == "sending"{
                     txtMsg = "You(sending): \(rows.body!) "
                }
                else{
                    txtMsg = "You: \(rows.body!)"
                }
                countIfUnseen = 0
            }
            else{
                if rows.read_at! == "null" || rows.read_at! == ""{
                    countIfUnseen+=1
                }
                txtMsg = rows.body!
            }
            cell.lblMessage.text = txtMsg
            continue
        }
        if(countIfUnseen > 0){
            cell.lblUsername.font   = UIFont.boldSystemFont(ofSize: 16.0)
            cell.lblCount.text      = "\(countIfUnseen)"
            cell.lblCount.isHidden  = false
        }
        else{
            cell.lblCount.isHidden  = true
        }
        return cell
    }
  
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: index, animated: true)
        }
        selectedInboxIndex      = indexPath.row
        let storyBoard          = UIStoryboard(name:"ChatStoryboard",bundle:nil)
        let chatVC              = storyBoard.instantiateViewController(withIdentifier: "ChatMessageController") as! ChatMessageController
        chatVC.messageThread    = self.arrayChatThread[indexPath.row]
        chatVC.webSocket        = webSocket
        chatVC.isCameFromInbox  = true
        self.navigationController?.pushViewController(chatVC, animated: true)
        ifChatMessageShown      = true
    }
    
    
    func showDialog(title:String,message:String){
        //alert box
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            
        }
        alertView.addAction(confirm)
        present(alertView,animated: true,completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let position = indexPath.row
        let objectThread = arrayChatThread[position]
        if((objectThread.messages?.count)! <= 0){
            return 0
        }
        return 80.0
    }
    

}
