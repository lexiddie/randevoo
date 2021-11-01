//
//  NotificationsController.swift
//  randevoo
//
//  Created by Lex on 15/8/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import ObjectMapper
import AlamofireImage

class ChatUser: Mappable, Codable {
    
    var imageUrl: String! = ""
    var id: String! = ""
    var name: String! = ""
    var lastChat: String = ""
    var createdAt = Date()
    var isRead: Bool = false
    
    init(imageUrl: String, id: String, name: String, lastChat: String, createdAt: Date, isRead: Bool) {
        self.imageUrl = imageUrl
        self.id = id
        self.name = name
        self.lastChat = lastChat
        self.createdAt = createdAt
        self.isRead = isRead
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        imageUrl <- map["imageUrl"]
        id <- map["id"]
        name <- map["name"]
        lastChat <- map["lastChat"]
        createdAt <- map["createdAt"]
        isRead <- map["isRead"]
    }
    
}

class NotificationsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    var mainTabBar: UITabBar!
    let chatCell = "ChatCell"
    var chatDemo:[Demo] = [Demo(name: "Shoe", imageView: "aj.jpg"),Demo(name: "Cloth", imageView: "pant.jpg")]
    private let defaults = UserDefaults.standard
    var chatUser: [ChatUser] = []
    var selfName = ""
    let db = Firestore.firestore()
    var emptyLabel = UILabel()
     
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        view.backgroundColor = UIColor.randevoo.mainLight
        initialView()
        setupTableView()
//        db.collection("users").getDocuments() {
//            (querySnapShot, err) in
//            if let err = err {
//                print("Error: \(err)")
//            }else{
//                for document in querySnapShot!.documents {
//                    let currentData = Mapper<TempUser>().map(JSONObject: document.data())
////                    print(UserDefaults.standard.value(forKey: "email"))
//                    if UserDefaults.standard.value(forKey: "email") as? String != currentData?.email{
//                        self.userDemo.append(currentData!)
//                    }else{
//                        self.selfName = (currentData?.name)!
//                    }
//                }
//                self.tableView.reloadData()
//            }
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let mainTabBarController = self.tabBarController as! MainTabBarController
        mainTabBar = mainTabBarController.tabBar
        mainTabBar.isHidden = false
//        personalAccount = mainTabBarController.personalAccount
//        businessAccount = mainTabBarController.businessAccount
        setupChatAsSender(id: (personalAccount?.id)!)
        setupChatAsReciever(id: (personalAccount?.id)!)
        tableView.reloadData()
    }
    
    private func initialView() {
        let view = NotificationsView(frame: self.view.frame)
        self.emptyLabel = view.emptyLabel
        self.tableView = view.tableView
        self.view = view
    }
    
    
    var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor.randevoo.mainLight
        table.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        table.allowsSelection = true
        return table
    }()
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatCell.self, forCellReuseIdentifier: chatCell)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    func setupChatAsSender(id: String) {
        db.collection("chats").whereField("senderId", isEqualTo: id).addSnapshotListener {
            (querySnapshot, err) in
            if let err = err {
                print("Error: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let currentChat = Mapper<Chat>().map(JSONObject: document.data())
                    let json = Mapper().toJSONString(currentChat!, prettyPrint: true)!
                    print("\nChat Sender: \(json)")
                    let date = (currentChat?.createdAt?.iso8601withFractionalSeconds)!
                    self.db.collection("users").whereField("id", isEqualTo: currentChat?.receiverId! as Any).getDocuments() {
                        (nextQuery, err) in
                        if let err = err {
                            print("Chat User Error: \(err)")
                        } else {
                            for document in nextQuery!.documents {
                                let destinationUser = Mapper<PersonalAccount>().map(JSONObject: document.data())
                                if self.chatUser.contains(where: { user in user.id == destinationUser?.id }) {
                                    if self.chatUser.first(where: {$0.id == destinationUser?.id})!.createdAt < date {
                                        self.chatUser.first(where: {$0.id == destinationUser?.id})!.createdAt = date
                                        if currentChat?.type == "text" {
                                            self.chatUser.removeAll(where: {$0.id == destinationUser?.id})
                                            self.chatUser.append(ChatUser(imageUrl: String((destinationUser?.profileUrl)!), id: String((destinationUser?.id)!), name: String((destinationUser?.name)!), lastChat: "You: \(currentChat?.content ?? "")", createdAt: date, isRead:true))
                                        } else {
                                            self.chatUser.removeAll(where: {$0.id == destinationUser?.id})
                                            self.chatUser.append(ChatUser(imageUrl: String((destinationUser?.profileUrl)!), id: String((destinationUser?.id)!), name: String((destinationUser?.name)!), lastChat: "You: Photo.", createdAt: date, isRead:true))
                                        }
                                    }
                                } else {
                                    if currentChat?.type == "text"{
                                        self.chatUser.append(ChatUser(imageUrl: String((destinationUser?.profileUrl)!), id: String((destinationUser?.id)!), name: String((destinationUser?.name)!), lastChat: "You: \(currentChat?.content ?? "")", createdAt: date, isRead:true))
                                    }else{
                                        self.chatUser.append(ChatUser(imageUrl: String((destinationUser?.profileUrl)!), id: String((destinationUser?.id)!), name: String((destinationUser?.name)!), lastChat: "You: Photo.", createdAt: date, isRead:true))
                                    }
                                }
                            }
                            self.chatUser = self.chatUser.sorted(by: { $0.createdAt.compare($1.createdAt) == .orderedDescending})
                            if self.chatUser.count == 0 {
                                self.emptyLabel.isHidden = false
                                self.tableView.isHidden = true
                            } else {
                                self.emptyLabel.isHidden = true
                                self.tableView.isHidden = false
                            }
                            self.tableView.reloadData()
//                            let json = Mapper().toJSONString(self.chatUser, prettyPrint: true)!
//                            print("\nChat Users: \(json)")
                        }
                    }
                }
            }
        }
    }
    
    func setupChatAsReciever(id: String) {
        db.collection("chats").whereField("receiverId", isEqualTo: id).addSnapshotListener {
            (querySnapshot, err) in
            if let err = err {
                print("Error: \(err)")
            }else{
                for document in querySnapshot!.documents {
                    let currentChat = Mapper<Chat>().map(JSONObject: document.data())
                    let date = (currentChat?.createdAt?.iso8601withFractionalSeconds)!
                    let json = Mapper().toJSONString(currentChat!, prettyPrint: true)!
                    print("\nChat Receiver: \(json)")
                    self.db.collection("users").whereField("id", isEqualTo: currentChat?.senderId! as Any).getDocuments() {
                        (nextQuery, err) in
                        if let err = err {
                            print("Chat User Error: \(err)")
                        } else {
    
                            for document in nextQuery!.documents {
                                let destinationUser = Mapper<PersonalAccount>().map(JSONObject: document.data())
                                if self.chatUser.contains(where: { user in user.id == destinationUser?.id }) {
                                    if self.chatUser.first(where: {$0.id == destinationUser?.id})!.createdAt < date || self.chatUser.first(where: {$0.id == destinationUser?.id})!.createdAt == currentChat?.createdAt?.iso8601withFractionalSeconds {
                                        self.chatUser.first(where: {$0.id == destinationUser?.id})!.createdAt = date
                                        if currentChat?.type == "text" {
                                            self.chatUser.removeAll(where: {$0.id == destinationUser?.id})
                                            self.chatUser.append(ChatUser(imageUrl: String((destinationUser?.profileUrl)!), id: String((destinationUser?.id)!), name: String((destinationUser?.name)!), lastChat: "\(destinationUser!.name ?? ""): \(currentChat!.content ?? "")", createdAt: date, isRead: (currentChat?.isRead)!))
                                        } else {
                                            self.chatUser.removeAll(where: {$0.id == destinationUser?.id})
                                            self.chatUser.append(ChatUser(imageUrl: String((destinationUser?.profileUrl)!), id: String((destinationUser?.id)!), name: String((destinationUser!.name)!), lastChat: "\(destinationUser!.name ?? ""): Photo .", createdAt: date, isRead: (currentChat?.isRead)!))
                                        }
                                    }
                                } else {
                                    if currentChat?.type == "text"{
                                        self.chatUser.append(ChatUser(imageUrl: String((destinationUser?.profileUrl)!), id: String((destinationUser?.id)!), name: String((destinationUser?.name)!), lastChat: "\(destinationUser!.name ?? ""): \(currentChat!.content ?? "")", createdAt: date, isRead: (currentChat?.isRead)!))
                                    }else{
                                        self.chatUser.append(ChatUser(imageUrl: String((destinationUser?.profileUrl)!), id: String((destinationUser?.id)!), name: String((destinationUser!.name)!), lastChat: "\(destinationUser!.name ?? ""): Photo .", createdAt: date, isRead: (currentChat?.isRead)!))
                                    }
                                }
                            }
                            self.chatUser = self.chatUser.sorted(by: { $0.createdAt.compare($1.createdAt) == .orderedDescending})
                            if self.chatUser.count == 0 {
                                self.emptyLabel.isHidden = false
                                self.tableView.isHidden = true
                            } else {
                                self.emptyLabel.isHidden = true
                                self.tableView.isHidden = false
                            }
                            self.tableView.reloadData()
//                            let json = Mapper().toJSONString(self.chatUser, prettyPrint: true)!
//                            print("\nChat Users: \(json)")
                        }
                    }
                }
            }
        }
    }
    

//    func initialRightNavBar() {
//        var list = UIImage()
//        if #available(iOS 13.0, *) {
//            list = UIImage.init(systemName: "bell")!
//        } else {
//            // Fallback on earlier versions
//        }
//        var like = UIImage()
//        if #available(iOS 13.0, *) {
//            like = UIImage.init(systemName: "square.and.pencil")!
//        } else {
//            // Fallback on earlier versions
//        }
//        //List Button
//        let notificationBtn: UIButton = UIButton(type: .system)
//        notificationBtn.setImage(list, for: .normal)
//        notificationBtn.addTarget(self, action: #selector(viewNotificiation(_:)), for: .touchUpInside)
//        notificationBtn.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
//        notificationBtn.tintColor = UIColor.randevoo.mainBlack
//        let notificationBarBtn = UIBarButtonItem(customView: notificationBtn)
//        //Like Button
//        let composeBtn: UIButton = UIButton(type: .system)
//        composeBtn.setImage(like, for: .normal)
//        composeBtn.addTarget(self, action: #selector(composeNewMessage(_:)), for: .touchUpInside)
//        composeBtn.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
//        composeBtn.tintColor = UIColor.randevoo.mainBlack
//        let composeBarBtn = UIBarButtonItem(customView: composeBtn)
//        self.navigationItem.setRightBarButtonItems([composeBarBtn, notificationBarBtn], animated: false)
//    }
    
    @IBAction func handleNotification(_ sender: Any?) {

    }
     
    @IBAction func handleCompose(_ sender: Any?) {
        let newMsgController = NewMessageController()
        newMsgController.personalAccID = (personalAccount?.id)!
        newMsgController.personalAccName = (personalAccount?.name)!
        newMsgController.rootVC = self
        let navVC =  UINavigationController(rootViewController: newMsgController)
        self.present(navVC, animated:true, completion: nil)
    }
    
    
    private func setupNavItems() {
        let title = UILabel()
        title.text = "Inbox"
        title.textColor = UIColor.randevoo.mainBlack
        title.font = UIFont(name: "Quicksand-Bold", size: 20)
        navigationItem.titleView = title
        
        let notificationBarButton = UIBarButtonItem(image: UIImage(named: "NotificationIcon")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleNotification(_:)))
        let composeBarButton = UIBarButtonItem(image: UIImage(named: "ComposeIcon")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCompose(_:)))
        navigationItem.rightBarButtonItems = [composeBarButton, notificationBarButton]
    }
    
}

extension NotificationsController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: chatCell, for: indexPath) as! ChatCell
        if chatUser[indexPath.item].imageUrl != "" {
            cell.userImg.af.setImage(withURL: URL(string: chatUser[indexPath.item].imageUrl)!)
        } else {
            cell.userImg.image = UIImage.init(named: "ProfileSelected")
        }
        cell.userName.text = chatUser[indexPath.item].name
        cell.lastChat.text = chatUser[indexPath.item].lastChat
        print(chatUser[indexPath.item].lastChat)
        print(chatUser[indexPath.item].isRead)
        if !chatUser[indexPath.item].isRead {
            cell.lastChat.font = UIFont(name: "Quicksand-Bold", size: 18)
        } else {
            cell.lastChat.font = UIFont(name: "Quicksand-Regular", size: 18)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let directChat = ChatController()
        directChat.destinationUserID = chatUser[indexPath.item].id
        directChat.destinationUserName = chatUser[indexPath.item].name
        directChat.sourceUserID = (personalAccount?.id)!
        directChat.sourceUserName = (personalAccount?.name)!
        directChat.destinationProfileUrl = chatUser[indexPath.item].imageUrl
        navigationController?.pushViewController(directChat, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            navigationController?.setNavigationBarHidden(true, animated: true)
            mainTabBar.isHidden = true
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
            mainTabBar.isHidden = false
        }
    }
}

